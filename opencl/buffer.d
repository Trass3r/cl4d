/**
 *	cl4d - object-oriented wrapper for the OpenCL C API
 *	written in the D programming language
 *
 *	Copyright:
 *		(C) 2009-2010 Andreas Hollandt
 *
 *	License:
 *		see LICENSE.txt
 */
module opencl.buffer;

import opencl.c.cl;
import opencl.context;
import opencl.error;
import opencl.memory;
import opencl.wrapper;

/**
 *	buffer objects are generic memory objects for containing any type of data
 */
class CLBuffer : CLMemory
{
private:

protected:
	//!
	this(cl_mem buffer)
	{
		super(buffer);
	}
	
public:
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
		// TODO: perform argument checks? is it necessary or just leave it to OpenCL?

		cl_int res;
		_object = clCreateBuffer(context.getObject(), flags, datasize, hostptr, &res);
		
		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",				""],
			["CL_INVALID_BUFFER_SIZE",			"hostbuf is empty"],
			["CL_INVALID_HOST_PTR",				"hostbuf is null and CL_MEM_USE_HOST_PTR or CL_MEM_COPY_HOST_PTR are set in flags or hostbuf !is null but CL_MEM_COPY_HOST_PTR or CL_MEM_USE_HOST_PTR are not set in flags"],
			["CL_MEM_OBJECT_ALLOCATION_FAILURE",""],
			["CL_OUT_OF_RESOURCES",				""],
			["CL_OUT_OF_HOST_MEMORY",			""]
		));
	}
	
	/**
	 *	create a new buffer object representing a specific region in this buffer
	 *
	 *	Params:
	 *		flags	= a bit-field that is used to specify allocation and usage information about the image
	 *				  memory object being created and is described in table 5.3
	 *		origin	= defines the region's offset in this buffer
	 *		size	= defines the size in bytes
	 *	Returns:
	 */
	CLBuffer createRegionSubBuffer(cl_mem_flags flags, size_t origin, size_t size)
	{
		cl_buffer_region reg = {origin, size};

		cl_int res;
		auto ret = new CLBuffer(clCreateSubBuffer(this.getObject(), flags, CL_BUFFER_CREATE_TYPE_REGION, &reg, &res));

		// TODO: handle flags separately? see CL_INVALID_VALUE message
		mixin(exceptionHandling(
			["CL_INVALID_VALUE",				"the region specified by (origin, size) is out of bounds in buffer OR buffer was created with CL_MEM_WRITE_ONLY and flags specifies CL_MEM_READ_WRITE or CL_MEM_READ_ONLY, OR if buffer was created with CL_MEM_READ_ONLY and flags specifies CL_MEM_READ_WRITE or CL_MEM_WRITE_ONLY, OR if flags specifies CL_MEM_USE_HOST_PTR or CL_MEM_ALLOC_HOST_PTR or CL_MEM_COPY_HOST_PTR"],
			["CL_INVALID_BUFFER_SIZE",			"size is 0"],
			["CL_INVALID_MEM_OBJECT",			"buffer is not a valid buffer object or is a sub-buffer object"],
			["CL_MISALIGNED_SUB_BUFFER_OFFSET",	"there are no devices in context associated with buffer for which the origin value is aligned to the CL_DEVICE_MEM_BASE_ADDR_ALIGN value"],
			["CL_MEM_OBJECT_ALLOCATION_FAILURE",""],
			["CL_OUT_OF_RESOURCES",				""],
			["CL_OUT_OF_HOST_MEMORY",			""],
		));
		
		return ret;
	}
}