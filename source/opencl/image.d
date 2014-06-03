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
module opencl.image;

import opencl.c.cl;
import opencl.c.cl_gl;
import opencl.context;
import opencl.error;
import opencl.memory;
import opencl.wrapper;

/**
 *	base class for the different image types
 *
 *	used to store a one-, two- or three- dimensional texture, frame-buffer or image.
 *	The elements of an image object are selected from a list of predefined image formats.
 *	The minimum number of elements in a memory object is one
 */
struct CLImage
{
	CLMemory sup;
	alias sup this;

	this(cl_mem obj)
	{
		sup = CLMemory(obj);
	}

	@property
	{
		//!image format descriptor specified when image was created
		auto format()
		{
			return this.getInfo!(cl_image_format, clGetImageInfo)(CL_IMAGE_FORMAT);
		}
		
		/**
		 *	size of each element of the image memory object given by image. An
		 *	element is made up of n channels. The value of n is given in cl_image_format descriptor.
		 */
		size_t elementSize()
		{
			return this.getInfo!(size_t, clGetImageInfo)(CL_IMAGE_ELEMENT_SIZE);
		}
		
		//! size in bytes of a row of elements of the image object given by image
		size_t rowPitch()
		{
			return this.getInfo!(size_t, clGetImageInfo)(CL_IMAGE_ROW_PITCH);
		}

		/**
		 *	size in bytes of a 2D slice for the 3D image object given by image.
		 *
		 *	For a 2D image object this value will be 0.
		 */
		size_t slicePitch()
		{
			return this.getInfo!(size_t, clGetImageInfo)(CL_IMAGE_SLICE_PITCH);
		}

		//! width in pixels
		size_t width()
		{
			return this.getInfo!(size_t, clGetImageInfo)(CL_IMAGE_WIDTH);
		}

		//! height in pixels 
		size_t height()
		{
			return this.getInfo!(size_t, clGetImageInfo)(CL_IMAGE_HEIGHT);
		}

		/**
		 *	depth of the image in pixels
		 *
		 *	For a 2D image object, depth = 0
		 */
		size_t depth()
		{
			return this.getInfo!(size_t, clGetImageInfo)(CL_IMAGE_DEPTH);
		}

		//! The target argument specified in CLImage2DGL, CLImage3DGL constructors
		cl_GLenum textureTarget()
		{
			return this.getInfo!(cl_GLenum, clGetGLTextureInfo)(CL_GL_TEXTURE_TARGET);
		}

		//! The miplevel argument specified in CLImage2DGL, CLImage3DGL constructors
		cl_GLint mipmapLevel()
		{
			return this.getInfo!(cl_GLint, clGetGLTextureInfo)(CL_GL_MIPMAP_LEVEL);
		}
	} // of @property
}

//! 2D Image
struct CLImage2D
{
	CLImage sup;
	alias sup this;

	this(cl_mem obj)
	{
		sup = CLImage(obj);
	}

	/**
	 *	Params:
	 *		flags	= used to specify allocation and usage info for the image object
	 *		format	= describes image format properties
	 *		rowPitch= scan-line pitch in bytes
	 *		hostPtr	= can be a pointer to host-allocated image data to be used
	 */
	this(CLContext context, cl_mem_flags flags, const cl_image_format format, size_t width, size_t height, size_t rowPitch, void* hostPtr = null)
	{
		// call "base constructor"
		cl_errcode res;
		sup = CLImage(clCreateImage2D(context.cptr, flags, &format, width, height, rowPitch, hostPtr, &res));
		
		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",					""],
			["CL_INVALID_VALUE",					"invalid image flags"],
			["CL_INVALID_IMAGE_FORMAT_DESCRIPTOR",	"values specified in format are not valid or format is null"],
			["CL_INVALID_IMAGE_SIZE",				"width or height are 0 OR exceed CL_DEVICE_IMAGE2D_MAX_WIDTH or CL_DEVICE_IMAGE2D_MAX_HEIGHT resp. OR rowPitch is not valid"],
			["CL_INVALID_HOST_PTR",					"hostPtr is null and CL_MEM_USE_HOST_PTR or CL_MEM_COPY_HOST_PTR are set in flags or if hostPtr is not null but CL_MEM_COPY_HOST_PTR or CL_MEM_USE_HOST_PTR are not set in"],
			["CL_IMAGE_FORMAT_NOT_SUPPORTED",		"format is not supported"],
			["CL_MEM_OBJECT_ALLOCATION_FAILURE",	"couldn't allocate memory for image object"],
			["CL_INVALID_OPERATION",				"there are no devices in context that support images (i.e. CL_DEVICE_IMAGE_SUPPORT is CL_FALSE)"],
			["CL_OUT_OF_RESOURCES",					""],
			["CL_OUT_OF_HOST_MEMORY",				""]
		));
	}
}

//! 2D image for GL interop.
struct CLImage2DGL
{
	CLImage2D sup;
	alias sup this;

