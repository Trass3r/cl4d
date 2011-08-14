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
module opencl.event;

import opencl.c.cl;
import opencl.context;
import opencl.error;
import opencl.program;
import opencl.wrapper;

//! Event collection
struct CLEvents
{
	CLObjectCollection!CLEvent sup;
	alias sup this;

/*	//! TODO
	this(cl_event[] objects)
	{
		super(objects);
	}*/

	/**
	 *	waits on the host thread for commands identified by events in this list to complete.
	 *
	 *	A command is considered complete if its execution status is CL_COMPLETE or a negative value.
	 *	This way the events in this list act as synchronization points.
	 */
	void wait()
	{
		cl_errcode res = clWaitForEvents(cast(cl_uint) this.length, this.ptr);

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
 *	Event objects can be used to track the execution status of a command
 *
 *	API calls that enqueue commands to a command-queue create a new event object that is returned in the event argument
 */
struct CLEvent
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
		cl_errcode res = clWaitForEvents(1, &_object);
		
		mixin(exceptionHandling(
			["CL_INVALID_VALUE",		""],
			["CL_INVALID_EVENT",		""],
			["CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST",	"execution status of the event is a negative integer value"],
			["CL_OUT_OF_RESOURCES",		""],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}

	/**
	 *	registers a user callback function for a specific command execution status.
	 *
	 *	The registered callback function will be called when the execution status of command associated with event
	 *	changes to the specified execution status
	 *
	 *	Each call to clSetEventCallback registers the specified user callback function on a callback
	 *	stack associated with event. The order in which the registered user callback functions are called is undefined
	 *
	 *	Params:
	 *		command_exec_callback_type = The command execution callback values for which a callback can be registered are: CL_COMPLETE
	 *		pfn_notify = the function to be registered, will be called asynchronously
	 */
	version(CL_VERSION_1_1)
	void setCallback(cl_command_execution_status command_exec_callback_type, evt_notify_fn pfn_notify, void* userData = null)
	{
		cl_errcode res = clSetEventCallback(this._object, command_exec_callback_type, pfn_notify, userData);
		
		mixin(exceptionHandling(
			["CL_INVALID_EVENT",	""],
			["CL_INVALID_VALUE",	"pfn_notify is null or callback type is not supported"],
			["CL_OUT_OF_RESOURCES",	""],
			["CL_OUT_OF_HOST_MEMORY",""]
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

		//! the execution status of the command identified by this event
		//! negative values are errors, probably of type cl_errcode
		auto status()
		{
			auto res = getInfo!cl_command_execution_status(CL_EVENT_COMMAND_EXECUTION_STATUS);

			// TODO: should this throw an exception?

			return res;
		}

		//! 64-bit value describing the current device time counter in nanoseconds when the command identified by event is enqueued
		cl_ulong profilingCommandQueued()
		{
			cl_ulong timer;
			try
				timer = this.getInfo!(cl_ulong, clGetEventProfilingInfo)(CL_PROFILING_COMMAND_QUEUED);
			catch(CLException e)
			{
				// handle special case that CL_QUEUE_PROFILING_ENABLE is not available or event is not CL_COMPLETE or it is a user event
				if (e.errcode == CL_PROFILING_INFO_NOT_AVAILABLE)
					timer = 0;
				else
					throw e; // rethrow it
			}
			return timer;
		}
		
		//! 64-bit value describing the current device time counter in nanoseconds when the command identified by event that has been enqueued is submitted by the host to the device
		cl_ulong profilingCommandSubmit()
		{
			cl_ulong timer;
			try
				timer = this.getInfo!(cl_ulong, clGetEventProfilingInfo)(CL_PROFILING_COMMAND_SUBMIT);
			catch(CLException e)
			{
				// handle special case that CL_QUEUE_PROFILING_ENABLE is not available or event is not CL_COMPLETE or it is a user event
				if (e.errcode == CL_PROFILING_INFO_NOT_AVAILABLE)
					timer = 0;
				else
					throw e; // rethrow it
			}
			return timer;
		}
		
		//! 64-bit value describing the current device time counter in nanoseconds when the command identified by event starts execution on the device
		cl_ulong profilingCommandStart()
		{
			cl_ulong timer;
			try
				timer = this.getInfo!(cl_ulong, clGetEventProfilingInfo)(CL_PROFILING_COMMAND_START);
			catch(CLException e)
			{
				// handle special case that CL_QUEUE_PROFILING_ENABLE is not available or event is not CL_COMPLETE or it is a user event
				if (e.errcode == CL_PROFILING_INFO_NOT_AVAILABLE)
					timer = 0;
				else
					throw e; // rethrow it
			}
			return timer;
		}
		
		//! 64-bit value describing the current device time counter in nanoseconds when the command identified by event has finished execution on the device
		cl_ulong profilingCommandEnd()
		{
			cl_ulong timer;
			try
				timer = this.getInfo!(cl_ulong, clGetEventProfilingInfo)(CL_PROFILING_COMMAND_END);
			catch(CLException e)
			{
				// handle special case that CL_QUEUE_PROFILING_ENABLE is not available or event is not CL_COMPLETE or it is a user event
				if (e.errcode == CL_PROFILING_INFO_NOT_AVAILABLE)
					timer = 0;
				else
					throw e; // rethrow it
			}
			return timer;
		}		
	} // of @property
}

version(CL_VERSION_1_1)
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
struct CLUserEvent
{
	CLEvent sup;
	alias sup this;

	~this()
	{
		// if the last reference is released and status isn't CL_COMPLETE or an error code
		// this event might block enqueue commands or other events waiting for it
		// TODO: remove 'sup.' once bug 2889 is fixed
		if(this.referenceCount == 1 && cast(cl_int)sup.status <= cast(cl_int)CL_COMPLETE)
			throw new Exception("user event will be destroyed that hasn't been set to CL_COMPLETE or an error");

		// done. release is called by sup's destructor
	}

	//! creates a user event object
	this(CLContext context)
	{
		// call "base constructor"
		cl_errcode res;
		sup = CLEvent(clCreateUserEvent(context.cptr, &res));
		
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
		cl_errcode res = clSetUserEventStatus(this._object, executionStatus);
		
		mixin(exceptionHandling(
			["CL_INVALID_EVENT",		"this is not a valid user event object"],
			["CL_INVALID_VALUE",		"executionStatus is not CL_COMPLETE or a negative integer value"],
			["CL_INVALID_OPERATION",	"executionStatus for event has already been changed by a previous call to clSetUserEventStatus"],
			["CL_OUT_OF_RESOURCES",		""],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}
}
