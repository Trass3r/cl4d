/**
 *	cl4d - object-oriented wrapper for the OpenCL C API
 *	written in the D programming language
 *
 *	Copyright:
 *		(C) 2009-2010 Andreas Hollandt
 *
 *	License:
 *		see LICENSE.txt
 */
module main;

//import common;

import opencl.all;

import std.stdio;

void main(string[] args)
{
	try
	{
		auto platform = CLPlatform.getPlatforms[1];
		writefln("%s\n\t%s\n\t%s\n\t%s\n\t%s", platform.name, platform.vendor, platform.clversion, platform.profile, platform.extensions);
	
		auto devices = platform.allDevices;
		
		foreach(device; devices)
			writefln("%s\n\t%s\n\t%s\n\t%s\n\t%s", device.name, device.vendor, device.driverVersion, device.clVersion, device.profile, device.extensions);
		
		auto context = new CLContext(devices);
		
		// Create a command queue and use the first device
		auto queue = new CLCommandQueue(context, devices[0]);
	    
		auto program = context.createProgram(`
				__kernel void sum(	__global const int* a,
									__global const int* b,
									__global int* c)
				{
					int i = get_global_id(0);
					c[i] = a[i] + b[i];
				} `);
		program.build("-Werror");
		
		auto kernel = new CLKernel(program, "sum");
		
		// create input vectors
		immutable VECTOR_SIZE = 100;
		int[VECTOR_SIZE] va = void; foreach(i,e; va) va[i] = i;
		int[VECTOR_SIZE] vb = void; foreach(i,e; vb) vb[i] = vb.length - i;
		int[VECTOR_SIZE] vc;
	
		// Create CL buffers
		auto bufferA = new CLBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, va.sizeof, va.ptr);
		auto bufferB = new CLBuffer(context, CL_MEM_READ_ONLY | CL_MEM_USE_HOST_PTR, vb.sizeof, vb.ptr);
		auto bufferC = new CLBuffer(context, CL_MEM_WRITE_ONLY, vc.sizeof);
	
		// Copy lists A and B to the memory buffers
	//	queue.enqueueWriteBuffer(bufferA, CL_TRUE, 0, va.sizeof, va.ptr);
	//	queue.enqueueWriteBuffer(bufferB, CL_TRUE, 0, vb.sizeof, vb.ptr);
	
		// Set arguments to kernel
		kernel.setArgs(bufferA, bufferB, bufferC);
	
		// Run the kernel on specific ND range
		auto global	= NDRange(VECTOR_SIZE);
		auto local	= NDRange(1);
		queue.enqueueNDRangeKernel(kernel, NullRange, global, local);
	
		// Read buffer vc into a local list
		queue.enqueueReadBuffer(bufferC, CL_TRUE, 0, vc.sizeof, vc.ptr);
	
		foreach(i,e; vc)
			writef("%d + %d = %d\n", va[i], vb[i], vc[i]);
	}
	catch(Exception e)
	{
		write(e);
	}
}