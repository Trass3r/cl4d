/**
 *	cl4d - object-oriented wrapper for the OpenCL C API
 *	written in the D programming language
 *
 *	Copyright:
 *		(c) 2009-2014 Andreas Hollandt
 *
 *	License:
 *		see LICENSE.txt
 */

// $Revision: 11708 $ on $Date: 2010-06-13 23:36:24 -0700 (Sun, 13 Jun 2010) $

module cl4d.c.cl_d3d11;

import cl4d.c.cl;

version(Windows):
extern(System):

import core.sys.windows.windows;

/******************************************************************************
 * cl_khr_d3d11_sharing														  *
 ******************************************************************************/

struct ID3D11Buffer;
struct ID3D11Texture2D;
struct ID3D11Texture3D;

enum
{
// Error Codes
	CL_INVALID_D3D11_DEVICE_KHR				= -1006,
	CL_INVALID_D3D11_RESOURCE_KHR			= -1007,
	CL_D3D11_RESOURCE_ALREADY_ACQUIRED_KHR	= -1008,
	CL_D3D11_RESOURCE_NOT_ACQUIRED_KHR		= -1009,

// cl_context_info
	CL_CONTEXT_D3D11_DEVICE_KHR				= 0x401D,
	CL_CONTEXT_D3D11_PREFER_SHARED_RESOURCES_KHR = 0x402D,

// cl_mem_info
	CL_MEM_D3D11_RESOURCE_KHR				= 0x401E,

// cl_image_info
	CL_IMAGE_D3D11_SUBRESOURCE_KHR			= 0x401F,

// cl_command_type
	CL_COMMAND_ACQUIRE_D3D11_OBJECTS_KHR	= 0x4020,
	CL_COMMAND_RELEASE_D3D11_OBJECTS_KHR	= 0x4021,
}

enum cl_d3d11_device_source_khr : cl_uint
{
	CL_D3D11_DEVICE_KHR						= 0x4019,
	CL_D3D11_DXGI_ADAPTER_KHR				= 0x401A,
}
mixin(bringToCurrentScope!cl_d3d11_device_source_khr);

enum cl_d3d11_device_set_khr : cl_uint
{
	CL_PREFERRED_DEVICES_FOR_D3D11_KHR		= 0x401B,
	CL_ALL_DEVICES_FOR_D3D11_KHR			= 0x401C,
}
mixin(bringToCurrentScope!cl_d3d11_device_set_khr);


/******************************************************************************/

alias extern(System) cl_errcode function(
	cl_platform_id				platform,
	cl_d3d11_device_source_khr	d3d_device_source,
	void*						d3d_object,
	cl_d3d11_device_set_khr		d3d_device_set,
	cl_uint						num_entries, 
	cl_device_id*				devices, 
	cl_uint*					num_devices) clGetDeviceIDsFromD3D11NV_fn;

alias extern(System) cl_mem function(
	cl_context		context,
	cl_mem_flags	flags,
	ID3D11Buffer*	resource,
	cl_errcode*		errcode_ret) clCreateFromD3D11BufferNV_fn;

alias extern(System) cl_mem function(
	cl_context			context,
	cl_mem_flags		flags,
	ID3D11Texture2D*	resource,
	uint				subresource,
	cl_errcode*			errcode_ret) clCreateFromD3D11Texture2DNV_fn;

alias extern(System) cl_mem function(
	cl_context			context,
	cl_mem_flags		flags,
	ID3D11Texture3D*	resource,
	uint				subresource,
	cl_errcode*			errcode_ret) clCreateFromD3D11Texture3DNV_fn;

alias extern(System) cl_errcode function(
	cl_command_queue	command_queue,
	cl_uint				num_objects,
	const(cl_mem)*		mem_objects,
	cl_uint				num_events_in_wait_list,
	const(cl_event)*	event_wait_list,
	cl_event*			event) clEnqueueAcquireD3D11ObjectsNV_fn;

alias extern(System) cl_errcode function(
	cl_command_queue	command_queue,
	cl_uint				num_objects,
	const cl_mem*		mem_objects,
	cl_uint				num_events_in_wait_list,
	const cl_event*		event_wait_list,
	cl_event*			event) clEnqueueReleaseD3D11ObjectsNV_fn;