/**
 *	This example demonstrates direct manipulation of OpenGL data using OpenCL without the need to transfer data back and forth.
 *
 *	Displays an NxN grid showing circular wave propagation and interference.
 *	An OpenCL context is created from OpenGL, thus allowing access to OpenGL vertex buffer objects.
 */
module CLGLInterop;

import opencl.all;

import derelict.sdl.sdl;

import derelict.opengl.gl;
import derelict.opengl.gltypes;

version(Windows)
	import derelict.opengl.wgl;
else version(Posix)
	import derelict.opengl.glx;
else
	static assert(0, "OS not supported");

import std.datetime;
import std.stdio;

import common;

__gshared
{
float[] PositionData, ColorData, NormalsData;
int[] ElementData;
cl_GLuint[] bufs;

//! used to pass time information to OpenCL and a teste variable to switch the drawing style over time
StopWatch sw;

// CL stuff
CLBuffer CLGLPositions;
CLBuffer CLGLColors;
CLMemories c;

CLContext context;
CLBuffer varTempo;
float[1] Tempo;
CLKernel kernelinteropTeste;
CLCommandQueue CQ;
}

void main()
{
	// create a window plus OpenGL context
	DerelictSDL.load();
	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTTHREAD);

	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	SDL_Surface* screen = SDL_SetVideoMode(1024, 768, 0, SDL_OPENGL|SDL_RESIZABLE|SDL_HWSURFACE);

	scope(exit) SDL_Quit();

	if (!screen)
		return;

	// initialize OpenGL
	DerelictGL.load();
	DerelictGL.loadClassicVersions(GLVersion.GL20); // load functions post OpenGL 1.1

	setupViewport(screen.w, screen.h);

	// start timers
	sw.start();
	StopWatch fpsTimer; // for fps display
	fpsTimer.start();

	// initialize OpenCL/OpenGL stuff
	initialize();
	debug write("initialization done\n");

	int numFrames = 0;
	bool done = false;
	while (!done)
	{
		SDL_Event evt;

		while (SDL_PollEvent(&evt))
		{
			switch(evt.type)
			{
				case SDL_VIDEORESIZE:
					screen = SDL_SetVideoMode(evt.resize.w, evt.resize.h, 0, SDL_OPENGL|SDL_RESIZABLE|SDL_HWSURFACE);
					if (screen)
						setupViewport(screen.w, screen.h);
					else
					{} // Uh oh, we couldn't set the new video mode??
					break;

				case SDL_QUIT:
					done = 1;
					break;
				default:
			}
		}

		// update scene
		callCLKernel();
		// draw scene
		draw();
		SDL_GL_SwapBuffers();

		// compute fps
		numFrames++;
		if (fpsTimer.peek().msecs > 1000)
		{
			write(numFrames, " FPS\n");
			fpsTimer.reset();
			numFrames = 0;
		}
	}
}

