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
module opencl.buffer;

import opencl.c.cl;
import opencl.c.cl_gl;
import opencl.context;
import opencl.error;
import opencl.memory;
import opencl.wrapper;

/**
 *	buffer objects are generic memory objects for containing any type of data
 */
// TODO: make CLBuffer know its type?
struct CLBuffer
{
	CLMemory sup;
	alias sup this;

	this(cl_mem obj)
	{
		sup = CLMemory(obj);
	}

	/**
	 *	create a buffer object from hostbuf
	 *
	 *	Params:
	 *		context	=	is a valid OpenCL context used to create the buffer object
	 *		flags	=	is a bit-field that is used to specify allocation and usage information such as the memory
	 *					arena that should be used to allocate the buffer object and how it will be used
	 *		datasize=	size in bytes of the buffer object to be allocated
	 *		hostptr	=	is a pointer to the buffer data that may already be allocated by the application
	 */
	this(CLContext context, cl_mem_flags flags, size_t datasize, void* hostptr = null)
	{
		// call "base constructor"
		cl_errcode res;
		this(clCreateBuffer(context.cptr, flags, datasize, hostptr, &res));
		
		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",				""],
			["CL_INVALID_BUFFER_SIZE",			"hostbuf is empty"],
			["CL_INVALID_HOST_PTR",				"hostbuf is null and CL_MEM_USE_HOST_PTR or CL_MEM_COPY_HOST_PTR are set in flags or hostbuf !is null but CL_MEM_COPY_HOST_PTR or CL_MEM_USE_HOST_PTR are not set in flags"],
			["CL_MEM_OBJECT_ALLOCATION_FAILURE",""],
			["CL_OUT_OF_RESOURCES",				""],
			["CL_OUT_OF_HOST_MEMORY",			""]
		));
	}

	version(CL_VERSION_1_1)
	/**
	 *	create a new buffer object representing a specific region in this buffer
	 *
	 *	Params:
	 *		flags	= a bit-field that is used to specify allocation and usage information about the image
	 *				  memory object being created and is described in table 5.3
	 *		origin	= defines the region's offset in this buffer
	 *		size	= defines the size in bytes
	 */
	CLBuffer createRegionSubBuffer(cl_mem_flags flags, size_t origin, size_t size)
	{
		cl_buffer_region reg = {origin, size};

		cl_errcode res;
		cl_mem ret = clCreateSubBuffer(this.cptr, flags, CL_BUFFER_CREATE_TYPE_REGION, &reg, &res);

		// TODO: handle flags separately? see CL_INVALID_VALUE message
		mixin(exceptionHandling(
			["CL_INVALID_VALUE",				"the region specified by (origin, size) is out of bounds in buffer OR buffer was created with CL_MEM_WRITE_ONLY and flags specifies CL_MEM_READ_WRITE or CL_MEM_READ_ONLY, OR if buffer was created with CL_MEM_READ_ONLY and flags specifies CL_MEM_READ_WRITE or CL_MEM_WRITE_ONLY, OR if flags specifies CL_MEM_USE_HOST_PTR or CL_MEM_ALLOC_HOST_PTR or CL_MEM_COPY_HOST_PTR"],
			["CL_INVALID_BUFFER_SIZE",			"size is 0"],
			["CL_INVALID_MEM_OBJECT",			"buffer is not a valid buffer object or is a sub-buffer object"],
			["CL_MISALIGNED_SUB_BUFFER_OFFSET",	"there are no devices in context associated with buffer for which the origin value is aligned to the CL_DEVICE_MEM_BASE_ADDR_ALIGN value"],
			["CL_MEM_OBJECT_ALLOCATION_FAILURE",""],
			["CL_OUT_OF_RESOURCES",				""],
			["CL_OUT_OF_HOST_MEMORY",			""]
		));
		
		return CLBuffer(ret);
	}
	
