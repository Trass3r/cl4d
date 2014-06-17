/**
 *	cl4d - object-oriented wrapper for the OpenCL C API
 *	written in the D programming language
 *
 *	Copyright:
 *		(C) 2009-2014 Andreas Hollandt
 *
 *	License:
 *		see LICENSE.txt
 */
module cl4d.context;

import cl4d.c.cl;
import cl4d.device;
import cl4d.error;
import cl4d.platform;
import cl4d.program;
import cl4d.wrapper;

/**
 * context class
 * Contexts are used by the OpenCL runtime for managing objects such as command-queues, memory,
 * program and kernel objects and for executing kernels on one or more devices specified in the context.
 */
struct CLContext
{
	mixin(CLWrapper("cl_context", "clGetContextInfo"));
public:
	/**
	 *	creates an OpenCL context using the given devices
	 *
	 *	Params:
	 *		props = optional properties, note that you don't need to specify the platform in props nor append a 0
	 */
	this(CLDevices devices, cl_context_properties[] props = null)
	{
		cl_errcode res;
		
		// TODO: user notification function

		cl_context_properties[] cps = [CL_CONTEXT_PLATFORM, cast(cl_context_properties) (devices[0].platform.cptr)] ~ props ~ 0;
		this(clCreateContext(cps.ptr, cast(cl_uint) devices.length, devices.ptr, null, null, &res));

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
	 *	create a context using all available devices of a specific type on a given platform
	 *
	 *	Params:
	 *		platform = specify the platform to use
	 *		props = optional properties, note that you don't need to append a 0
	 */
	this(CLPlatform platform, cl_device_type type = CL_DEVICE_TYPE_ALL, cl_context_properties[] props = null)
	{
		cl_errcode res;

		cl_context_properties[] cps = [CL_CONTEXT_PLATFORM, cast(cl_context_properties) platform.cptr] ~ props ~ 0;
		this(clCreateContextFromType(cps.ptr, type, null, null, &res));

		mixin(exceptionHandling(
			["CL_INVALID_PLATFORM",		"no platform could be selected"],
			["CL_INVALID_VALUE",		"internal invalid value error"],
			["CL_DEVICE_NOT_AVAILABLE",	"no devices currently available"],
			["CL_DEVICE_NOT_FOUND",		"no devices were found"],
			["CL_OUT_OF_HOST_MEMORY",	""],
			["CL_INVALID_DEVICE_TYPE",  "device_type is not a valid value"],
			["CL_INVALID_GL_SHAREGROUP_REFERENCE_KHR", "CL and GL not on the same device"]
		));
	}

	CLProgram createProgram(string sourceCode)
	{
		return CLProgram(this, sourceCode);
	}
	
	/**
	 *	get a list of image formats supported by the OpenCL implementation
	 */
	cl_image_format[] supportedImageFormats(cl_mem_flags flags, cl_mem_object_type type) const
	{
		cl_uint numFormats;
		cl_errcode res = clGetSupportedImageFormats(this._object, flags, type, 0, null, &numFormats);

		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",		""]
		));

		if (res != CL_SUCCESS)
			throw new CLException(res);

		auto formats = new cl_image_format[numFormats];

		res = clGetSupportedImageFormats(this._object, flags, type, numFormats, formats.ptr, null);

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
			auto tmp = getArrayInfo!cl_device_id(CL_CONTEXT_DEVICES);
			return CLDevices(tmp);
		}
		
		//! properties argument specified in the constructor, otherwise null or [0]
		auto contextProperties()
		{
			return getArrayInfo!cl_context_properties(CL_CONTEXT_PROPERTIES);
		}
	} // of @property
}
