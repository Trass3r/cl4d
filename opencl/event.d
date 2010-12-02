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
module opencl.event;

import opencl.c.cl;
import opencl.context;
import opencl.error;
import opencl.program;
import opencl.wrapper;

//! Event collection
class CLEvents : CLObjectCollection!(cl_event)
{
public:

	//!
	this(cl_event[] objects)
	{
		super(objects);
	}

	/**
	 *	waits on the host thread for commands identified by events in this list to complete.
	 *
	 *	A command is considered complete if its execution status is CL_COMPLETE or a negative value.
	 *	This way the events in this list act as synchronization points.
	 */
	void wait()
	{
		cl_int res = clWaitForEvents(_objects.length, _objects.ptr);

		mixin(exceptionHandling(
			["CL_INVALID_VALUE",		"event _objects is null"],
			["CL_INVALID_CONTEXT",		"the events in this list do not belong to the same context"],
			["CL_INVALID_EVENT",		""],
			["CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST",	"execution status of any of the events is a negative integer value"],
			["CL_OUT_OF_RESOURCES",		""],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}
}

/**
 *
 */
class CLEvent
{
	mixin(CLWrapper("cl_event", "clGetEventInfo"));

public:
	/**
	 *	waits on the host thread for commands identified by event to complete.
	 *
	 *	A command is considered complete if its execution status is CL_COMPLETE or a negative value.
	 *	This way the event acts as a synchronization point.
	 */
	void wait() const
	{
		cl_int res = clWaitForEvents(1, &_object);
		
		mixin(exceptionHandling(
			["CL_INVALID_VALUE",		""],
			["CL_INVALID_EVENT",		""],
			["CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST",	"execution status of the event is a negative integer value"],
			["CL_OUT_OF_RESOURCES",		""],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}
	
	@property
	{
		/**
		 *	the command-queue associated with event
		 *
		 *	For user event objects, a null value is returned
		 */
		auto commandQueue()
		{
			return getInfo!cl_command_queue(CL_EVENT_COMMAND_QUEUE);
		}
		
		//! the context associated with event
		auto context()
		{
			return getInfo!cl_context(CL_EVENT_CONTEXT);
		}

		//! the command associated with event
		auto commandType()
		{
			return getInfo!cl_command_type(CL_EVENT_COMMAND_TYPE);
		}

		//! the execution status of the command identified by event
		auto status()
		{
			auto res = getInfo!cl_command_execution_status(CL_EVENT_COMMAND_EXECUTION_STATUS);
			
			if (res < 0)
				throw new CLException(res, "error occured while retrieving event execution status");
			
			return res;
		}
	} // of @property
}

/**
 *	User event class
 *
 *	allows applications to enqueue commands that wait on a user event to finish before the command is executed by the device
 *
 *	NOTE: Enqueued commands that specify user events in the waitlist argument of
 *	enqueue*** commands must ensure that the status of these user events being waited on are set
 *	using the status property before any OpenCL APIs that release OpenCL objects except for
 *	event objects are called; otherwise the behavior is undefined.
 */
class CLUserEvent : CLEvent
{
public:
	//! creates a user event object
	this(CLContext context)
	{
		cl_int res;
		_object = clCreateUserEvent(context.getObject(), &res);
		
		mixin(exceptionHandling(
			["CL_INVALID_CONTEXT",	""],
			["CL_OUT_OF_RESOURCES",	""],
			["CL_OUT_OF_HOST_MEMORY",""]
		));
	}

	/**
	 *	sets the execution status of a user event object
	 *
	 *	Params:
	 *		executionStatus = specifies the new execution status to be set and can be CL_COMPLETE or a
	 *		negative integer value to indicate an error.  A negative integer value causes all enqueued
	 *		commands that wait on this user event to be terminated.
	 *
	 *	clSetUserEventStatus can only be called once to change the execution status of event
	 */
	@property void status(cl_command_execution_status executionStatus)
	{
		cl_int res = clSetUserEventStatus(_object, executionStatus);
		
		mixin(exceptionHandling(
			["CL_INVALID_EVENT",		"this is not a valid user event object"],
			["CL_INVALID_VALUE",		"executionStatus is not CL_COMPLETE or a negative integer value"],
			["CL_INVALID_OPERATION",	"executionStatus for event has already been changed by a previous call to clSetUserEventStatus"],
			["CL_OUT_OF_RESOURCES",		""],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}
}