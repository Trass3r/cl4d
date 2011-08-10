/**
 *	cl4d - object-oriented wrapper for the OpenCL C API
 *	written in the D programming language
 *
 *	Copyright:
 *		(c) 2009-2011 Andreas Hollandt
 *
 *	License:
 *		see LICENSE.txt
 */

// based on $Revision: 14835 $ on $Date: 2011-05-26 11:32:00 -0700 (Thu, 26 May 2011) $

/**
 *	cl_ext contains OpenCL extensions which don't have external (OpenGL, D3D) dependencies.
 */
module opencl.c.cl_ext;

import opencl.c.cl;


extern(System):

version = CL_ALL;

version(CL_ALL)
{
	version = CL_KHR;
	version = CL_NV;
	version = CL_AMD;
	version = CL_APPLE;
	version = CL_EXT;
}

__gshared:
version(CL_KHR)
{
enum
{
	// cl_khr_fp64 extension - no extension #define since it has no functions
	CL_DEVICE_DOUBLE_FP_CONFIG		= 0x1032,

	// cl_khr_fp16 extension - no extension #define since it has no functions
	CL_DEVICE_HALF_FP_CONFIG		= 0x1033,
}

// cl_khr_icd extension
enum
{
	// cl_platform_info
	CL_PLATFORM_ICD_SUFFIX_KHR		= 0x0920,

	// Additional Error Codes
	CL_PLATFORM_NOT_FOUND_KHR		= -1001,
}

cl_errcode clIcdGetPlatformIDsKHR(
	cl_uint				num_entries,
	cl_platform_id* 	platforms,
	cl_uint*			num_platforms
);

typedef cl_errcode function(cl_uint num_entries,
								  cl_platform_id* platforms,
								  cl_uint* num_platforms) clIcdGetPlatformIDsKHR_fn;

} // of version(CL_KHR)

version(CL_APPLE)
{
	/* Memory object destruction
	 *
	 * Apple extension for use to manage externally allocated buffers used with cl_mem objects with CL_MEM_USE_HOST_PTR
	 *
	 * Registers a user callback function that will be called when the memory object is deleted and its resources 
	 * freed. Each call to clSetMemObjectCallbackFn registers the specified user callback function on a callback 
	 * stack associated with memobj. The registered user callback functions are called in the reverse order in 
	 * which they were registered. The user callback functions are called and then the memory object is deleted 
	 * and its resources freed. This provides a mechanism for the application (and libraries) using memobj to be 
	 * notified when the memory referenced by host_ptr, specified when the memory object is created and used as 
	 * the storage bits for the memory object, can be reused or freed.
	 *
	 * The application may not call CL api's with the cl_mem object passed to the pfn_notify.
	 *
	 * Please check for the "cl_APPLE_SetMemObjectDestructor" extension using clGetDeviceInfo(CL_DEVICE_EXTENSIONS)
	 * before using.
	 */
	version = cl_APPLE_SetMemObjectDestructor;
	
	cl_errcode clSetMemObjectDestructorAPPLE(cl_mem memobj,
	                                     void function(cl_mem memobj, void* user_data) pfn_notify, // TODO: extern(C)?
	                                     void* user_data);  
	
	
	/* Context Logging Functions
	 *
	 * The next three convenience functions are intended to be used as the pfn_notify parameter to clCreateContext().
	 * Please check for the "cl_APPLE_ContextLoggingFunctions" extension using clGetDeviceInfo(CL_DEVICE_EXTENSIONS)
	 * before using.
	 *
	 * clLogMessagesToSystemLog fowards on all log messages to the Apple System Logger 
	 */
	version = cl_APPLE_ContextLoggingFunctions;
	void clLogMessagesToSystemLogAPPLE(const(char)* errstr, 
	                                   const(void)* private_info, 
	                                   size_t       cb, 
	                                   void *       user_data );
	
	// clLogMessagesToStdout sends all log messages to the file descriptor stdout
	void clLogMessagesToStdoutAPPLE(const(char)* errstr, 
	                                const(void)* private_info, 
	                                size_t       cb, 
	                                void*        user_data);
	
	// clLogMessagesToStderr sends all log messages to the file descriptor stderr
	void clLogMessagesToStderrAPPLE(const(char)* errstr, 
	                                const(void)* private_info, 
	                                size_t       cb, 
	                                void*        user_data );
} // of version(CL_APPLE)

version(CL_NV)
{
	/******************************************
	 * cl_nv_device_attribute_query extension *
	 ******************************************/
	// cl_nv_device_attribute_query extension - no extension #define since it has no functions
	enum
	{
		CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV	= 0x4000,
		CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV	= 0x4001,
		CL_DEVICE_REGISTERS_PER_BLOCK_NV		= 0x4002,
		CL_DEVICE_WARP_SIZE_NV				 	= 0x4003,
		CL_DEVICE_GPU_OVERLAP_NV			 	= 0x4004,
		CL_DEVICE_KERNEL_EXEC_TIMEOUT_NV	 	= 0x4005,
		CL_DEVICE_INTEGRATED_MEMORY_NV		 	= 0x4006,
	}
} // of version(CL_NV)

