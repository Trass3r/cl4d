/**
 *	cl4d - object-oriented wrapper for the OpenCL C API
 *	written in the D programming language
 *
 *	Copyright:
 *		(c) 2009-2012 Andreas Hollandt
 *
 *	License:
 *		see LICENSE.txt
 */
module opencl.c.cl_dx9_media_sharing;

import opencl.c.cl;

version(Windows):
extern(System):

import core.sys.windows.windows;

/******************************************************************************
/* cl_khr_dx9_media_sharing													*/

struct IDirect3DSurface9;

struct cl_dx9_surface_info_khr
{
	IDirect3DSurface9*	resource;
	HANDLE				shared_handle;
}

alias cl_uint             cl_dx9_media_adapter_type_khr;
alias cl_uint             cl_dx9_media_adapter_set_khr;

/******************************************************************************/

enum
{
// Error Codes
	CL_INVALID_DX9_MEDIA_ADAPTER_KHR			= -1010,
	CL_INVALID_DX9_MEDIA_SURFACE_KHR			= -1011,
	CL_DX9_MEDIA_SURFACE_ALREADY_ACQUIRED_KHR	= -1012,
	CL_DX9_MEDIA_SURFACE_NOT_ACQUIRED_KHR		= -1013,
}

enum cl_media_adapter_type_khr
{
	CL_ADAPTER_D3D9_KHR			= 0x2020,
	CL_ADAPTER_D3D9EX_KHR		= 0x2021,
	CL_ADAPTER_DXVA_KHR			= 0x2022,
}
mixin(bringToCurrentScope!cl_media_adapter_type_khr);

enum cl_media_adapter_set_khr
{
	CL_PREFERRED_DEVICES_FOR_DX9_MEDIA_ADAPTER_KHR	= 0x2023,
	CL_ALL_DEVICES_FOR_DX9_MEDIA_ADAPTER_KHR		= 0x2024,
}
mixin(bringToCurrentScope!cl_media_adapter_set_khr);

enum
{
// cl_context_info
	CL_CONTEXT_D3D9_DEVICE_KHR			= 0x2025,
	CL_CONTEXT_D3D9EX_DEVICE_KHR		= 0x2026,
	CL_CONTEXT_DXVA_DEVICE_KHR			= 0x2027,

// cl_mem_info
	CL_MEM_DX9_MEDIA_ADAPTER_TYPE_KHR			= 0x2028,
	CL_MEM_DX9_MEDIA_SURFACE_INFO_KHR			= 0x2029,

// cl_image_info
	CL_IMAGE_DX9_MEDIA_PLANE_KHR			= 0x202A,

// cl_command_type
	CL_COMMAND_ACQUIRE_DX9_MEDIA_SURFACES_KHR	= 0x202B,
	CL_COMMAND_RELEASE_DX9_MEDIA_SURFACES_KHR	= 0x202C,
}

/******************************************************************************/

alias extern(System) cl_int function(
	cl_platform_id					platform,
	cl_dx9_media_adapter_type_khr	media_adapter_type,
	void*							media_adapter,
	cl_dx9_media_adapter_set_khr	media_adapter_set,
	cl_uint							num_entries,
	cl_device_id*					devices,
	cl_uint*						num_devices) clGetDeviceIDsForDX9MediaAdapterKHR_fn;

alias extern(System) cl_mem function(
	cl_context					context,
	cl_mem_flags					flags,
	cl_dx9_media_adapter_type_khr	adapter_type,
	void*							surface_info,
	cl_uint							plane,
	cl_int*							errcode_ret) clCreateFromDX9MediaSurfaceKHR_fn;

alias extern(System) cl_int function(
	cl_command_queue	command_queue,
	cl_uint				num_objects,
	const cl_mem*		mem_objects,
	cl_uint				num_events_in_wait_list,
	const cl_event*		event_wait_list,
	cl_event*			event) cl_intclEnqueueAcquireDX9MediaSurfacesKHR_fn;

alias extern(System) cl_int function(
	cl_command_queue	command_queue,
	cl_uint				num_objects,
	cl_mem*				mem_objects,
	cl_uint				num_events_in_wait_list,
	const cl_event* 	event_wait_list,
	cl_event*			event) cl_intclEnqueueReleaseDX9MediaSurfacesKHR_fn;