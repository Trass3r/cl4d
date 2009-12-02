/**
 * 
 */
module opencl.program;

import opencl.c.opencl;
import opencl.wrapper;
import opencl.device;
import opencl.context;
import opencl.error;

/**
 * An OpenCL program consists of a set of kernels that are identified as functions declared with
 * the __kernel qualifier in the program source. OpenCL programs may also contain auxiliary
 * functions and constant data that can be used by __kernel functions. The program executable
 * can be generated online or offline by the OpenCL compiler for the appropriate target device(s).
 */
class CLProgram : CLWrapper!(cl_program, clGetProgramInfo)
{
private:
	CLContext	_context; // the context that contains this program
//	CLDevice[]	_devices; // can be subset specified with CreateWithBinary
	string		_sourceCode; // the OpenCL C source code
public:
	/**
	 * creates a program object for a context, and loads the source code specified by the text strings in
	 * the strings array into the program object. The devices associated with the program object are the
	 * devices associated with context.
	 */
	this(CLContext context, string sourceCode)
	{
		cl_int res;
		size_t* lengths = cast(size_t*) [sourceCode.length];
		char** ptrs = cast(char**) [sourceCode.ptr];
		super(clCreateProgramWithSource(context.getObject(), 1, ptrs, lengths, &res));
		
		switch (res)
		{
			case CL_SUCCESS:
				_context = context; // TODO: ok like that?
				_sourceCode = sourceCode;
				break;
			case CL_INVALID_CONTEXT:
				throw new CLInvalidContextException();
				break;
			case CL_INVALID_VALUE:
				throw new CLInvalidValueException("source code string pointer is invalid");
				break;
			case CL_OUT_OF_HOST_MEMORY:
				throw new CLOutOfHostMemoryException();
				break;
			default:
				throw new CLUnrecognizedException(res);
				break;
		}
	}
	
	~this()
	{
		release();
	}

	/**
	 * builds (compiles & links) a program executable from the program source or binary for all the
	 * devices or a specific device(s) in the OpenCL context associated with program. OpenCL allows
	 * program executables to be built using the source or the binary.
	 */
	CLProgram build()
	{
		cl_int res;
		res = clBuildProgram(_object, 0, null, null, null, null);
		
		return this;
	}
	
	CLProgram buildDebug()
	{
		cl_int res;
		res = clBuildProgram(_object, 0, null, "-Werror", null, null);
		return this;
	}

	/// increments the context reference count
	void retain()
	{
		cl_int res;
		res = clRetainProgram(_object);
		if(res != CL_SUCCESS)
			throw new CLInvalidProgramException("internal program object is not a valid OpenCL context");
	}
	
	/// decrements the context reference count
	void release()
	{
		cl_int res;
		res = clReleaseContext(_object);
		if(res != CL_SUCCESS)
			throw new CLInvalidProgramException("internal program object is not a valid OpenCL context");
	}

	/**
	 * allows the implementation to release the resources allocated by the OpenCL compiler.  This is a
	 * hint from the application and does not guarantee that the compiler will not be used in the future
	 * or that the compiler will actually be unloaded by the implementation.  Calls to clBuildProgram
	 * after clUnloadCompiler will reload the compiler, if necessary, to build the appropriate program executable.
	 * 
	 * TODO: should this stay in this class?
	 */
	static void unloadCompiler()
	{
		cl_int res;
		res = clUnloadCompiler();
		if(res != CL_SUCCESS)
			throw new CLException(res, "failed unloading compiler, this shouldn't happen in OpenCL 1.0");
	}
	
	/// returns the program reference count
	// TODO: make it package?
	cl_uint referenceCount()
	{
		return getInfo!(cl_uint)(CL_PROGRAM_REFERENCE_COUNT);
	}
	
	/// TODO: check those stuff for consistency with getInfo results
	CLContext context()
	{
		return _context;
	}
	
	/**
	 * Return the list of devices associated with the program object. This can be the devices associated with context on
	 * which the program object has been created or can be a subset of devices that are specified when a progam object
	 * is created using	clCreateProgramWithBinary
	 */
	CLDevice[] devices()
	{
		cl_device_id[] ids = getArrayInfo!(cl_device_id)(CL_PROGRAM_DEVICES);
		CLDevice[] res = new CLDevice[ids.length];
		for(uint i=0; i<ids.length, i++)
			res[i] = new CLDevice(ids[i]);
		return res;
	}
	
	///
	string sourceCode()
	{
		return _sourceCode;
	}
	
	/**
	 * Return the program binaries for all devices associated with the program.
	 * Returns:
	 */
	ubyte[][] binaries()
	{
		// TODO: make sure binaries are available?
		size_t[] sizes = getArrayInfo!(size_t)(CL_PROGRAM_BINARY_SIZES);
		
		ubyte*[] ptrs = getArrayInfo!(ubyte*)(CL_PROGRAM_BINARIES);
		
		ubyte[][] res = new ubyte[][ptrs.length];
		for (uint i=0; i<ptrs.length; i++)
		{
			res[i] = ptrs[i][0 .. sizes[i]];
		}
		
		return res;
	}
}