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
module opencl.error;

import opencl.c.cl;

class CLException : Exception
{
protected:
	cl_errcode _errcode;
	
public:
	this(cl_errcode errcode, string msg = "", CLException next = null)
	{
		_errcode = errcode;
		
		super(msg, next);
	}

	this(cl_errcode errcode, string msg, string file, size_t line, CLException next = null)
	{
		_errcode = errcode;
		
		super(msg, file, line, next);
	}

	/// errcode getter
	@property cl_errcode errcode() const {return _errcode;}
}

version(NO_CL_EXCEPTIONS) {} else
version(BASIC_CL_EXCEPTIONS) {} else
{
import std.conv;

/// an unrecognized OpenCL exception
class CLUnrecognizedException : CLException {this(cl_errcode errcode, string file = "", size_t line = 0) {super(errcode, "unrecognized OpenCL exception occured: " ~ to!string(errcode), file, line);}}

/// platform exceptions base class
class CLPlatformException : CLException {this(cl_errcode errcode, string msg = "", string file = "", size_t line = 0) {super(errcode, msg, file, line);}}

/// device exceptions base class
class CLDeviceException : CLException {this(cl_errcode errcode, string msg = "", string file = "", size_t line = 0) {super(errcode, msg, file, line);}}

/// context exceptions base class
class CLContextException : CLException {this(cl_errcode errcode, string msg = "", string file = "", size_t line = 0) {super(errcode, msg, file, line);}}

/// event exceptions base class
class CLEventException : CLException {this(cl_errcode errcode, string msg = "", string file = "", size_t line = 0) {super(errcode, msg, file, line);}}

/// program exceptions base class
class CLProgramException : CLException {this(cl_errcode errcode, string msg = "", string file = "", size_t line = 0) {super(errcode, msg, file, line);}}

/// buffer exceptions base class
class CLBufferException : CLException {this(cl_errcode errcode, string msg = "", string file = "", size_t line = 0) {super(errcode, msg, file, line);}}

/// kernel exceptions base class
class CLKernelException : CLException {this(cl_errcode errcode, string msg = "", string file = "", size_t line = 0) {super(errcode, msg, file, line);}}

/// command queue exceptions base class
class CLCommandQueueException : CLException {this(cl_errcode errcode, string msg = "", string file = "", size_t line = 0) {super(errcode, msg, file, line);}}

} // of version(!NO_CL_EXCEPTIONS)

/**
 *	this function generates exception handling code that is used all over the place when calling OpenCL functions
 *	thus it is easy to change global behavior, e.g. removing exception handling completely in release mode
 *
 *	NOTE that this function expects the return value of the preceding OpenCL function call to be in cl_errcode res;
 */
package string exceptionHandling(E...)(E es)
{
	version(NO_CL_EXCEPTIONS)
		return "";
	else version(BASIC_CL_EXCEPTIONS)
		return `if (res != CL_SUCCESS) throw new CLException(res, "OpenCL API call failed!", __FILE__, __LINE__);`;
	else
	{
	string res = `switch (res)
{
	case CL_SUCCESS:
		break;
`;
	
	foreach(e; es)
	{
		res ~= `	case ` ~ e[0] ~ `:
		throw new CL` ~ toCamelCase(e[0][2..$]) ~ `Exception("` ~ e[1] ~ `", __FILE__, __LINE__);
`;
	}
	
	res ~= `	default:
		throw new CLUnrecognizedException(res, __FILE__, __LINE__);
}`;
	return res;
	}
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
package string toCamelCase(string input)
{
	char[] s = input.dup;
	toLowerInPlace(s);
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

version(NO_CL_EXCEPTIONS) {} else
version(BASIC_CL_EXCEPTIONS) {} else
{

private string mixinExceptionClasses(E...)(E es)
{
	string res = "";
		
	foreach(e; es)
	{
		//auto words = split(tolower(e.name), "_");
		//for(uint i=0; i<words.length; i++) words[i] = capitalize(words[i]);
		
		
		res ~= `/// 
final class CL` ~ toCamelCase(e.name[2..$]) ~ `Exception : ` ~ e.baseclass ~ ` {this(string msg = "", string file = "", size_t line = 0) {super(` ~ e.name ~ `, ` ~ ((e.msg != "") ? `"` ~ e.msg ~ `" ~ ` : "") ~ `msg, file, line);}}
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
		ECD("CL_INVALID_PROPERTY",			"",	"CLContextException"),
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
		ECD("CL_INVALID_KERNEL_ARGS",		"",	"CLKernelException"),
		ECD("CL_INVALID_WORK_DIMENSION",	"",	"CLKernelException"),
		ECD("CL_INVALID_ARG_INDEX",			"",	"CLKernelException"),
		ECD("CL_INVALID_ARG_VALUE",			"",	"CLKernelException"),
		ECD("CL_INVALID_SAMPLER",			"",	"CLKernelException"),
		ECD("CL_INVALID_ARG_SIZE",			"",	"CLKernelException"),
		ECD("CL_INVALID_EVENT",				"",	"CLEventException"),
		
		// command queue exceptions
		ECD("CL_INVALID_COMMAND_QUEUE",			"",	"CLCommandQueueException"),
		ECD("CL_OUT_OF_RESOURCES",				"allocating resources required by the OpenCL implementation on the device has failed", "CLCommandQueueException"),
		ECD("CL_MEM_OBJECT_ALLOCATION_FAILURE", "allocating memory for buffer object has failed", "CLBufferException"),
		ECD("CL_INVALID_QUEUE_PROPERTIES",		"",	"CLCommandQueueException"),
		ECD("CL_INVALID_EVENT_WAIT_LIST",		"",	"CLCommandQueueException"),
		ECD("CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST",	"",	"CLCommandQueueException"),
		ECD("CL_MEM_COPY_OVERLAP",				"", "CLCommandQueueException"),
		ECD("CL_INVALID_GLOBAL_WORK_SIZE",		"", "CLCommandQueueException"),
		ECD("CL_INVALID_GLOBAL_OFFSET",			"", "CLCommandQueueException"),
		ECD("CL_INVALID_WORK_GROUP_SIZE",		"", "CLCommandQueueException"),
		ECD("CL_INVALID_WORK_ITEM_SIZE",		"", "CLCommandQueueException"),
		ECD("CL_MAP_FAILURE",					"",	"CLCommandQueueException"),
		
		// memory object errors
		ECD("CL_INVALID_MEM_OBJECT",		"memobj is not a valid memory object", "CLBufferException"),
		ECD("CL_INVALID_BUFFER_SIZE",		"",	"CLBufferException"),
		ECD("CL_INVALID_HOST_PTR",			"",	"CLBufferException"),
		ECD("CL_MISALIGNED_SUB_BUFFER_OFFSET","", "CLBufferException"),
		ECD("CL_INVALID_IMAGE_FORMAT_DESCRIPTOR","", "CLBufferException"),
		ECD("CL_INVALID_IMAGE_SIZE",		"",	"CLBufferException"),
		ECD("CL_IMAGE_FORMAT_MISMATCH",		"",	"CLBufferException"),
		ECD("CL_IMAGE_FORMAT_NOT_SUPPORTED","", "CLBufferException"),
		ECD("CL_INVALID_MIP_LEVEL",			"", "CLBufferException"),
		ECD("CL_INVALID_GL_OBJECT",			"", "CLBufferException")
));

} // of version(!NO_CL_EXCEPTIONS)