//! initialize OpenGL/OpenCL stuff
private void initialize()
{
	// enable depth test, materials and blending,
	// in case you want to play with the alpha components of the colors later
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);

	// materials, color
	glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
	glEnable(GL_COLOR_MATERIAL);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	/*
	 *	We will create a NxN grid in xy in the interval [-2,2]x[-2,2],
	 *	with all z components set to zero because we will manipulate the Z components using OpenCL
	 */
	immutable int N = 400;
	PositionData = new float[3 * N * N];
	NormalsData = new float[3 * N * N];
	ColorData = new float[4 * N * N];
	foreach (int i; 0 .. N)
		foreach (int j; 0 .. N)
		{
			PositionData[3 * (i + N * j)] = 4 * (cast(float)i / cast(float)N - 0.5f);
			PositionData[1 + 3 * (i + N * j)] = 4 * (cast(float)j / cast(float)N - 0.5f);

			NormalsData[2 + 3 * (i + N * j)] = 1.0f;

			ColorData[2 + 4 * (i + N * j)] = cast(float)i / cast(float)(N - 1);
			ColorData[3 + 4 * (i + N * j)] = 1.0f;
		}

	ElementData = new int[3 * 2 * (N - 1) * (N - 1)];
	foreach (int i; 0 .. N - 1)
		foreach (int j; 0 .. N - 1)
		{
			ElementData[6 * (i + (N - 1) * j)] = i + N * j;
			ElementData[6 * (i + (N - 1) * j) + 1] = i + N * (j + 1);
			ElementData[6 * (i + (N - 1) * j) + 2] = i + 1 + N * (j + 1);

			ElementData[6 * (i + (N - 1) * j) + 3] = i + N * j;
			ElementData[6 * (i + (N - 1) * j) + 4] = i + 1 + N * (j + 1);
			ElementData[6 * (i + (N - 1) * j) + 5] = i + 1 + N * j;
		}

	// now we create the OpenGL vertex buffer objects
	bufs = new uint[4];
	glGenBuffers(4, bufs.ptr);

	glBindBuffer(GL_ARRAY_BUFFER, bufs[0]);
	glBufferData(GL_ARRAY_BUFFER, ColorData.arrsizeof, ColorData.ptr, GL_STREAM_DRAW);

	glBindBuffer(GL_ARRAY_BUFFER, bufs[1]);
	glBufferData(GL_ARRAY_BUFFER, PositionData.arrsizeof, PositionData.ptr, GL_STREAM_DRAW);

	glBindBuffer(GL_ARRAY_BUFFER, bufs[2]);
	glBufferData(GL_ARRAY_BUFFER, NormalsData.arrsizeof, NormalsData.ptr, GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bufs[3]);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, ElementData.arrsizeof, ElementData.ptr, GL_STATIC_DRAW);


	/*** initialize OpenCL ***/
	
	// we need to inform the OpenCL API what OpenGL context we are using and the current DC
	version(Windows)
	{
		auto rawContextHandle = wglGetCurrentContext();
		auto curDC = wglGetCurrentDC();
	}
	else version(linux)
	{
		auto rawContextHandle = glXGetCurrentContext();
		auto curDisplay = glXGetCurrentDisplay();
	}
	else
		static assert(0, "OS not supported");


	/*** create the OpenCL context ***/

	cl_context_properties[] props = null;

	version(Windows)
		props = [CL_GL_CONTEXT_KHR, cast(cl_context_properties) rawContextHandle,
		         CL_WGL_HDC_KHR, cast(cl_context_properties) curDC];
	else version(Posix)
		props = [CL_GL_CONTEXT_KHR, cast(cl_context_properties) rawContextHandle,
		         CL_GLX_DISPLAY_KHR, cast(cl_context_properties) curDisplay];
	else
		static assert(0, "OS not supported");

	// will be capable of manipulating OpenGL vertex buffer arrays directly
	context = CLContext(CLHost.getPlatforms()[0], CL_DEVICE_TYPE_GPU, props);

	// recall that we stored vertexes positions in OpenGL buffer bufs[1] and colors in bufs[0]
	CLGLPositions = CLBufferGL(context, CL_MEM_READ_WRITE, bufs[1]);
	CLGLColors = CLBufferGL(context, CL_MEM_WRITE_ONLY, bufs[0]);

	// bundle them for later GL object acquiring
	c = CLMemories([CLGLPositions, CLGLColors]);

	// varTime is a regular buffer to store the simulation time, which we will pass on to the kernel
	varTempo = CLBuffer(context, CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR, Tempo.sizeof, Tempo.ptr);

	// the kernel we will use to manipulate the data
	enum interopTeste = q{
		/**
		 *  simulate the interference of two waves
		 *  positions and colors are OpenGL vertex buffer objects
		 */
		 __kernel void
		interopTeste(__global float * positions,__global float * colors, __global const float * tempo)
		{
			// Vector element index
			int i = get_global_id(0);
			float x = positions[3*i]+0.7;
			float y = positions[3*i+1];
			float r = native_sqrt(x*x+y*y);
			float t = tempo[0];
			float valor = native_exp(- r * 2.5f)*native_sin(40*r-4*t);

			x -= 1.4;
			r = native_sqrt(x*x+y*y);
			valor += native_exp(- r * 1.5f)*native_sin(40*r-4*t);

			// adjust the Z component of the vertices
			positions[3*i+2] = valor;
			// manipulate the R component of the colors
			colors[4*i] = clamp(valor,0.0f,1.0f);
		}
	};

	// create a new OpenCL program
	CLProgram prog = CLProgram(context, interopTeste);
	prog.build("", context.devices);

	// create the kernel
	kernelinteropTeste = prog.createKernel("interopTeste");
	kernelinteropTeste.setArgs(CLGLPositions, CLGLColors, varTempo);

	CQ = CLCommandQueue(context, context.devices[0]);
}

//! setup viewport (also when resized)
private void setupViewport(int w, int h)
{
	glViewport(0, 0, w, h); // Use all of the glControl painting area
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(-2, 2, -2, 2, -15, 15); // Bottom-left corner pixel has coordinate (0, 0)
	glMatrixMode (GL_MODELVIEW);
}

//! redraw the scene
void draw()
{
	double tempo = sw.peek().usecs / 1_000_000.0; // exact seconds

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	glRotatef(-40, 0.8f, 0, 0);
	glRotatef(-tempo, 0f, 0f, 0.8f);

	glBindBuffer(GL_ARRAY_BUFFER, bufs[0]);
	glColorPointer(4, GL_FLOAT, 0, null);

	glBindBuffer(GL_ARRAY_BUFFER, bufs[1]);
	glVertexPointer(3, GL_FLOAT, 0, null);

	glBindBuffer(GL_ARRAY_BUFFER, bufs[2]);
	glNormalPointer(GL_FLOAT, 0, null);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bufs[3]);
	

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);

	// switch display style from time to time
	int style = (cast(int)(tempo*0.05)) % 3;
	glDrawElements(style == 0 ? GL_TRIANGLES : (style == 1 ? GL_LINES : GL_POINTS),
	               cast(GLsizei) ElementData.length, GL_UNSIGNED_INT, null);

	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
}

/**
 *	Acquiring and manipulating vertex buffer objects
 */
private void callCLKernel()
{
	/*
	 *	OpenCL and OpenGL cannot manipulate data at the same time.
	 *	Because of this, we need to flush OpenGL before starting OpenCL operations
	 *	and finish the command queue afterwards
	 */
	glFinish();

	/*
	 *	We also need to acquire and release the buffer objects to inform the GPU
	 *	what kind of operation is being executed (OpenGL draw operations or OpenCL compute operations).
	 */
	CQ.enqueueAcquireGLObjects(c);

	// read elapsed time from Stopwatch and write to device memory
	Tempo[0] = sw.peek().usecs / 1_000_000.0f;
	CQ.enqueueWriteBuffer(varTempo, CL_TRUE, 0, Tempo.sizeof, Tempo.ptr);

	// now execute the kernel
	CQ.enqueueNDRangeKernel(kernelinteropTeste, NDRange(PositionData.length / 3));

	CQ.enqueueReleaseGLObjects(c);

	CQ.finish();
}
