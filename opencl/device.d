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
module opencl.device;

import opencl.c.cl;
import opencl.c.cl_ext;
import opencl.error;
import opencl.platform;
import opencl.wrapper;

/// collection of several devices
alias CLObjectCollection!CLDevice CLDevices;

/// device class
struct CLDevice
{
	mixin(CLWrapper("cl_device_id", "clGetDeviceInfo"));

public:

@property
{
	//! the OpenCL device type
	auto deviceType()
	{
		return getInfo!cl_device_type(CL_DEVICE_TYPE);
	}
	
	//! A unique device vendor identifier. (e.g. PCIe ID)
	cl_uint vendorID()
	{
		return getInfo!cl_uint(CL_DEVICE_VENDOR_ID);
	}
	
	//! The number of parallel compute cores on the OpenCL device (min. 1)
	cl_uint maxComputeUnits()
	{
		return getInfo!cl_uint(CL_DEVICE_MAX_COMPUTE_UNITS);
	}
	
	/**
	 *	Maximum dimensions that specify the global and local work-item IDs used by
	 *	the data parallel execution model. (Refer to clEnqueueNDRangeKernel)
	 *	The minimum value is 3.  
	 */
	cl_uint maxWorkItemDimensions()
	{
		return getInfo!cl_uint(CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS);
	}

	/**
	 *	Maximum number of work-items that can be specified in each dimension of
	 *	the work-group to clEnqueueNDRangeKernel.
	 *
	 *	The minimum value is (1, 1, 1).
	 *
	 *	Returns:
	 *		n size_t entries, where n is the value returned by the query for maxWorkItemDimensions.   
	 */
	size_t[] maxWorkItemSizes()
	{
		return getArrayInfo!size_t(CL_DEVICE_MAX_WORK_ITEM_SIZES);
	}
	
	/**
	 *	Maximum number of work-items in a work-group executing a kernel using the data parallel execution model.
	 * (Refer to clEnqueueNDRangeKernel). The minimum value is 1.
	 */
	size_t maxWorkgroupSize()
	{
		return getInfo!size_t(CL_DEVICE_MAX_WORK_GROUP_SIZE);
	}
	
	// TODO: page 37/38 of specs
	
	//! Maximum configured clock frequency of the device in MHz
	cl_uint maxClockFrequency()
	{
		return getInfo!cl_uint(CL_DEVICE_MAX_CLOCK_FREQUENCY);
	}
	
	/**
	 *	The default compute device address space size specified as an unsigned integer value in bits.
	 *	Currently supported values are 32 or 64 bits
	 */
	cl_uint addressBits()
	{
		return getInfo!cl_uint(CL_DEVICE_ADDRESS_BITS);
	}
	
	/**
	 *	Max size of memory object allocation in bytes.
	 *	The minimum value is max(1/4 * CL_DEVICE_GLOBAL_MEM_SIZE, 128*1024*1024) 
	 */
	cl_ulong maxMemAllocSize()
	{
		return getInfo!cl_ulong(CL_DEVICE_MAX_MEM_ALLOC_SIZE);
	}
	
	//! true if images are supported by the OpenCL device
	cl_bool imageSupport()
	{
		return getInfo!cl_bool(CL_DEVICE_IMAGE_SUPPORT);
	}
	
	/**
	 *	Max number of simultaneous image objects that can be read by a kernel.
	 *	minimum value is 128 if imageSupport is true
	 */
	cl_uint maxReadImageArgs()
	{
		return getInfo!cl_uint(CL_DEVICE_MAX_READ_IMAGE_ARGS);
	}

	/**
	 *	Max number of simultaneous image objects that can be written by a kernel.
	 *	minimum value is 8 if imageSupport is true
	 */
	cl_uint maxWriteImageArgs()
	{
		return getInfo!cl_uint(CL_DEVICE_MAX_WRITE_IMAGE_ARGS);
	}

	/**
	 *	Max width of 2D image in pixels.
	 *	minimum value is 8192 if imageSupport is true
	 */
	size_t image2DMaxWidth()
	{
		return getInfo!size_t(CL_DEVICE_IMAGE2D_MAX_WIDTH);
	}
	
	/**
	 *	Max height of 2D image in pixels.
	 *	minimum value is 8192 if imageSupport is true
	 */
	size_t image2DMaxHeight()
	{
		return getInfo!size_t(CL_DEVICE_IMAGE2D_MAX_HEIGHT);
	}
	
	/**
	 *	Max width of 3D image in pixels.
	 *	minimum value is 2048 if imageSupport is true
	 */
	size_t image3DMaxWidth()
	{
		return getInfo!size_t(CL_DEVICE_IMAGE3D_MAX_WIDTH);
	}
	
	/**
	 *	Max height of 3D image in pixels.
	 *	minimum value is 2048 if imageSupport is true
	 */
	size_t image3DMaxHeight()
	{
		return getInfo!size_t(CL_DEVICE_IMAGE3D_MAX_HEIGHT);
	}
	
	/**
	 *	Max depth of 3D image in pixels.
	 *	minimum value is 2048 if imageSupport is true
	 */
	size_t image3DMaxDepth()
	{
		return getInfo!size_t(CL_DEVICE_IMAGE3D_MAX_DEPTH);
	}
	
	/**
	 *	Maximum number of samplers that can be used in a kernel.
	 *	minimum value is 16 if imageSupport is true
	 */
	cl_uint maxSamplers()
	{
		return getInfo!cl_uint(CL_DEVICE_MAX_SAMPLERS);
	}
	
	/**
	 *	Max size in bytes of the arguments that can be passed to a kernel.
	 *
	 *	The minimum value is 1024. For this minimum value, only a maximum of 
	 *	128 arguments can be passed to a kernel
	 */
	size_t maxParameterSize()
	{
		return getInfo!size_t(CL_DEVICE_MAX_PARAMETER_SIZE);
	}
	
	/**
	 *	The minimum value is the size (in bits) of the largest OpenCL built-in data
	 *	type supported by the device (long16 in FULL profile, long16 or int16 in EMBEDDED profile).
	 */
	cl_uint memBaseAddrAlign()
	{
		return getInfo!cl_uint(CL_DEVICE_MEM_BASE_ADDR_ALIGN);
	}
	
	/**
	 *	The minimum value is the size (in bytes) of the largest OpenCL builtin
	 *	data type supported by the device (long16 in FULL profile, long16 or int16 in EMBEDDED profile).
	 */
	cl_uint minDataTypeAlignSize()
	{
		return getInfo!cl_uint(CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE);
	}
	
	//! Describes single precision floating-point capability of the device. This is a bit-field, see the docs
	auto singleFpConfig()
	{
		return getInfo!cl_device_fp_config(CL_DEVICE_SINGLE_FP_CONFIG);
	}

	//! Describes double precision floating-point capability of the device. Make sure the cl_khr_fp64 extension is supported
	auto doubleFpConfig()
	{
		return getInfo!cl_device_fp_config(CL_DEVICE_DOUBLE_FP_CONFIG);
	}
	
	/**
	 *	Type of global memory cache supported. Valid values are:
	 *	CL_NONE, CL_READ_ONLY_CACHE and CL_READ_WRITE_CACHE
	 */
	auto globalMemCacheType()
	{
		return getInfo!cl_device_mem_cache_type(CL_DEVICE_GLOBAL_MEM_CACHE_TYPE);
	}

	//! size of global memory cache line in bytes.
	cl_uint globalMemCacheLineSize()
	{
		return getInfo!cl_uint(CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE);
	}

	//! size of global memory cache in bytes.
	cl_ulong globalMemCacheSize()
	{
		return getInfo!cl_ulong(CL_DEVICE_GLOBAL_MEM_CACHE_SIZE);
	}

	//! size of global device memory in bytes.
	cl_ulong globalMemSize()
	{
		return getInfo!cl_ulong(CL_DEVICE_GLOBAL_MEM_SIZE);
	}

	//! Max size in bytes of a constant buffer allocation (min. 64 KB)
	cl_ulong maxConstBufferSize()
	{
		return getInfo!cl_ulong(CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE);
	}

	//! Max number of arguments declared with the __constant qualifier in a kernel (min. 8)
	cl_uint maxConstArgs()
	{
		return getInfo!cl_uint(CL_DEVICE_MAX_CONSTANT_ARGS);
	}
	
	/**
	 *	Type of local memory supported.
	 *	This can be set to CL_LOCAL implying dedicated local memory storage such as SRAM, or CL_GLOBAL
	 */
	auto localMemType()
	{
		return getInfo!cl_device_local_mem_type(CL_DEVICE_LOCAL_MEM_TYPE);
	}

	//! Size of local memory arena in bytes. The minimum value is 32 KB.
	cl_ulong localMemSize()
	{
		return getInfo!cl_ulong(CL_DEVICE_LOCAL_MEM_SIZE);
	}
	
	//! true if the device implements error correction for all accesses to compute device memory (global and constant)
	cl_bool errorCorrectionSupport()
	{
		return getInfo!cl_bool(CL_DEVICE_ERROR_CORRECTION_SUPPORT);
	}
	
	//! returns true if the device and the host have a unified memory subsystem
	cl_bool hostUnifiedMemory()
	{
		return getInfo!cl_bool(CL_DEVICE_HOST_UNIFIED_MEMORY);
	}
	
	/**
	 *	Describes the resolution of device timer.
	 *	This is measured in nanoseconds.
	 */
	size_t profilingTimerResolution()
	{
		return getInfo!size_t(CL_DEVICE_PROFILING_TIMER_RESOLUTION);
	}

	//! is device a little endian device?
	cl_bool littleEndian()
	{
		return getInfo!cl_bool(CL_DEVICE_ENDIAN_LITTLE);
	}
	
	//! is device available?
	cl_bool available()
	{
		return getInfo!cl_bool(CL_DEVICE_AVAILABLE);
	}
	
	/**
	 *	does the implementation have a compiler to compile the program source?
	 *	This can be CL_FALSE for the embedded platform profile only.
	 */
	cl_bool compilerAvailable()
	{
		return getInfo!cl_bool(CL_DEVICE_COMPILER_AVAILABLE);
	}
	
	/**
	 *	Describes the execution capabilities of the device.
	 *
	 *	Returns:
	 *		a bit-field that describes one or more of the following values:
	 *
	 *		$(UL
	 *		$(LI CL_EXEC_KERNEL – The OpenCL device can execute OpenCL kernels.)
	 *		$(LI CL_EXEC_NATIVE_KERNEL – The OpenCL device can execute native kernels.))
	 *
	 *		The mandated minimum capability is: CL_EXEC_KERNEL.
	 */
	auto deviceExecCapabilities()
	{
		return getInfo!cl_device_exec_capabilities(CL_DEVICE_EXECUTION_CAPABILITIES);
	}
	
	/**
	 *	Describes the command-queue properties supported by the device.
	 *
	 *	Returns:
	 *		a bit-field that describes one or more of the following values:
	 *
	 *		$(UL
	 * 		$(LI CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE)
	 *		$(LI CL_QUEUE_PROFILING_ENABLE))
	 *
	 *	TODO: make own functions for outOfOrder and profiling?
	 */
	auto commandQueueProperties()
	{
		return getInfo!cl_command_queue_properties(CL_DEVICE_QUEUE_PROPERTIES);
	}
	
	/// get the associated platform
	CLPlatform platform()
	{
		return CLPlatform(getInfo!cl_platform_id(CL_DEVICE_PLATFORM));
	}
	
	/// get device name
	string name() {return getStringInfo(CL_DEVICE_NAME);}
	
	/// get device vendor
	string vendor() {return getStringInfo(CL_DEVICE_VENDOR);}
	
	/// get device OpenCL driver version in the form major_number.minor_number
	string driverVersion() {return getStringInfo(CL_DRIVER_VERSION);}
	
	/**
	 *	get OpenCL profile string
	 * 
	 *	Returns:
	 *		the profile name supported by the device. 
	 *		The profile name returned can be one of the following strings:
	 * 		$(UL
	 *		$(LI FULL_PROFILE - if the device supports the OpenCL specification
	 *		(functionality defined as part of the core specification and does not require 
	 *		any extensions to be supported).)
	 * 
	 *		$(LI EMBEDDED_PROFILE - if the device supports the OpenCL embedded profile.))
	 */
	string profile() {return getStringInfo(CL_DEVICE_PROFILE);}
	
	/**
	 * get OpenCL version string
	 * 
	 * Returns:
	 *		OpenCL version supported by the device.
	 *		This version string has the following format: 
 	 *		OpenCL<space><major_version.minor_version><space><vendor-specific information>
	 */
	string clVersion() {return getStringInfo(CL_DEVICE_VERSION);}

	/**
	 *	Returns the highest OpenCL C version supported by the compiler for this device
	 */
	string clCVersion() {return getStringInfo(CL_DEVICE_OPENCL_C_VERSION);}
	
	/**
	 * get extensions supported by the device
	 * 
	 * Returns:
	 *		Returns a space separated list of extension names
	 *		(the extension names themselves do not contain any spaces).  
	 */
	string extensions() {return getStringInfo(CL_DEVICE_EXTENSIONS);}
} // of @property
}
