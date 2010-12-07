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
module opencl.commandqueue;

import opencl.c.cl;
import opencl.buffer;
import opencl.context;
import opencl.device;
import opencl.error;
import opencl.event;
import opencl.kernel;
import opencl.wrapper;

//!
class CLCommandQueue
{
	mixin(CLWrapper("cl_command_queue", "clGetCommandQueueInfo"));

public:
	/**
	 *	creates a command-queue on a specific device
	 *
	 *	Params:
	 *		context		=	must be a valid context
	 *		device		=	must be a device associated with context
	 *		outOfOrder	=	Determines whether the commands queued in the command-queue are executed in-order or out-oforder
	 *		profiling	=	Enable or disable profiling of commands in the command-queue
	 */
	this(CLContext context, CLDevice device, bool outOfOrder = false, bool profiling = false)
	{
		cl_int res;
		_object = clCreateCommandQueue(context.getObject(), device.getObject(), (outOfOrder ? CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE : 0) | (profiling ? CL_QUEUE_PROFILING_ENABLE : 0), &res);
		
		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",			"context is not a valid context"],
			["CL_INVALID_DEVICE",			"device is not a valid device or is not associated with context"],
			["CL_INVALID_VALUE",			"values specified in properties are not valid"],
			["CL_INVALID_QUEUE_PROPERTIES",	"values specified in properties are valid but are not supported by the device"],
			["CL_OUT_OF_RESOURCES",			""],
			["CL_OUT_OF_HOST_MEMORY",		""]
		));
	}
	
	/**
	 *	issues all previously queued OpenCL commands to the device associated with command_queue.
	 *	flush only guarantees that all queued commands get issued to the appropriate device.
	 *	There is no guarantee that they will be complete after flush returns.
	 *
	 *	Any blocking commands queued in a command-queue and clReleaseCommandQueue perform
	 *	an implicit flush of the command-queue.
	 *
	 *	To use event objects that refer to commands enqueued in a command-queue as event objects to
	 *	wait on by commands enqueued in a different command-queue, the application must call a
	 *	flush or any blocking commands that perform an implicit flush of the command-queue where
	 *	the commands that refer to these event objects are enqueued.
	 */
	void flush()
	{
		cl_int res = clFlush(getObject());
		
		mixin(exceptionHandling(
			["CL_INVALID_COMMAND_QUEUE",	""],
			["CL_OUT_OF_RESOURCES",			""],
			["CL_OUT_OF_HOST_MEMORY",		""]
		));
	}
	
	/**
	 *	blocks until all previously queued OpenCL commands in command_queue are issued to the
	 *	associated device and have completed. clFinish does not return until all queued commands in
	 *	command_queue have been processed and completed. clFinish is also a synchronization point.
	 */
	void finish()
	{
		cl_int res = clFinish(getObject());
		
		mixin(exceptionHandling(
			["CL_INVALID_COMMAND_QUEUE",	""],
			["CL_OUT_OF_RESOURCES",			""],
			["CL_OUT_OF_HOST_MEMORY",		""]
		));
	}
	
	/**
	 *	enqueues a command to execute a kernel on the device associated with this queue
	 *
	 *
	 *	Params:
	 *	    offset = can be used to specify an array of work_dim unsigned values that describe
	 *				 the offset used to calculate the global ID of a work-item. If a NullRange, the
	 *				 global IDs start at offset (0, 0, ... 0)
	 *		global = describes the number of global work-items in each dimension that will execute the kernel function.
	 *				 The total number of global work-items is computed as global[0] * ... * global[dims – 1].
	 *				 See CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS.
	 *	    local =	 describes the number of work-items that make up a work-group (also referred to as the size of the work-group)
	 *				 that will execute the kernel and is computed as local[0] * ... * local[dims - 1]
	 *				 must be less than or equal to the CL_DEVICE_MAX_WORK_GROUP_SIZE value and the number of workitems
	 *				 specified in local[0], ... local[dims – 1] must be less than or equal to the corresponding values specified by
	 *				 CL_DEVICE_MAX_WORK_ITEM_SIZES[0], ..., CL_DEVICE_MAX_WORK_ITEM_SIZES[dims – 1].
	 *
	 *				 The explicitly specified local worksize will be used to determine how to break the global work-items specified by global into
	 *				 appropriate work-group instances. If local is specified, the values specified in global[0], ... global[dims - 1] must be evenly
	 *				 divisible by the corresponding values specified in local[0], ..., local[dims – 1].
	 *
	 *				 The work-group size to be used for kernel can also be specified in the program source using the
	 *				 __attribute__((reqd_work_group_size(X, Y, Z)))qualifier (see section 6.8.2). In this case the size of work group
	 *				 specified by local_work_size must match the value specified by the reqd_work_group_size attribute qualifier.
	 *
	 *				 If local is a NullRange the OpenCL implementation will determine how to be break the global work-items into appropriate work-group instances.
	 *
	 *				 These work-group instances are executed in parallel across multiple compute units or concurrently on the same compute unit.
	 *
	 *				 Each work-item is uniquely identified by a global identifier. The global ID, which can be read inside the kernel,
	 *				 is computed using the value given by global_work_size and global_work_offset. In addition, a work-item is also identified
	 *				 within a work-group by a unique local ID. The local ID, which can also be read by the kernel, is computed using the value given
	 *				 by local_work_size. The starting local ID is always (0, 0, … 0)
	 */
	CLEvent enqueueNDRangeKernel(CLKernel kernel, const ref NDRange global, const ref NDRange local = NullRange, const ref NDRange offset = NullRange,
							CLEvents waitlist = null)
	{
		cl_event event;
		cl_int res = clEnqueueNDRangeKernel(_object, kernel.getObject(), global.dimensions, offset.ptr, global.ptr, local.ptr, waitlist is null ? 0 : waitlist.length, waitlist is null ? null : waitlist.ptr, &event);
		
		mixin(exceptionHandling(
			["CL_INVALID_COMMAND_QUEUE",	""],
			["CL_INVALID_PROGRAM_EXECUTABLE","there is no successfully built program executable available for device associated with the queue"],
			["CL_INVALID_KERNEL",			""],
			["CL_INVALID_CONTEXT",			""],
			["CL_INVALID_KERNEL_ARGS",		"the kernel argument values have not been specified"],
			["CL_INVALID_WORK_DIMENSION",	"global.dimensions is not valid (i.e. between 1 and 3)"],
			["CL_INVALID_GLOBAL_WORK_SIZE",	"global is a NullRange or any of the values specified in global[0], ... global[dims – 1] are 0 or exceed the range given by the sizeof(size_t) for the device on which the kernel execution will be enqueued"],
			["CL_INVALID_GLOBAL_OFFSET",	"the value specified in global + the corresponding values in offset for any dimensions is greater than the sizeof(size t) for the device on which the kernel execution will be enqueued"],
			["CL_INVALID_WORK_GROUP_SIZE",	"(local is specified AND (number of workitems specified by global is not evenly divisible by size of work-group given by local or does not match the work-group size specified for kernel using the __attribute__((reqd_work_group_size(X, Y, Z))) qualifier in program source OR the total number of work-items in the work-group computed as local[0] * ... * local[dims – 1] is greater than the value specified by CL_DEVICE_MAX_WORK_GROUP_SIZE)) OR local is a NullRange and the __attribute__((reqd_work_group_size(X, Y, Z))) qualifier is used to declare the work-group size for kernel in the program source."],
			["CL_INVALID_WORK_ITEM_SIZE",	"the number of work-items specified in any of local[0], ... local[dims – 1] is greater than the corresponding values specified by CL_DEVICE_MAX_WORK_ITEM_SIZES[0], ..., CL_DEVICE_MAX_WORK_ITEM_SIZES[dims – 1]."],
			["CL_MISALIGNED_SUB_BUFFER_OFFSET","a sub-buffer object is specified as the value for an argument that is a buffer object and the offset specified when the sub-buffer object is created is not aligned to CL_DEVICE_MEM_BASE_ADDR_ALIGN value for device associated with queue."],
			["CL_INVALID_IMAGE_SIZE",		"an image object is specified as an argument value and the image dimensions (image width, height, specified or compute row and/or slice pitch) are not supported by device associated with queue"],
			["CL_MEM_OBJECT_ALLOCATION_FAILURE", "could not allocate memory for data store associated with image or buffer objects specified as arguments to kernel"],
			["CL_INVALID_EVENT_WAIT_LIST",	"objects in waitlist are not valid events"],
			["CL_OUT_OF_RESOURCES",			"could not queue the execution instance of kernel on the command-queue because of insufficient resources needed to execute the kernel. For example, the explicitly specified local_work_size causes a failure to execute the kernel because of insufficient resources such as registers or local memory. Another example would be the number of read-only image args used in kernel exceed the CL_DEVICE_MAX_READ_IMAGE_ARGS value for device or the number of write-only image args used in kernel exceed the CL_DEVICE_MAX_WRITE_IMAGE_ARGS value for device or the number of samplers used in kernel exceed CL_DEVICE_MAX_SAMPLERS for device"],
			["CL_OUT_OF_HOST_MEMORY",		""]
		));
		
		return new CLEvent(event);
	}
	
	/**
	 *	enqueue commands to read from a buffer object to host memory or write to a buffer object from host memory
	 *
	 *	the command queue and the buffer must be created with the same OpenCL context
	 *
	 *	Params:
	 *		blocking	=	if false, queues a non-blocking read/write command and returns. The contents of the buffer that ptr points to
	 *								cannot be used until the command has completed. The function returns an event
	 *								object which can be used to query the execution status of the read command. When the read
	 *								command has completed, the contents of the buffer that ptr points to can be used by the application
	 *		offset		=	is the offset in bytes in the buffer object to read from or write to
	 *		size		=	is the size in bytes of data being read or written
	 *		ptr			=	is the pointer to buffer in host memory where data is to be read into or to be written from
	 *		waitlist	=	specifies events that need to complete before this particular command can be executed
	 *						they act as synchronization points. The context associated with events in waitlist and the queue must be the same
	 *
	 *	Returns:
	 *		an event object that identifies this particular read / write command and can be used to query or queue a wait for this particular command to complete
	 */
	private CLEvent enqueueReadWriteBuffer(alias func, PtrType)(CLBuffer buffer, cl_bool blocking, size_t offset, size_t size, PtrType ptr, CLEvents waitlist = null)
	in
	{
		assert(ptr !is null);
	}
	body
	{
		cl_event event;
		cl_int res = func (_object, buffer.getObject(), blocking, offset, size, ptr,  waitlist is null ? 0 : waitlist.length,  waitlist is null ? null : waitlist.ptr, &event);
		
		mixin(exceptionHandling(
			["CL_INVALID_COMMAND_QUEUE",						""],
			["CL_INVALID_CONTEXT",								"context associated with command queue and buffer or waitlist is not the same"],
			["CL_INVALID_MEM_OBJECT",							"buffer is invalid"],
			["CL_INVALID_VALUE",								"region being read/written specified by (offset, size) is out of bounds"],
			["CL_INVALID_EVENT_WAIT_LIST",						"event objects in waitlist are not valid events"],
			["CL_MISALIGNED_SUB_BUFFER_OFFSET",					"buffer is a sub-buffer object and offset specified when the sub-buffer object is created is not aligned to CL_DEVICE_MEM_BASE_ADDR_ALIGN value for device associated with queue"],
			["CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST",	"the read operations are blocking and the execution status of any of the events in waitlist is a negative integer value"],
			["CL_MEM_OBJECT_ALLOCATION_FAILURE",				"couldn't allocate memory for data store associated with buffer"],
			["CL_OUT_OF_RESOURCES",								""],
			["CL_OUT_OF_HOST_MEMORY",							""]
		));

		return new CLEvent(event);
	}
	alias enqueueReadWriteBuffer!(clEnqueueReadBuffer, void*) enqueueReadBuffer; //! ditto
	alias enqueueReadWriteBuffer!(clEnqueueWriteBuffer, const void*) enqueueWriteBuffer; //! ditto
	
	/**
	 *	enqueues a command to copy a buffer object identified by srcBuffer to another buffer object identified by dstBuffer
	 *
	 *	Params:
	 *	    srcOffset	= the offset where to begin copying data from srcBuffer
	 *	    dstOffset	= the offset where to begin copying data into dstBuffer
	 *	    size		= size in bytes to copy
	 *
	 *	Returns:
	 *		an event object that identifies this particular copy command and can be used to
	 *		query or queue a wait for this particular command to complete
	 *		The event can be ignored in which case it will not be possible for the application to query the status of this command or queue a
	 *		wait for this command to complete.  clEnqueueBarrier can be used instead
	 */
	CLEvent enqueueCopyBuffer(CLBuffer srcBuffer, CLBuffer dstBuffer, size_t srcOffset, size_t dstOffset, size_t size, CLEvents waitlist = null)
	{
		cl_event event;
		cl_int res = clEnqueueCopyBuffer(_object, srcBuffer.getObject(), dstBuffer.getObject(), srcOffset, dstOffset, size,  waitlist is null ? 0 : waitlist.length,  waitlist is null ? null : waitlist.ptr, &event);
		
		mixin(exceptionHandling(
			["CL_INVALID_COMMAND_QUEUE",		""],
			["CL_INVALID_CONTEXT",				"context associated with command queue, srcBuffer and dstBuffer are not the same or if the context associated with command queue and events in waitlist are not the same"],
			["CL_INVALID_MEM_OBJECT",			""],
			["CL_INVALID_VALUE",				"srcOffset, dstOffset, size, srcOffset + size or dstOffset + size require accessing elements outside the srcBuffer and dstBuffer buffer objects respectively"],
			["CL_INVALID_EVENT_WAIT_LIST",		"event objects in waitlist are not valid events"],
			["CL_MISALIGNED_SUB_BUFFER_OFFSET",	"srcBuffer or dstBuffer is a sub-buffer object and offset specified when the sub-buffer object is created is not aligned to CL_DEVICE_MEM_BASE_ADDR_ALIGN value for device associated with queue"],
			["CL_MEM_COPY_OVERLAP",				"srcBuffer and dstBuffer are the same buffer object and the source and destination regions overlap"],
			["CL_MEM_OBJECT_ALLOCATION_FAILURE","there is a failure to allocate memory for data store associated with srcBuffer or dstBuffer"],
			["CL_OUT_OF_RESOURCES",				""],
			["CL_OUT_OF_HOST_MEMORY",			""]
		));
		
		return new CLEvent(event);
	}

