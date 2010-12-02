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
module opencl.context;

import opencl.c.cl;
import opencl.device;
import opencl.error;
import opencl.platform;
import opencl.program;
import opencl.wrapper;

/**
 * context class
 * Contexts are used by the OpenCL runtime for managing objects such as command-queues, memory,
 * program and kernel objects and for executing kernels on one or more devices specified in the context.
 */
class CLContext
{
	mixin(CLWrapper("cl_context", "clGetContextInfo"));

private:
	CLPlatform	_platform;
	CLDevices	_devices;

public:
	/// creates an OpenCL context with the given devices
	this(CLDevices devices)
	{
		cl_int res;
		
		// TODO: add platform_id verification and
		auto deviceIDs = devices.getObjArray();

		// TODO: user notification function
		_object = clCreateContext(null, deviceIDs.length, deviceIDs.ptr, null, null, &res);
		if(!_object)
			mixin(exceptionHandling(
				["CL_INVALID_PLATFORM",		"no valid platform could be selected for context creation"],
				["CL_INVALID_VALUE",		"devices array has length 0 or a null pointer"],
				["CL_INVALID_DEVICE",		"devices contains an invalid device or are not associated with the specified platfor"],
				["CL_DEVICE_NOT_AVAILABLE",	"a device is currently not available even though the device was returned by getDevices"],
				["CL_OUT_OF_HOST_MEMORY",	""]
			));
	}
	
	/// create a context from all available devices
	this()
	{
		cl_int res;
		_object = clCreateContextFromType(null, CL_DEVICE_TYPE_ALL, null, null, &res);
		
		mixin(exceptionHandling(
			["CL_INVALID_PLATFORM",		"no platform could be selected"],
			["CL_INVALID_VALUE",		"internal invalid value error"],
			["CL_DEVICE_NOT_AVAILABLE",	"no devices currently available"],
			["CL_DEVICE_NOT_FOUND",		"no devices were found"],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}
	
	CLProgram createProgram(string sourceCode)
	{
		return new CLProgram(this, sourceCode);
	}
	
	@property
	{
		CLDevices devices()
		{
			return _devices;
		}
	}
}

/**
 * a context using all available GPU devices
 */
class CLGPUContext : CLContext
{
	this()
	{
		cl_int res;
		_object = clCreateContextFromType(null, CL_DEVICE_TYPE_GPU, null, null, &res);
		
		switch(res)
		{
			case CL_SUCCESS:
				break;
			case CL_INVALID_PLATFORM:
				throw new CLInvalidPlatformException("no platform could be selected");
				break;
			case CL_INVALID_VALUE:
				throw new CLInvalidValueException("internal invalid value error");
				break;
			case CL_DEVICE_NOT_AVAILABLE:
				throw new CLDeviceNotAvailableException("no GPU devices currently available");
				break;
			case CL_DEVICE_NOT_FOUND:
				throw new CLDeviceNotFoundException("no GPU devices were found");
				break;
			case CL_OUT_OF_HOST_MEMORY:
				throw new CLOutOfHostMemoryException();
				break;
			default:
				throw new CLUnrecognizedException(res);
		}
	}
}

/**
* a context using all available CPU devices
*/
class CLCPUContext : CLContext
{
	this()
	{
		cl_int res;
		_object = clCreateContextFromType(null, CL_DEVICE_TYPE_CPU, null, null, &res);
		
		switch(res)
		{
			case CL_SUCCESS:
				break;
			case CL_INVALID_PLATFORM:
				throw new CLInvalidPlatformException("no platform could be selected");
				break;
			case CL_INVALID_VALUE:
				throw new CLInvalidValueException("internal invalid value error");
				break;
			case CL_DEVICE_NOT_AVAILABLE:
				throw new CLDeviceNotAvailableException("no CPU devices currently available");
				break;
			case CL_DEVICE_NOT_FOUND:
				throw new CLDeviceNotFoundException("no CPU devices were found");
				break;
			case CL_OUT_OF_HOST_MEMORY:
				throw new CLOutOfHostMemoryException();
				break;
			default:
				throw new CLUnrecognizedException(res);
		}
	}
}

/**
* a context using all available accelerator devices
*/
class CLAccelContext : CLContext
{
	this()
	{
		cl_int res;
		_object = clCreateContextFromType(null, CL_DEVICE_TYPE_ACCELERATOR, null, null, &res);
		
		switch(res)
		{
			case CL_SUCCESS:
				break;
			case CL_INVALID_PLATFORM:
				throw new CLInvalidPlatformException("no platform could be selected");
				break;
			case CL_INVALID_VALUE:
				throw new CLInvalidValueException("internal invalid value error");
				break;
			case CL_DEVICE_NOT_AVAILABLE:
				throw new CLDeviceNotAvailableException("no accelerator devices currently available");
				break;
			case CL_DEVICE_NOT_FOUND:
				throw new CLDeviceNotFoundException("no accelerator devices were found");
				break;
			case CL_OUT_OF_HOST_MEMORY:
				throw new CLOutOfHostMemoryException();
				break;
			default:
				throw new CLUnrecognizedException(res);
		}
	}
}

/**
* a context using all available default devices
*/
class CLDefaultContext : CLContext
{
	this()
	{
		cl_int res;
		_object = clCreateContextFromType(null, CL_DEVICE_TYPE_DEFAULT, null, null, &res);
		
		switch(res)
		{
			case CL_SUCCESS:
				break;
			case CL_INVALID_PLATFORM:
				throw new CLInvalidPlatformException("no platform could be selected");
				break;
			case CL_INVALID_VALUE:
				throw new CLInvalidValueException("internal invalid value error");
				break;
			case CL_DEVICE_NOT_AVAILABLE:
				throw new CLDeviceNotAvailableException("no devices currently available");
				break;
			case CL_DEVICE_NOT_FOUND:
				throw new CLDeviceNotFoundException("no devices were found");
				break;
			case CL_OUT_OF_HOST_MEMORY:
				throw new CLOutOfHostMemoryException();
				break;
			default:
				throw new CLUnrecognizedException(res);
		}
	}
}