	/**
	 *	creates an OpenCL 2D image object from an OpenGL 2D texture object, or a single face of an OpenGL cubemap texture object
	 *
	 *	Params:
	 *		flags	= only CL_MEM_READ_ONLY, CL_MEM_WRITE_ONLY and CL_MEM_READ_WRITE may be used
	 *		target	= used only to define the image type of texture. No reference to a bound GL texture object is made or implied by this parameter
	 *		miplevel= mipmap level to be used
	 *		texobj	= name of a complete GL 2D, cubemap or rectangle texture object
	 */
	this(const CLContext context, cl_mem_flags flags, cl_GLenum target, cl_GLint  miplevel, cl_GLuint texobj)
	{
		// call "base constructor"
		cl_errcode res;
		sup = CLImage2D(clCreateFromGLTexture2D(context.cptr, flags, target, miplevel, texobj, &res));

		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",		"context is not a valid context or was not created from a GL context"],
			["CL_INVALID_VALUE",		"flags or target not valid"],
			["CL_INVALID_MIP_LEVEL",	"miplevel is invalid OR OpenGL implementation does not support creating from mipmap levels > 0"],
			["CL_INVALID_GL_OBJECT",	"texobj is not a GL texture object whose type matches target OR the specified miplevel of texture is not defined OR width or height of the specified miplevel is zero"],
			["CL_INVALID_IMAGE_FORMAT_DESCRIPTOR",	"the OpenGL texture internal format does not map to a supported OpenCL image format"],
			["CL_INVALID_OPERATION",	"texobj is a GL texture object created with a border width value greater than zero (OR implementation does not support miplevel values > 0?)"],
			["CL_OUT_OF_RESOURCES",		""],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}
}

//! 3D Image
struct CLImage3D
{
	CLImage sup;
	alias sup this;

	this(cl_mem obj)
	{
		sup = CLImage(obj);
	}

	/**
	 *	Params:
	 *		flags		= used to specify allocation and usage info for the image object
	 *		format		= describes image format properties
	 *		rowPitch	= scan-line pitch in bytes
	 *		slicePitch	= size in bytes of each 2D slice in the 3D image
	 *		hostPtr		= can be a pointer to host-allocated image data to be used
	 */
	this(CLContext context, cl_mem_flags flags, const cl_image_format format, size_t width, size_t height, size_t depth, size_t rowPitch, size_t slicePitch, void* hostPtr = null)
	{
		// call "base constructor"
		cl_errcode res;
		sup = CLImage(clCreateImage3D(context.cptr, flags, &format, width, height, depth, rowPitch, slicePitch, hostPtr, &res));
		
		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",					""],
			["CL_INVALID_VALUE",					"invalid image flags"],
			["CL_INVALID_IMAGE_FORMAT_DESCRIPTOR",	"values specified in format are not valid or format is null"],
			["CL_INVALID_IMAGE_SIZE",				"width or height are 0 or depth <= 1 OR exceed CL_DEVICE_IMAGE3D_MAX_WIDTH or CL_DEVICE_IMAGE3D_MAX_HEIGHT or CL_DEVICE_IMAGE3D_MAX_DEPTH resp. OR rowPitch or slicePitch is not valid"],
			["CL_INVALID_HOST_PTR",					"hostPtr is null and CL_MEM_USE_HOST_PTR or CL_MEM_COPY_HOST_PTR are set in flags or if hostPtr is not null but CL_MEM_COPY_HOST_PTR or CL_MEM_USE_HOST_PTR are not set in"],
			["CL_IMAGE_FORMAT_NOT_SUPPORTED",		"format is not supported"],
			["CL_MEM_OBJECT_ALLOCATION_FAILURE",	"couldn't allocate memory for image object"],
			["CL_INVALID_OPERATION",				"there are no devices in context that support images (i.e. CL_DEVICE_IMAGE_SUPPORT is CL_FALSE)"],
			["CL_OUT_OF_RESOURCES",					""],
			["CL_OUT_OF_HOST_MEMORY",				""]
		));
	}
}

//! 3D image for GL interop.
struct CLImage3DGL
{
	CLImage3D sup;
	alias sup this;

	/**
	 *	creates an OpenCL 3D image object from an OpenGL 3D texture object
	 *
	 *	Params:
	 *		flags	= only CL_MEM_READ_ONLY, CL_MEM_WRITE_ONLY and CL_MEM_READ_WRITE may be used
	 *		target	= used only to define the image type of texture. No reference to a bound GL texture object is made or implied by this parameter. must be GL_TEXTURE_3D
	 *		miplevel= mipmap level to be used
	 *		texobj	= name of a complete GL 3D texture object
	 */
	this(const CLContext context, cl_mem_flags flags, cl_GLenum target, cl_GLint  miplevel, cl_GLuint texobj)
	{
		cl_errcode res;
		sup = CLImage3D(clCreateFromGLTexture3D(context.cptr, flags, target, miplevel, texobj, &res));

		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",		"context is not a valid context or was not created from a GL context"],
			["CL_INVALID_VALUE",		"flags or target not valid"],
			["CL_INVALID_MIP_LEVEL",	"miplevel is invalid OR OpenGL implementation does not support creating from mipmap levels > 0"],
			["CL_INVALID_GL_OBJECT",	"texobj is not a GL texture object whose type matches target OR the specified miplevel of texture is not defined OR width or height of the specified miplevel is zero"],
			["CL_INVALID_IMAGE_FORMAT_DESCRIPTOR",	"the OpenGL texture internal format does not map to a supported OpenCL image format"],
			["CL_INVALID_OPERATION",	"texobj is a GL texture object created with a border width value greater than zero (OR implementation does not support miplevel values > 0?)"],
			["CL_OUT_OF_RESOURCES",		""],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}
}
