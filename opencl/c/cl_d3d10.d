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

// based on $Revision: 11708 $ on $Date: 2010-06-13 23:36:24 -0700 (Sun, 13 Jun 2010) $

module opencl.c.cl_d3d10;

//import d3d10;
import opencl.c.cl;

version(Windows):
extern(System):

import core.sys.windows.windows;

/******************************************************************************
 * cl_khr_d3d10_sharing
 ******************************************************************************/

enum
{
//	Error Codes
	CL_INVALID_D3D10_DEVICE_KHR				= -1002,
	CL_INVALID_D3D10_RESOURCE_KHR			= -1003,
	CL_D3D10_RESOURCE_ALREADY_ACQUIRED_KHR	= -1004,
	CL_D3D10_RESOURCE_NOT_ACQUIRED_KHR		= -1005,

//	cl_context_info
	CL_CONTEXT_D3D10_DEVICE_KHR						= 0x4014,
	CL_CONTEXT_D3D10_PREFER_SHARED_RESOURCES_KHR	= 0x402C,

//	cl_mem_info
	CL_MEM_D3D10_RESOURCE_KHR				= 0x4015,

//	cl_image_info
	CL_IMAGE_D3D10_SUBRESOURCE_KHR			= 0x4016,

//	cl_command_type
	CL_COMMAND_ACQUIRE_D3D10_OBJECTS_KHR	= 0x4017,
	CL_COMMAND_RELEASE_D3D10_OBJECTS_KHR	= 0x4018,
}

enum cl_d3d10_device_source_khr : cl_uint
{
	CL_D3D10_DEVICE_KHR						= 0x4010,
	CL_D3D10_DXGI_ADAPTER_KHR				= 0x4011,
}
mixin(bringToCurrentScope!cl_d3d10_device_source_khr);

enum cl_d3d10_device_set_khr : cl_uint
{
	CL_PREFERRED_DEVICES_FOR_D3D10_KHR		= 0x4012,
	CL_ALL_DEVICES_FOR_D3D10_KHR			= 0x4013,
}
mixin(bringToCurrentScope!cl_d3d10_device_set_khr);


/******************************************************************************/

alias extern(System) cl_errcode function(
	cl_platform_id				platform,
	cl_d3d10_device_source_khr	d3d_device_source,
	void*						d3d_object,
	cl_d3d10_device_set_khr		d3d_device_set,
	cl_uint						num_entries,
	cl_device_id*				devices,
	cl_uint*					num_devices
) clGetDeviceIDsFromD3D10KHR_fn;

alias extern(System) cl_mem function(
	cl_context		context,
	cl_mem_flags	flags,
	void*			resource, // ID3D10Buffer*
	cl_errcode*		errcode_ret
) clCreateFromD3D10BufferKHR_fn;

alias extern(System) cl_mem function(
	cl_context			context,
	cl_mem_flags		flags,
	void*				resource, // ID3D10Texture2D*
	UINT				subresource,
	cl_errcode*			errcode_ret
) clCreateFromD3D10Texture2DKHR_fn;

alias extern(System) cl_mem function(
	cl_context			context,
	cl_mem_flags		flags,
	void*				resource, // ID3D10Texture3D*
	UINT				subresource,
	cl_errcode*			errcode_ret
) clCreateFromD3D10Texture3DKHR_fn;

alias extern(System) cl_errcode function(
	cl_command_queue	command_queue,
	cl_uint				num_objects,
	const(cl_mem)*		mem_objects,
	cl_uint				num_events_in_wait_list,
	const(cl_event)*	event_wait_list,
	cl_event*			event
) clEnqueueAcquireD3D10ObjectsKHR_fn;

alias extern(System) cl_errcode function(
	cl_command_queue	command_queue,
	cl_uint				num_objects,
	const(cl_mem)*		mem_objects,
	cl_uint				num_events_in_wait_list,
	const(cl_event)*	event_wait_list,
	cl_event*			event
) clEnqueueReleaseD3D10ObjectsKHR_fn;