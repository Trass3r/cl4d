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
class CLContext : CLObject
{
	mixin(CLWrapper("cl_context", "clGetContextInfo"));

public:
	/**
	 *	creates an OpenCL context using the given devices
	 *
	 *	Params:
	 *		props = additional properties, note that you don't need to specify the platform in props nor append a 0
	 */
	this(CLDevices devices, cl_context_properties[] props = null)
	{
		cl_errcode res;
		
		auto deviceIDs = devices.getObjArray();

		// TODO: user notification function

		if (props !is null) assert(props[$-1] != 0);

		cl_context_properties[] cps = props ~ [CL_CONTEXT_PLATFORM, cast(cl_context_properties) (devices[0].platform.cptr), 0];
		_object = clCreateContext(cps.ptr, deviceIDs.length, deviceIDs.ptr, null, null, &res);

		mixin(exceptionHandling(
			["CL_INVALID_PLATFORM",		"no valid platform could be selected for context creation"],
			["CL_INVALID_PROPERTY",		"context property name in properties is not a supported property name, the value specified for a supported property name is not valid, OR the same property name is specified more than once"],
			["CL_INVALID_VALUE",		"devices array has length 0 or a null pointer"],
			["CL_INVALID_DEVICE",		"devices contains an invalid device or are not associated with the specified platform"],
			["CL_DEVICE_NOT_AVAILABLE",	"a device is currently not available even though the device was returned by getDevices"],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}
	
	/**
	 *	create a context using all available devices of a specific type
	 *
	 *	Params:
	 *		props = additional properties, note that you don't need to append a 0
	 */
	this(cl_device_type type = CL_DEVICE_TYPE_ALL, cl_context_properties[] props = null)
	{
		cl_errcode res;

		cl_context_properties[] cps = props ~ 0; // TODO: make ICD-compatible
		_object = clCreateContextFromType(cps.ptr, type, null, null, &res);
		
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
	
	/**
	 *	get a list of image formats supported by the OpenCL implementation
	 */
	cl_image_format[] supportedImageFormats(cl_mem_flags flags, cl_mem_object_type type) const
	{
		cl_uint numFormats;
		cl_errcode res = clGetSupportedImageFormats(_object, flags, type, 0, null, &numFormats);

		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",		""]
		));

		if (res != CL_SUCCESS)
			throw new CLException(res);

		auto formats = new cl_image_format[numFormats];

		res = clGetSupportedImageFormats(_object, flags, type, numFormats, formats.ptr, null);

		mixin(exceptionHandling(
			["CL_INVALID_VALUE",		""],
			["CL_OUT_OF_RESOURCES",		""],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));

		return formats;
	}

	@property
	{
		//! number of devices in context
		cl_uint numDevices()
		{
			return getInfo!cl_uint(CL_CONTEXT_NUM_DEVICES);
		}

		//! devices in context
		CLDevices devices()
		{
			return new CLDevices(getArrayInfo!cl_device_id(CL_CONTEXT_DEVICES));
		}
		
		//! properties argument specified in the constructor, otherwise null or [0]
		auto contextProperties()
		{
			return getArrayInfo!cl_context_properties(CL_CONTEXT_PROPERTIES);
		}
	} // of @property
}