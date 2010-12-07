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
//	CLPlatform	_platform;
//	CLDevices	_devices;

public:
	/// creates an OpenCL context with the given devices
	this(CLDevices devices)
	{
		cl_int res;
		
		// TODO: add platform_id verification and
		auto deviceIDs = devices.getObjArray();

		// TODO: user notification function
		//cl_context_properties[3] cps = [CL_CONTEXT_PLATFORM, cast(cl_context_properties) (devices[0].platform.getObject()), 0];
		// TODO: why doesn't it work with cps?
		_object = clCreateContext(null /*cps.ptr*/, deviceIDs.length, deviceIDs.ptr, null, null, &res);

		mixin(exceptionHandling(
			["CL_INVALID_PLATFORM",		"no valid platform could be selected for context creation"],
//			["CL_INVALID_PROPERTY",		"context property name in properties is not a supported property name, the value specified for a supported property name is not valid, OR the same property name is specified more than once"],
			["CL_INVALID_VALUE",		"devices array has length 0 or a null pointer"],
			["CL_INVALID_DEVICE",		"devices contains an invalid device or are not associated with the specified platfor"],
			["CL_DEVICE_NOT_AVAILABLE",	"a device is currently not available even though the device was returned by getDevices"],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}
	
	/// create a context from all available devices
	this(cl_device_type type = CL_DEVICE_TYPE_ALL)
	{
		cl_int res;
		_object = clCreateContextFromType(null, type, null, null, &res); // TODO: make ICD-compatible
		
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
			assert(0);
		}
	}
}