@property
{
	//! offset of a sub-buffer object, 0 otherwise
	size_t offset()
	{
		return this.getInfo!size_t(CL_MEM_OFFSET);
	}
	
	//! the the memory object specified as buffer argument to createSubBuffer, null otherwise
	CLBuffer superBuffer()
	{
		cl_mem sub = this.getInfo!cl_mem(CL_MEM_ASSOCIATED_MEMOBJECT);
		return CLBuffer(sub);
	}
}
}

//! Memory buffer interface for GL interop.
struct CLBufferGL
{
	CLBuffer sup;
	alias sup this;

	/**
	 *	creates an OpenCL buffer object from an OpenGL buffer object
	 *
	 *	Params:
	 *		context	=	a valid OpenCL context created from an OpenGL context
	 *		flags	=	only CL_MEM_READ_ONLY, CL_MEM_WRITE_ONLY and CL_MEM_READ_WRITE can be used
	 *		bufobj	=	a GL buffer object. The data store of the GL buffer object must have have
	 *					been previously created by calling glBufferData, although its contents need not be initialized.
	 *					The size of the data store will be used to determine the size of the CL buffer object
	 */
	this(CLContext context, cl_mem_flags flags, cl_GLuint bufobj)
	{
		cl_errcode res;
		sup = CLBuffer(clCreateFromGLBuffer(context.cptr, flags, bufobj, &res));
		
		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",		"context is not a valid context or was not created from a GL context"],
			["CL_INVALID_VALUE",		"invalid flags"],
			["CL_INVALID_GL_OBJECT",	"bufobj is not a GL buffer object or is a GL buffer object but does not have an existing data store"],
			["CL_OUT_OF_RESOURCES",		""],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}
}

/**
 *	memory buffer interface for GL interop with renderbuffer
 * 
 *	NB: If the state of a GL renderbuffer object is modified through the GL API (i.e. changes to the
 *	dimensions or format used to represent pixels of the GL renderbuffer using appropriate GL API
 *	calls such as glRenderbufferStorage) while there exists a corresponding CL image object,
 *	subsequent use of the CL image object will result in undefined behavior
 */
struct CLBufferRenderGL
{
	CLBuffer sup;
	alias sup this;

	/**
	 *	creates an OpenCL 2D image object from an OpenGL renderbuffer object
	 *
	 *	Params:
	 *		context			=	a valid OpenCL context created from an OpenGL context
	 *		flags			=	only CL_MEM_READ_ONLY, CL_MEM_WRITE_ONLY and CL_MEM_READ_WRITE can be used
	 *		renderbuffer	=	renderbuffer is the name of a GL renderbuffer object.
	 *							The renderbuffer storage must be specified before the image object can be created. The renderbuffer format and dimensions
	 *							defined by OpenGL will be used to create the 2D image object. Only GL renderbuffers with
	 *							internal formats that maps to appropriate image channel order and data type specified in tables
	 *							5.5 and 5.6 of the spec can be used to create the 2D image object
	 */
	this(CLContext context, cl_mem_flags flags, cl_GLuint renderbuffer)
	{
		cl_errcode res;
		sup = CLBuffer(clCreateFromGLRenderbuffer(context.cptr, flags, renderbuffer, &res));
		
		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",					"context is not a valid context or was not created from a GL context"],
			["CL_INVALID_VALUE",					"invalid flags"],
			["CL_INVALID_GL_OBJECT",				"renderbuffer is not a GL renderbuffer object or if the width or height of renderbuffer is zero"],
			["CL_INVALID_IMAGE_FORMAT_DESCRIPTOR",	"the OpenGL renderbuffer internal format does not map to a supported OpenCL image format"],
			["CL_INVALID_OPERATION",				"renderbuffer is a multi-sample GL renderbuffer object"],
			["CL_OUT_OF_RESOURCES",					""],
			["CL_OUT_OF_HOST_MEMORY",				""]
			
		));
	}
}
