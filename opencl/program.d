/**
 *	cl4d - object-oriented wrapper for the OpenCL C API
 *	written in the D programming language
 *
 *	Copyright:
 *		(C) 2009-2011 Andreas Hollandt
 *
 *	License:
 *		see LICENSE.txt
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
class CLProgram : CLObject
{
	mixin(CLWrapper("cl_program", "clGetProgramInfo"));

public:
	/**
	 * creates a program object for a context, and loads the source code specified by the text strings in
	 * the strings array into the program object. The devices associated with the program object are the
	 * devices associated with context.
	 */
	this(CLContext context, string sourceCode)
	{
		cl_errcode res;
		size_t* lengths = cast(size_t*) [sourceCode.length];
		char** ptrs = cast(char**) [sourceCode.ptr];
		_object = clCreateProgramWithSource(context.cptr, 1, ptrs, lengths, &res);

		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",		""],
			["CL_INVALID_VALUE",		"source code string pointer is invalid"],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}
	
	/*
	 * creates a program object for a context, and loads the binary bits specified by binary into the program object
	 *
	this(CLContext context, ubyte[][] binaries, CLDevice[] devices = null)
	{
		cl_errcode res, binary_status;
		super(clCreateProgramWithBinary(context.cptr, 0, devices, binaries.length, ));
		
	}//*/
	
	/**
	 * builds (compiles & links) a program executable from the program source or binary for all the
	 * devices or a specific device(s) in the OpenCL context associated with program. OpenCL allows
	 * program executables to be built using the source or the binary.
	 */
	CLProgram build(string options = "", CLDevices devices = null)
	{
		// TODO: handle this whole (if devices is null) crap better
		cl_errcode res;
		cl_device_id[] cldevices;
		if (devices !is null)
			cldevices = devices.getObjArray();
		
		// If pfn_notify isn't NULL, clBuildProgram does not need to wait for the build to complete and can return immediately
		// If pfn_notify is NULL, clBuildProgram does not return until the build has completed
		// TODO: rather use callback?
		res = clBuildProgram(_object, devices is null ? 0 : cldevices.length, devices is null ? null : cldevices.ptr, toStringz(options), null, null);
		
		// handle build failures specifically
		if (res == CL_BUILD_PROGRAM_FAILURE)
		{
			throw new CLBuildProgramFailureException(buildLogs());
		}

		mixin(exceptionHandling(
			["CL_INVALID_PROGRAM",		""],
			["CL_INVALID_VALUE",		"device_list is NULL and num_devices is greater than zero, or if device_list is not NULL and num_devices is zero OR pfn_notify is NULL but user_data is not NULL"],
			["CL_INVALID_DEVICE",		"OpenCL devices listed in device_list are not in the list of devices associated with program"],
			["CL_INVALID_BINARY",		"program is created with clCreateWithProgramBinary and devices listed in device_list do not have a valid program binary loaded"],
			["CL_INVALID_BUILD_OPTIONS","build options specified by options are invalid"],
			["CL_INVALID_OPERATION",	"the build of a program executable for any of the devices listed in device_list by a previous call to clBuildProgram for program has not completed OR there already are kernel objects attached to the program"],
			["CL_COMPILER_NOT_AVAILABLE","program is created with clCreateProgramWithSource and a compiler is not available i.e. CL_DEVICE_COMPILER_AVAILABLE specified in table 4.3 is set to CL_FALSE"],
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
		cl_errcode res;
		cl_uint numKernels;
		
		res = clCreateKernelsInProgram(this.cptr, 0, null, &numKernels);
		
		mixin(exceptionHandling(
			["CL_INVALID_PROGRAM",				"program is not a valid program object"],
			["CL_INVALID_PROGRAM_EXECUTABLE",	"there is no successfully built executable for any device in program"]
		));
		
		auto kernels = new cl_kernel[numKernels];
		res = clCreateKernelsInProgram(this.cptr, kernels.length, kernels.ptr, null);

		mixin(exceptionHandling(
			["CL_INVALID_VALUE",				"kernels is not NULL and num_kernels is less than the number of kernels in program"],
			["CL_OUT_OF_HOST_MEMORY",			""],
			["CL_OUT_OF_RESOURCES",				""]
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
		cl_errcode res;
		res = clUnloadCompiler();
		if(res != CL_SUCCESS)
			throw new CLException(res, "failed unloading compiler, this shouldn't happen in OpenCL 1.0");
	}
	
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
		return getInfo2!(cl_build_status, clGetProgramBuildInfo)(device.cptr, CL_PROGRAM_BUILD_STATUS);
	}
	
	/**
	 *	Return the build options specified by the options argument in build() for device.
	 *	If build status of program for device is CL_BUILD_NONE, an empty string is returned.
	 */
	string buildOptions(CLDevice device)
	{
		return getArrayInfo2!(ichar, clGetProgramBuildInfo)(device.cptr, CL_PROGRAM_BUILD_OPTIONS);
	}
	
	/**
	 *	Return the build log when clBuildProgram was called for device.
	 *	If build status of program for device is CL_BUILD_NONE, an empty string is returned.
	 */
	string buildLog(CLDevice device)
	{
		return getArrayInfo2!(ichar, clGetProgramBuildInfo)(device.cptr, CL_PROGRAM_BUILD_LOG);
	}

	@property
	{
		string buildLogs()
		{
			auto devices = context.devices;
			string res = "Build logs:\n";
			foreach(device; devices)
			{
				// TODO: currently build just builds for all devices, but what if build(specific_device) is added?
				res ~=  device.name ~ ": " ~ buildLog(device) ~ "\n";
			}
			
			return res;
		}
		
		//! the context specified when the program object was created
		CLContext context()
		{
			return new CLContext(getInfo!cl_context(CL_PROGRAM_CONTEXT));
		}

		//! number of devices associated with program
		cl_uint numDevices()
		{
			return getInfo!cl_uint(CL_PROGRAM_NUM_DEVICES);
		}

		/**
		 * Return the list of devices associated with the program object. This can be the devices associated with context on
		 * which the program object has been created or can be a subset of devices that are specified when a progam object
		 * is created using	clCreateProgramWithBinary
		 */
		auto devices()
		{
			cl_device_id[] ids = getArrayInfo!(cl_device_id)(CL_PROGRAM_DEVICES);
			return new CLDevices(ids);
		}

		/**
		 *	the program source code specified in the constructor
		 *
		 *	the source string returned is a concatenation of all source strings specified,
		 *	with a null terminator. The concatenation strips any nulls in the original source strings.
		 *
		 *	If program is created from binaries, a null string or the appropriate program source
		 *	code is returned depending on whether or not the program source code is stored in the binary
		 */
		string sourceCode()
		{
			return getStringInfo(CL_PROGRAM_SOURCE);
		}

		/**
		 *	the program binaries for all devices associated with the program
		 *
		 *	can be an implementation-specific intermediate representation (a.k.a. IR) or
		 *	device specific executable bits or both
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