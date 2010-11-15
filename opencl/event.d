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
import opencl.error;
import opencl.program;
import opencl.wrapper;

//! collection of several devices
// TODO
alias CLObjectCollection!(cl_event) CLEvents;

/**
 *
 */
class CLEvent : CLWrapper!(cl_event, clGetEventInfo)
{
private:
	CLProgram	_program;
	string		_eventName;

public:
	//! 
	this(cl_event event)
	{
		super(event);
	}

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
	@property void status(cl_int executionStatus)
	{
		cl_int res;
		res = clSetUserEventStatus(_object, executionStatus);
		
		mixin(exceptionHandling(
			["CL_INVALID_EVENT",		"this is not a valid user event object"],
			["CL_INVALID_VALUE",		"executionStatus is not CL_COMPLETE or a negative integer value"],
			["CL_INVALID_OPERATION",	"executionStatus for event has already been changed by a previous call to clSetUserEventStatus"],
			["CL_OUT_OF_RESOURCES",		""],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
	}
}