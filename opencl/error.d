/*
cl4d - object-oriented wrapper for the OpenCL C API v1.1 revision 33
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
module opencl.error;

import opencl.c.cl;

class CLException : Exception
{
protected:
	cl_int _errcode;
	
public:
    this(cl_int errcode, string msg = "", CLException next = null)
    {
    	_errcode = errcode;
    	
    	// TODO: mapping
    	switch(errcode)
    	{
    		
    	}
        super(msg, next);
    }

    this(cl_int errcode, string file, size_t line, CLException next = null)
    {
    	_errcode = errcode;
    	
    	super("CLException: ", file, line, next);
    }
    
    /// errcode getter
    cl_int errCode() {return _errcode;}
}

/// an unrecognized OpenCL exception
class CLUnrecognizedException : CLException {this(cl_int errcode) {super(errcode, "unrecognized OpenCL exception occured");}}

/// platform exceptions base class
class CLPlatformException : CLException {this(cl_int errcode, string msg = "") {super(errcode, msg);}}

/// device exceptions base class
class CLDeviceException : CLException {this(cl_int errcode, string msg = "") {super(errcode, msg);}}

/// context exceptions base class
class CLContextException : CLException {this(cl_int errcode, string msg = "") {super(errcode, msg);}}

/// event exceptions base class
class CLEventException : CLException {this(cl_int errcode, string msg = "") {super(errcode, msg);}}

/// program exceptions base class
class CLProgramException : CLException {this(cl_int errcode, string msg = "") {super(errcode, msg);}}

/// buffer exceptions base class
class CLBufferException : CLException {this(cl_int errcode, string msg = "") {super(errcode, msg);}}

/// kernel exceptions base class
class CLKernelException : CLException {this(cl_int errcode, string msg = "") {super(errcode, msg);}}

/// command queue exceptions base class
class CLCommandQueueException : CLException {this(cl_int errcode, string msg = "") {super(errcode, msg);}}

/**
 *	this function generates exception handling code that is used all over the place when calling OpenCL functions
 *	thus it is easy to change global behaviour, e.g. removing exception handling completely in release mode
 *
 *	NOTE that this function expects the return value of the preceding OpenCL function call to be in cl_int res;
 */
package string exceptionHandling(E...)(E es)
{
	string res = `switch(res)
{
	case CL_SUCCESS:
		break;
`;
	
	foreach(e; es)
	{
		res ~= `	case ` ~ e[0] ~ `:
		throw new CL` ~ toCamelCase(e[0][2..$].dup) ~ `Exception("` ~ e[1] ~ `");
		break;
`;
	}
	
	res ~= `	default:
		throw new CLUnrecognizedException(res);
		break;
}`;
	return res;
}

// ======================================================
// Rest of the exception classes is automatically generated

//exception class descriptor
private struct ECD
{
	string name;
	string msg = "";
	string baseclass = "CLException";
}

private import std.string;

// converts an OpenCL error identifier (e.g. "CL_INVALID_VALUE") into a camelcase name for the corresponding exception class
package string toCamelCase(char[] s)
{
	tolowerInPlace(s);
	int i=0, j=0;
	while(i < s.length - 1)
	{
		if(s[i] == '_')
		{
			s[j++] = cast(char) (s[++i] + 'A' - 'a');
		}
		else if(s[i+1] == '_')
		{
			i++;
		}
		else
			s[j++] = s[++i];
	}
	
	return cast(string) s[0 .. j];
}

private string mixinExceptionClasses(E...)(E es)
{
	string res = "";
		
	foreach(e; es)
	{
		//auto words = split(tolower(e.name), "_");
		//for(uint i=0; i<words.length; i++) words[i] = capitalize(words[i]);
		
		
		res ~= `/// 
class CL` ~ toCamelCase(e.name[2..$].dup) ~ `Exception : ` ~ e.baseclass ~ ` {this(string msg = "") {super(` ~ e.name ~ `, ` ~ ((e.msg != "") ? `"` ~ e.msg ~ `" ~ ` : "") ~ `msg);}}
`;

	}
	return res;
}

// change 'mixin(' to 'pragma(msg,' to see the content
mixin(mixinExceptionClasses(
		ECD("CL_INVALID_VALUE"),
		ECD("CL_OUT_OF_HOST_MEMORY",		"allocating resources required by the OpenCL implementation on the host has failed"),
		ECD("CL_INVALID_PLATFORM",			"", "CLPlatformException"),
		ECD("CL_INVALID_DEVICE",			"", "CLDeviceException"),
		ECD("CL_INVALID_DEVICE_TYPE",		"", "CLDeviceException"),
		ECD("CL_DEVICE_NOT_FOUND",			"", "CLDeviceException"),
		ECD("CL_DEVICE_NOT_AVAILABLE",		"", "CLDeviceException"),
		ECD("CL_INVALID_CONTEXT",			"context is not a valid Context", "CLContextException"),
		ECD("CL_INVALID_PROGRAM",			"", "CLProgramException"),
		ECD("CL_INVALID_BINARY",			"", "CLProgramException"),
		ECD("CL_INVALID_BUILD_OPTIONS",		"", "CLProgramException"),
		ECD("CL_INVALID_OPERATION",			"", "CLProgramException"),
		ECD("CL_COMPILER_NOT_AVAILABLE",	"", "CLProgramException"),
		ECD("CL_BUILD_PROGRAM_FAILURE",		"", "CLProgramException"),
		ECD("CL_INVALID_KERNEL",			"", "CLKernelException"),
		ECD("CL_INVALID_PROGRAM_EXECUTABLE","", "CLProgramException"), // TODO: derive from CLKernelException since it occurs in clCreateKernel?
		ECD("CL_INVALID_KERNEL_NAME",		"", "CLKernelException"),
		ECD("CL_INVALID_KERNEL_DEFINITION",	"", "CLKernelException"),
		ECD("CL_INVALID_EVENT",				"",	"CLEventException"),
		
		// command queue exceptions
		ECD("CL_INVALID_COMMAND_QUEUE",			"",	"CLCommandQueueException"),
		ECD("CL_OUT_OF_RESOURCES",				"allocating resources required by the OpenCL implementation on the device has failed", "CLCommandQueueException"),
		ECD("CL_MEM_OBJECT_ALLOCATION_FAILURE", "allocating memory for buffer object has failed", "CLBufferException"),
		ECD("CL_INVALID_QUEUE_PROPERTIES",		"",	"CLCommandQueueException"),
		ECD("CL_INVALID_EVENT_WAIT_LIST",		"",	"CLCommandQueueException"),
		ECD("CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST",	"",	"CLCommandQueueException"),
		ECD("CL_MEM_COPY_OVERLAP",				"", "CLCommandQueueException"),
		
		// memory object errors
		ECD("CL_INVALID_MEM_OBJECT",		"memobj is not a valid memory object", "CLBufferException"),
		ECD("CL_INVALID_BUFFER_SIZE",		"",	"CLBufferException"),
		ECD("CL_INVALID_HOST_PTR",			"",	"CLBufferException"),
		ECD("CL_MISALIGNED_SUB_BUFFER_OFFSET","", "CLBufferException")
));