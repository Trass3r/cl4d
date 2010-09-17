/*
cl4d - object-oriented wrapper for the OpenCL C API v1.1
written in the D programming language

Copyright (C) 2009-2010 Andreas Hollandt

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/
module opencl.event;

import opencl.c.cl;
import opencl.wrapper;
import opencl.error;

//! collection of several devices
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

	//! 
	void retain()
	{
		cl_int res;
		res = clRetainEvent(_object);
		
		mixin(exceptionHandling(
			["CL_INVALID_EVENT",		"is not a valid event object"],
			["CL_OUT_OF_RESOURCES",		"allocating resources required by the OpenCL implementation on the device has failed"],
			["CL_OUT_OF_HOST_MEMORY",	"allocating resources required by the OpenCL implementation on the host has failed"]
		));
	}
	
	//! 
	void release()
	{
		cl_int res;
		res = clReleaseEvent(_object);
		
		mixin(exceptionHandling(
				["CL_INVALID_EVENT",		"is not a valid event object"],
				["CL_OUT_OF_RESOURCES",		"allocating resources required by the OpenCL implementation on the device has failed"],
				["CL_OUT_OF_HOST_MEMORY",	"allocating resources required by the OpenCL implementation on the host has failed"]
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
			["CL_OUT_OF_RESOURCES",		"allocating resources required by the OpenCL implementation on the device has failed"],
			["CL_OUT_OF_HOST_MEMORY",	"allocating resources required by the OpenCL implementation on the host has failed"]
		));
	}
}