version(CL_AMD)
{
	/*********************************
	 * cl_amd_device_attribute_query *
	 *********************************/
	enum CL_DEVICE_PROFILING_TIMER_OFFSET_AMD	= 0x4036;
} // of version(CL_AMD)

version(CL_EXT)
{
	version(CL_VERSION_1_1)
	{
		/***********************************
		 * cl_ext_device_fission extension *
		 ***********************************/
		version = cl_ext_device_fission;
	
		cl_errcode clReleaseDeviceEXT(cl_device_id device); 
	
		typedef extern(System) cl_errcode function(cl_device_id device) clReleaseDeviceEXT_fn;
	
		cl_errcode clRetainDeviceEXT( cl_device_id device); 
	
		typedef extern(System) cl_errcode function(cl_device_id device) clRetainDeviceEXT_fn;
	
		typedef cl_ulong cl_device_partition_property_ext;
		
		cl_errcode clCreateSubDevicesEXT(cl_device_id in_device,
									 const(cl_device_partition_property_ext)* properties,
									 cl_uint num_entries,
									 cl_device_id* out_devices,
									 cl_uint* num_devices);
	
		typedef extern(System) cl_errcode function(cl_device_id in_device,
											   const(cl_device_partition_property_ext)* properties,
											   cl_uint num_entries,
											   cl_device_id* out_devices,
											   cl_uint* num_devices) clCreateSubDevicesEXT_fn;
	
		enum
		{
			// cl_device_partition_property_ext
			CL_DEVICE_PARTITION_EQUALLY_EXT      	= 0x4050,
			CL_DEVICE_PARTITION_BY_COUNTS_EXT    	= 0x4051,
			CL_DEVICE_PARTITION_BY_NAMES_EXT     	= 0x4052,
			CL_DEVICE_PARTITION_BY_AFFINITY_DOMAIN_EXT = 0x4053,
		 
			// clDeviceGetInfo selectors
			CL_DEVICE_PARENT_DEVICE_EXT          	= 0x4054,
			CL_DEVICE_PARTITION_TYPES_EXT        	= 0x4055,
			CL_DEVICE_AFFINITY_DOMAINS_EXT       	= 0x4056,
			CL_DEVICE_REFERENCE_COUNT_EXT        	= 0x4057,
			CL_DEVICE_PARTITION_STYLE_EXT        	= 0x4058,
	
			// error codes
			CL_DEVICE_PARTITION_FAILED_EXT			= -1057,
			CL_INVALID_PARTITION_COUNT_EXT			= -1058,
			CL_INVALID_PARTITION_NAME_EXT			= -1059,
		 
			// CL_AFFINITY_DOMAINs
			CL_AFFINITY_DOMAIN_L1_CACHE_EXT      	= 0x1,
			CL_AFFINITY_DOMAIN_L2_CACHE_EXT      	= 0x2,
			CL_AFFINITY_DOMAIN_L3_CACHE_EXT      	= 0x3,
			CL_AFFINITY_DOMAIN_L4_CACHE_EXT      	= 0x4,
			CL_AFFINITY_DOMAIN_NUMA_EXT          	= 0x10,
			CL_AFFINITY_DOMAIN_NEXT_FISSIONABLE_EXT	= 0x100,
		 
			// cl_device_partition_property_ext list terminators
			CL_PROPERTIES_LIST_END_EXT				= (cast(cl_device_partition_property_ext) 0),
			CL_PARTITION_BY_COUNTS_LIST_END_EXT		= (cast(cl_device_partition_property_ext) 0),
			CL_PARTITION_BY_NAMES_LIST_END_EXT		= (cast(cl_device_partition_property_ext) 0 - 1),
		}

		/* cl_ext_atomic_counters_32 and cl_ext_atomic_counters_64 extensions
		 * no extension #define since they have no functions
		 */
		enum CL_DEVICE_MAX_ATOMIC_COUNTERS_EXT = 0x4032;

		/***********************************
		 * cl_ext_migrate_memobject extension definitions
		 ***********************************/
		version = cl_ext_migrate_memobject;
		
		typedef cl_bitfield cl_mem_migration_flags_ext;
		
		enum CL_MIGRATE_MEM_OBJECT_HOST_EXT = 0x1;

		enum CL_COMMAND_MIGRATE_MEM_OBJECT_EXT = 0x4040;
		
		cl_int clEnqueueMigrateMemObjectEXT(
			cl_command_queue command_queue,
			cl_uint num_mem_objects,
			const(cl_mem)* mem_objects,
			cl_mem_migration_flags_ext flags,
			cl_uint num_events_in_wait_list,
			const(cl_event)* event_wait_list,
			cl_event* event);
		
		typedef extern(System) cl_int function(
			cl_command_queue command_queue,
			cl_uint num_mem_objects,
			const(cl_mem)* mem_objects,
			cl_mem_migration_flags_ext flags,
			cl_uint num_events_in_wait_list,
			const(cl_event)* event_wait_list,
			cl_event* event) clEnqueueMigrateMemObjectEXT_fn;
	}
} // of version(CL_EXT)