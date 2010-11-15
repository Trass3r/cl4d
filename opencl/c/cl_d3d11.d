/**
 *	cl4d - object-oriented wrapper for the OpenCL C API
 *	written in the D programming language
 *
 *	Copyright:
 *		(c) 2008-2010 The Khronos Group Inc. (original C headers)
 *		(c) 2009-2010 Andreas Hollandt
 *
 *	License:
 *		see LICENSE.txt
 */

// $Revision: 11708 $ on $Date: 2010-06-13 23:36:24 -0700 (Sun, 13 Jun 2010) $

module opencl.c.cl_d3d11;

import opencl.c.cl;

extern(System):

/******************************************************************************
 * cl_nv_d3d11_sharing														*/

typedef cl_uint cl_d3d11_device_source_nv;
typedef cl_uint cl_d3d11_device_set_nv;

/******************************************************************************/

enum
{
// Error Codes
	CL_INVALID_D3D11_DEVICE_NV				= -1006,
	CL_INVALID_D3D11_RESOURCE_NV			= -1007,
	CL_D3D11_RESOURCE_ALREADY_ACQUIRED_NV	= -1008,
	CL_D3D11_RESOURCE_NOT_ACQUIRED_NV		= -1009,

// cl_d3d11_device_source_nv
	CL_D3D11_DEVICE_NV						= 0x4019,
	CL_D3D11_DXGI_ADAPTER_NV				= 0x401A,

// cl_d3d11_device_set_nv
	CL_PREFERRED_DEVICES_FOR_D3D11_NV		= 0x401B,
	CL_ALL_DEVICES_FOR_D3D11_NV				= 0x401C,

// cl_context_info
	CL_CONTEXT_D3D11_DEVICE_NV				= 0x401D,

// cl_mem_info
	CL_MEM_D3D11_RESOURCE_NV				= 0x401E,

// cl_image_info
	CL_IMAGE_D3D11_SUBRESOURCE_NV			= 0x401F,

// cl_command_type
	CL_COMMAND_ACQUIRE_D3D11_OBJECTS_NV		= 0x4020,
	CL_COMMAND_RELEASE_D3D11_OBJECTS_NV		= 0x4021,
}

/******************************************************************************/

typedef extern(System) cl_int function(
	cl_platform_id				platform,
	cl_d3d11_device_source_nv	d3d_device_source,
	void*						d3d_object,
	cl_d3d11_device_set_nv		d3d_device_set,
	cl_uint						num_entries, 
	cl_device_id*				devices, 
	cl_uint*					num_devices) clGetDeviceIDsFromD3D11NV_fn;

typedef extern(System) cl_mem function(
	cl_context		context,
	cl_mem_flags	flags,
	ID3D11Buffer*	resource,
	cl_int*			errcode_ret) clCreateFromD3D11BufferNV_fn;

typedef extern(System) cl_mem function(
	cl_context			context,
	cl_mem_flags		flags,
	ID3D11Texture2D*	resource,
	uint				subresource,
	cl_int*				errcode_ret) clCreateFromD3D11Texture2DNV_fn;

typedef extern(System) cl_mem function(
	cl_context			context,
	cl_mem_flags		flags,
	ID3D11Texture3D*	resource,
	uint				subresource,
	cl_int*				errcode_ret) clCreateFromD3D11Texture3DNV_fn;

typedef extern(System) cl_int function(
	cl_command_queue	command_queue,
	cl_uint				num_objects,
	const(cl_mem)*		mem_objects,
	cl_uint				num_events_in_wait_list,
	const(cl_event)*	event_wait_list,
	cl_event*			event) clEnqueueAcquireD3D11ObjectsNV_fn;

typedef extern(System) cl_int function(
	cl_command_queue	command_queue,
	cl_uint				num_objects,
	cl_mem*				mem_objects,
	cl_uint				num_events_in_wait_list,
	const cl_event*		event_wait_list,
	cl_event*			event) clEnqueueReleaseD3D11ObjectsNV_fn;