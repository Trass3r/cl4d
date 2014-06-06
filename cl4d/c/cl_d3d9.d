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

module cl4d.c.cl_d3d9;

import cl4d.c.cl;

version(Windows):
extern(System):

import core.sys.windows.windows;

/******************************************************************************
 * cl_nv_d3d9_sharing														  *
 ******************************************************************************/

struct IDirect3DVertexBuffer9;
struct IDirect3DIndexBuffer9;
struct IDirect3DSurface9;
struct IDirect3DCubeTexture9;
struct IDirect3DVolumeTexture9;
struct IDirect3DTexture9;

// Error Codes
enum
{
	CL_INVALID_D3D9_DEVICE_NV				= -1010,
	CL_INVALID_D3D9_RESOURCE_NV				= -1011,
	CL_D3D9_RESOURCE_ALREADY_ACQUIRED_NV	= -1012,
	CL_D3D9_RESOURCE_NOT_ACQUIRED_NV		= -1013,

// cl_context_info
	CL_CONTEXT_D3D9_DEVICE_NV			= 0x4026,

// cl_mem_info
	CL_MEM_D3D9_RESOURCE_NV				= 0x4027,

// cl_image_info
	CL_IMAGE_D3D9_FACE_NV				= 0x4028,
	CL_IMAGE_D3D9_LEVEL_NV				= 0x4029,

// cl_command_type
	CL_COMMAND_ACQUIRE_D3D9_OBJECTS_NV	= 0x402A,
	CL_COMMAND_RELEASE_D3D9_OBJECTS_NV	= 0x402B,
}

enum D3DCUBEMAP_FACES 
{ 
  D3DCUBEMAP_FACE_POSITIVE_X   = 0,
  D3DCUBEMAP_FACE_NEGATIVE_X   = 1,
  D3DCUBEMAP_FACE_POSITIVE_Y   = 2,
  D3DCUBEMAP_FACE_NEGATIVE_Y   = 3,
  D3DCUBEMAP_FACE_POSITIVE_Z   = 4,
  D3DCUBEMAP_FACE_NEGATIVE_Z   = 5,
  D3DCUBEMAP_FACE_FORCE_DWORD  = 0xffffffff
}

enum cl_d3d9_device_source_nv : cl_uint
{
	CL_D3D9_DEVICE_NV					= 0x4022,
	CL_D3D9_ADAPTER_NAME_NV				= 0x4023,
}
mixin(bringToCurrentScope!cl_d3d9_device_source_nv);

enum cl_d3d9_device_set_nv : cl_uint
{
	CL_PREFERRED_DEVICES_FOR_D3D9_NV	= 0x4024,
	CL_ALL_DEVICES_FOR_D3D9_NV			= 0x4025,
}
mixin(bringToCurrentScope!cl_d3d9_device_set_nv);


/******************************************************************************/

alias extern(System) cl_errcode function(
	cl_platform_id				platform,
	cl_d3d9_device_source_nv	d3d_device_source,
	void*						d3d_object,
	cl_d3d9_device_set_nv		d3d_device_set,
	cl_uint						num_entries, 
	cl_device_id*				devices, 
	cl_uint*					num_devices) clGetDeviceIDsFromD3D9NV_fn;

alias extern(System) cl_mem function(
	cl_context				context,
	cl_mem_flags			flags,
	IDirect3DVertexBuffer9*	resource,
	cl_errcode*				errcode_ret) clCreateFromD3D9VertexBufferNV_fn;

alias extern(System) cl_mem function(
	cl_context				context,
	cl_mem_flags			flags,
	IDirect3DIndexBuffer9*	resource,
	cl_errcode*				errcode_ret) clCreateFromD3D9IndexBufferNV_fn;

alias extern(System) cl_mem function(
	cl_context			context,
	cl_mem_flags		flags,
	IDirect3DSurface9*	resource,
	cl_errcode*			errcode_ret) clCreateFromD3D9SurfaceNV_fn;

alias extern(System) cl_mem function(
	cl_context		 	context,
	cl_mem_flags		flags,
	IDirect3DTexture9*	resource,
	uint				miplevel,
	cl_errcode*			errcode_ret) clCreateFromD3D9TextureNV_fn;

alias extern(System) cl_mem function(
	cl_context				context,
	cl_mem_flags			flags,
	IDirect3DCubeTexture9*	resource,
	D3DCUBEMAP_FACES		facetype,
	uint					miplevel,
	cl_errcode*				errcode_ret) clCreateFromD3D9CubeTextureNV_fn;

alias extern(System) cl_mem function(
	cl_context					context,
	cl_mem_flags				flags,
	IDirect3DVolumeTexture9*	resource,
	uint						miplevel,
	cl_errcode*					errcode_ret) clCreateFromD3D9VolumeTextureNV_fn;

alias extern(System) cl_errcode function(
	cl_command_queue	command_queue,
	cl_uint				num_objects,
	const(cl_mem)*		mem_objects,
	cl_uint				num_events_in_wait_list,
	const(cl_event)*	event_wait_list,
	cl_event*			event) clEnqueueAcquireD3D9ObjectsNV_fn;

alias extern(System) cl_errcode function(
	cl_command_queue	command_queue,
	cl_uint				num_objects,
	cl_mem*				mem_objects,
	cl_uint				num_events_in_wait_list,
	const(cl_event)*	event_wait_list,
	cl_event*			event) clEnqueueReleaseD3D9ObjectsNV_fn;
