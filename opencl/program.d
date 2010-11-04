/*
cl4d - object-oriented wrapper for the OpenCL C API v1.1 revision 33
written in the D programming language

Copyright (C) 2009-2010 Andreas Hollandt

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/
module opencl.program;

import opencl.kernel;
import opencl.c.cl;
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
//	CLDevices	_devices; // can be subset specified with CreateWithBinary
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
	
	/**
	 * creates a program object for a context, and loads the binary bits specified by binary into the program object
	 *
	this(CLContext context, ubyte[][] binaries, CLDevice[] devices = null)
	{
		cl_int res, binary_status;
		super(clCreateProgramWithBinary(context.getObject(), 0, devices, binaries.length, ));
		
	}
*/

	~this()
	{
		release();
	}
	
	/**
	 * builds (compiles & links) a program executable from the program source or binary for all the
	 * devices or a specific device(s) in the OpenCL context associated with program. OpenCL allows
	 * program executables to be built using the source or the binary.
	 * 
	 * be sure to use zero-terminated options string
	 */
	CLProgram build(string options = "", CLDevices devices = null)
	{
		// TODO: handle this whole (if devices is null) crap better
		cl_int res;
		cl_device_id[] cldevices;
		if (devices !is null)
			cldevices = devices.getObjArray();
		
		// If pfn_notify isn't NULL, clBuildProgram does not need to wait for the build to complete and can return immediately
		// If pfn_notify is NULL, clBuildProgram does not return until the build has completed
		// TODO: rather use callback?
		res = clBuildProgram(_object, devices is null ? 0 : cldevices.length, devices is null ? null : cldevices.ptr, options.ptr, null, null);
		
		mixin(exceptionHandling(
			["CL_INVALID_PROGRAM",		""],
			["CL_INVALID_VALUE",		"device_list is NULL and num_devices is greater than zero, or if device_list is not NULL and num_devices is zero OR pfn_notify is NULL but user_data is not NULL"],
			["CL_INVALID_DEVICE",		"OpenCL devices listed in device_list are not in the list of devices associated with program"],
			["CL_INVALID_BINARY",		"program is created with clCreateWithProgramBinary and devices listed in device_list do not have a valid program binary loaded"],
			["CL_INVALID_BUILD_OPTIONS","build options specified by options are invalid"],
			["CL_INVALID_OPERATION",	"the build of a program executable for any of the devices listed in device_list by a previous call to clBuildProgram for program has not completed OR there already are kernel objects attached to the program"],
			["CL_COMPILER_NOT_AVAILABLE","program is created with clCreateProgramWithSource and a compiler is not available i.e. CL_DEVICE_COMPILER_AVAILABLE specified in table 4.3 is set to CL_FALSE"],
			["CL_BUILD_PROGRAM_FAILURE","there is a failure to build the program executable. This error will be returned if clBuildProgram does not return until the build has completed"],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));

		return this;
	}

	/**
	 *	create a kernel object
	 *
	 *	Params:
	 *		kernelName	= a function name in the program declared with the __kernel qualifier
	 */
	CLKernel createKernel(string kernelName)
	{
		return new CLKernel(this, kernelName);
	}
	
	/**
	 *	creates kernel objects for all kernel functions in program.
	 *	Kernel objects are not created for any __kernel functions in program that do not have the same
	 *	function definition across all devices for which a program executable has been successfully built
	 *
	 *
	 *	Kernel objects can only be created once you have a program object with a valid program source 
	 *	or binary loaded into the program object and the program executable has been successfully built 
	 *	for one or more devices associated with program.  No changes to the program executable are 
	 *	allowed while there are kernel objects associated with a program object.  This means that calls to 
	 *	clBuildProgram return CL_INVALID_OPERATION if there are kernel objects attached to a 
	 *	program object.  The OpenCL context associated with program will be the context associated 
	 *	with kernel.  The list of devices associated with program are the devices associated with kernel.  
	 *	Devices associated with a program object for which a valid program executable has been built 
	 *	can be used to execute kernels declared in the program object
	 *
	 *	Returns:
	 *		kernel collection
	 */
	auto createKernels()
	{
		cl_int res;
		cl_uint numKernels;
		
		res = clCreateKernelsInProgram(getObject(), 0, null, &numKernels);
		
		mixin(exceptionHandling(
			["CL_INVALID_PROGRAM",				"program is not a valid program object"],
			["CL_INVALID_PROGRAM_EXECUTABLE",	"there is no successfully built executable for any device in program"],
			["CL_OUT_OF_HOST_MEMORY",			""]
		));
		
		auto kernels = new cl_kernel[numKernels];
		res = clCreateKernelsInProgram(getObject(), kernels.length, kernels.ptr, null);

		mixin(exceptionHandling(
			["CL_INVALID_VALUE",				"kernels is not NULL and num_kernels is less than the number of kernels in program"]
//			["CL_OUT_OF_HOST_MEMORY",			""] // TODO: need this?
		));

		return new CLKernels(kernels);
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
	
	@property
	{
		/**
		 *	Returns the build status of program for the specific device.
		 *
		 *	This can be one of the following:
		 *		CL_BUILD_NONE. The build status returned if no build has been performed
		 *						on the specified program object for device.
		 *		CL_BUILD_ERROR. The build status returned if the last call to clBuildProgram on the specified
		 *						program object for device generated an error
		 *		CL_BUILD_SUCCESS. The build status retrned if the last call to clBuildProgram on the specified
		 *						program object for device was successful.
		 *		CL_BUILD_IN_PROGRESS. The build status returned if the last call to clBuildProgram on the specified
		 *						program object for device has not finished.
		 */
		auto buildStatus(CLDevice device)
		{
			return getInfo2!(cl_build_status, clGetProgramBuildInfo)(device.getObject(), CL_PROGRAM_BUILD_STATUS);
		}
		
		/**
		 *	Return the build options specified by the options argument in build() for device.
		 *	If build status of program for device is CL_BUILD_NONE, an empty string is returned.
		 */
		string buildOptions(CLDevice device)
		{
			return getArrayInfo2!(ichar, clGetProgramBuildInfo)(device.getObject(), CL_PROGRAM_BUILD_OPTIONS);
		}
		
		/**
		 *	Return the build log when clBuildProgram was called for device.
		 *	If build status of program for device is CL_BUILD_NONE, an empty string is returned.
		 */
		string buildLog(CLDevice device)
		{
			return getArrayInfo2!(ichar, clGetProgramBuildInfo)(device.getObject(), CL_PROGRAM_BUILD_LOG);
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
		auto devices()
		{
			// TODO: maybe save the devices as a class member
			cl_device_id[] ids = getArrayInfo!(cl_device_id)(CL_PROGRAM_DEVICES);
			return new CLDevices(ids);
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
	} // of @property
}