version(CL_VERSION_1_1)
{
	/**
	 *	enqueue commands to read a 2D or 3D rectangular region from a buffer object to host memory or write a 2D or 3D rectangular region to a buffer object from host memory
	 *
	 *	Also see enqueueReadWriteBuffer and OpenCL specs NOTE
	 *
	 *	Params:
	 *	    bufferOrigin	=	defines the (x, y, z) offset in the memory region associated with buffer. For a 2D rectangle region, the z value given by buffer_origin[2] should be 0. The offset in bytes is
	 *							computed as buffer_origin[2] * buffer_slice_pitch + buffer_origin[1] * buffer_row_pitch + buffer_origin[0]
	 *	    hostOrigin		=	the (x, y, z) offset in the memory region pointed to by ptr. For a 2D rectangle region, the z value given by host_origin[2] should be 0. The offset in bytes is computed as
	 *							host_origin[2] * host_slice_pitch + host_origin[1] * host_row_pitch + host_origin[0].
	 *	    region			=	the (width, height, depth) in bytes of the 2D or 3D rectangle being read or written. For a 2D rectangle copy, the depth value given by region[2] should be 1
	 *	    bufferRowPitch	=	the length of each row in bytes to be used for the memory region associated with buffer. If buffer_row_pitch is 0, buffer_row_pitch is computed as region[0]
	 *	    bufferSlicePitch=	the length of each 2D slice in bytes to be used for the memory region associated with buffer. If buffer_slice_pitch is 0, buffer_slice_pitch is computed as region[1] * buffer_row_pitch
	 *	    hostRowPitch	=	the length of each row in bytes to be used for the memory region pointed to by ptr. If host_row_pitch is 0, host_row_pitch is computed as region[0]
	 *	    hostSlicePitch	=	the length of each 2D slice in bytes to be used for the memory region pointed to by ptr. If host_slice_pitch is 0, host_slice_pitch is computed as region[1] * host_row_pitch
	 *	    ptr				=	pointer to buffer in host memory where data is to be read into or to be written from
	 *
	 *	TODO: add assertions that buffer origin etc. is correct in respect to CLBuffer isImage2D etc. see above notes
	 */
	private void enqueueReadWriteBufferRect(alias func, PtrType)(CLBuffer buffer, cl_bool blocking, const size_t[3] bufferOrigin, const size_t[3] hostOrigin, const size_t[3] region,
	                                                             PtrType ptr, CLEvents waitlist = null, size_t bufferRowPitch = 0, size_t bufferSlicePitch = 0, size_t hostRowPitch = 0, size_t hostSlicePitch = 0)
	in
	{
		assert(ptr !is null);
		assert(region[0] != 0u && region[1] != 0u && region[2] != 0u);
		if (bufferRowPitch > 0)
			assert(bufferRowPitch >= region[0]);
		if (hostRowPitch > 0)
			assert(hostRowPitch >= region[0]);
		if (bufferSlicePitch > 0)
			assert(bufferSlicePitch >= region[1] * bufferRowPitch);
		if (hostSlicePitch > 0)
			assert(hostSlicePitch >= region[1] * hostRowPitch);
	}
	body
	{
		// TODO: leave the default pitch values as 0 and let OpenCL compute or set default values as region[0]? etc. see method documentation
		cl_event event;
		cl_int res = func(_object, buffer.getObject(), blocking, bufferOrigin.ptr, hostOrigin.ptr, region.ptr, bufferRowPitch, bufferSlicePitch, hostRowPitch, hostSlicePitch, ptr,  waitlist is null ? 0 : waitlist.length,  waitlist is null ? null : waitlist.ptr, &event);
		
		mixin(exceptionHandling(
			["CL_INVALID_COMMAND_QUEUE",						""],
			["CL_INVALID_CONTEXT",								"context associated with command queue and buffer or waitlist is not the same"],
			["CL_INVALID_MEM_OBJECT",							"buffer is invalid"],
			["CL_INVALID_VALUE",								"region being read/written specified by (bufferOrigin, region) is out of bounds or pitch values are invalid"],
			["CL_INVALID_EVENT_WAIT_LIST",						"event objects in waitlist are not valid events"],
			["CL_MISALIGNED_SUB_BUFFER_OFFSET",					"buffer is a sub-buffer object and offset specified when the sub-buffer object is created is not aligned to CL_DEVICE_MEM_BASE_ADDR_ALIGN value for device associated with queue"],
			["CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST",	"the read operations are blocking and the execution status of any of the events in waitlist is a negative integer value"],
			["CL_MEM_OBJECT_ALLOCATION_FAILURE",				"couldn't allocate memory for data store associated with buffer"],
			["CL_OUT_OF_RESOURCES",								""],
			["CL_OUT_OF_HOST_MEMORY",							""]
		));

		return new CLEvent(event);

	}
	alias enqueueReadWriteBufferRect!(clEnqueueReadBufferRect, void*) enqueueReadBufferRect; //! ditto
	alias enqueueReadWriteBufferRect!(clEnqueueWriteBufferRect, const void*) enqueueWriteBufferRect; //! ditto
	
	/**
	 *	enqueues a command to copy a 2D or 3D rectangular region from the buffer object identified by
	 *	srcBuffer to a 2D or 3D region in the buffer object identified by dstBuffer
	 *
	 *	Params:
	 *	    srcOrigin	=	(x, y, z) offset in the memory region associated with srcBuffer.
	 *						For a 2D rectangle region, the z value given by src_origin[2] should be 0.
	 *						The offset in bytes is computed as src_origin[2] * srcSlicePitch + src_origin[1] * srcRowPitch + src_origin[0]
	 *		dstOrigin	=	analogous to above
	 *		region		=	(width, height, depth) in bytes of the 2D or 3D rectangle being copied.
	 *						For a 2D rectangle, the depth value given by region[2] should be 1
	 *		srcRowPitch	=	length of each row in bytes to be used for the memory region associated with srcBuffer.
	 *						If srcRowPitch is 0, srcRowPitch is computed as region[0]
	 *		srcSlicePitch=	length of each 2D slice in bytes to be used for the memory region associated with srcBuffer.
	 *						If srcSlicePitch is 0, srcSlicePitch is computed as region[1] * srcRowPitch
	 *
	 *	Returns:
	 *		an event object that identifies this particular copy command and can be used to
	 *		query or queue a wait for this particular command to complete
	 *		The event can be ignored in which case it will not be possible for the application to query the status of this command or queue a
	 *		wait for this command to complete.  clEnqueueBarrier can be used instead
	 */
	CLEvent enqueueCopyBufferRect(CLBuffer srcBuffer, CLBuffer dstBuffer, const size_t[3] srcOrigin, const size_t[3] dstOrigin, const size_t[3] region,
            CLEvents waitlist = null, size_t srcRowPitch = 0, size_t srcSlicePitch = 0, size_t dstRowPitch = 0, size_t dstSlicePitch = 0)
	in
	{
		assert(region[0] != 0u && region[1] != 0u && region[2] != 0u);
		if (srcRowPitch > 0)
			assert(srcRowPitch >= region[0]);
		if (dstRowPitch > 0)
			assert(dstRowPitch >= region[0]);
		if (srcSlicePitch > 0)
			assert(srcSlicePitch >= region[1] * srcRowPitch);
		if (dstSlicePitch > 0)
			assert(dstSlicePitch >= region[1] * dstRowPitch);
	}
	body
	{
		cl_event event;
		cl_int res = clEnqueueCopyBufferRect(_object, srcBuffer.getObject(), dstBuffer.getObject(), srcOrigin.ptr, dstOrigin.ptr, region.ptr, srcRowPitch, srcSlicePitch, dstRowPitch, dstSlicePitch,  waitlist is null ? 0 : waitlist.length,  waitlist is null ? null : waitlist.ptr, &event);
		
		mixin(exceptionHandling(
			["CL_INVALID_COMMAND_QUEUE",		""],
			["CL_INVALID_CONTEXT",				"context associated with command queue, srcBuffer and dstBuffer are not the same or if the context associated with command queue and events in waitlist are not the same"],
			["CL_INVALID_MEM_OBJECT",			""],
			["CL_INVALID_VALUE",				"(src_origin, region) or (dstOrigin, region) require accessing elements outside the srcBuffer and dstBuffer buffer objects respectively"],
			["CL_INVALID_EVENT_WAIT_LIST",		"event objects in waitlist are not valid events"],
			["CL_MISALIGNED_SUB_BUFFER_OFFSET",	"srcBuffer or dstBuffer is a sub-buffer object and offset specified when the sub-buffer object is created is not aligned to CL_DEVICE_MEM_BASE_ADDR_ALIGN value for device associated with queue"],
			["CL_MEM_COPY_OVERLAP",				"srcBuffer and dstBuffer are the same buffer object and the source and destination regions overlap"],
			["CL_MEM_OBJECT_ALLOCATION_FAILURE","there is a failure to allocate memory for data store associated with srcBuffer or dstBuffer"],
			["CL_OUT_OF_RESOURCES",				""],
			["CL_OUT_OF_HOST_MEMORY",			""]
		));
		
		return new CLEvent(event); // TODO: what happens if the return value is ignored in terms of release(event)?
	}
} // of version(CL_VERSION_1_1)

	/**
	 *	enqueues a marker command
	 *
	 *	The marker command is not completed until all commands enqueued before it have completed.
	 *
	 *	Returns:
	 *		an event which can be waited on, i.e. this event can be waited on to ensure that all commands, which have been
	 *		queued before the marker command, have been completed
	 */
	CLEvent enqueueMarker()
	{
		cl_event event;
		cl_int res = clEnqueueMarker(_object, &event);
		
		mixin(exceptionHandling(
			["CL_INVALID_COMMAND_QUEUE",	""],
			["CL_OUT_OF_RESOURCES",			""],
			["CL_OUT_OF_HOST_MEMORY",		""]
		));
		
		return new CLEvent(event);
	}
	
	/**
	 *	enqueues a barrier operation
	 *
	 *	The clEnqueueBarrier command ensures that all queued
	 *	commands in command_queue have finished execution before the next batch of commands can
	 *	begin execution. The clEnqueueBarrier command is a synchronization point
	 */
	void enqueueBarrier()
	{
		cl_int res = clEnqueueBarrier(_object);
		
		mixin(exceptionHandling(
			["CL_INVALID_COMMAND_QUEUE",	""],
			["CL_OUT_OF_RESOURCES",			""],
			["CL_OUT_OF_HOST_MEMORY",		""]
		));
	}
	
	//! are the commands queued in the command queue executed out-of-order
	@property bool outOfOrder()
	{
		return cast(bool) (getInfo!(cl_command_queue_properties)(CL_QUEUE_PROPERTIES) & CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE);
	}
	
	//! is profiling of commands in the command-queue enabled
	@property bool profiling()
	{
		return cast(bool) (getInfo!(cl_command_queue_properties)(CL_QUEUE_PROPERTIES) & CL_QUEUE_PROFILING_ENABLE);
	}
}