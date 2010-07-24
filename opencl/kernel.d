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
module opencl.kernel;

import opencl.c.cl;
import opencl.context;
import opencl.program;
import opencl.wrapper;


/// collection of several devices
alias CLObjectCollection!(cl_kernel) CLKernels;

/**
 *
 */
class CLKernel : CLWrapper!(cl_kernel, clGetKernelInfo)
{
private:
	CLProgram	_program;
	string		_kernelName;

public:
	/**
	 *	create a kernel object
	 *
	 *	Params:
	 *		program		= a program object with a successfully built executable
	 *		kernelName	= a function name in the program declared with the __kernel qualifier
	 */
	this(CLProgram program, string kernelName)
	{
		cl_int res;
	
		// TODO: check kernel name to be zero-terminated

		_program = program;
		_kernelName = kernelName;
		
		// TODO: call super constructor
		_object = clCreateKernel(program.getObject(), kernelName.ptr, &res);
		
		mixin(exceptionHandling(
			["CL_INVALID_PROGRAM",				"program is not a valid program object"],
			["CL_INVALID_PROGRAM_EXECUTABLE",	"there is no successfully built executable for program"],
			["CL_INVALID_KERNEL_NAME",			"kernelName is not found in program"],
			["CL_INVALID_KERNEL_DEFINITION",	"the function definition for __kernel function given by kernelName such as the number of arguments, the argument types are not the same for all devices for which the program executable has been built"],
			["CL_INVALID_VALUE",				"kernelName is NULL"],
			["CL_OUT_OF_HOST_MEMORY",			""]
			));
	}
	
	/// increments the kernel reference count
	void retain()
	{
		if(clRetainKernel(_object) != CL_SUCCESS)
			throw new CLInvalidKernelException();
	}
	
	/**
	 *	decrements the kernel reference count
	 *	The kernel object is deleted once the number of instances that are retained to kernel become zero
	 *	and the kernel object is no longer needed by any enqueued commands that use kernel
	 */
	void release()
	{
		if (clReleaseKernel(_object) != CL_SUCCESS)
			throw new CLInvalidKernelException();
	}
	
@property
{
	/// Return the kernel function name
	string kernelName()
	{
		assert(getStringInfo(CL_KERNEL_FUNCTION_NAME) == _kernelName);
		return _kernelName;
	}
	
	/// Return the number of arguments to kernel
	cl_uint numArgs()
	{
		return getInfo!(cl_uint)(CL_KERNEL_NUM_ARGS);
	}
	
	/**
	 *	Return the kernel reference count
	 *
	 *	The reference count returned should be considered immediately stale. It is unsuitable for general use in 
	 *	applications. This feature is provided for identifying memory leaks
	 *
	 *	TODO: make it protected?, make use of it!
	 */
	cl_uint referenceCount()
	{
		return getInfo!(cl_uint)(CL_KERNEL_REFERENCE_COUNT);
	}
	
	/// Return the program object associated with kernel
	CLProgram program()
	{
		// TODO: get info and assert
		return _program;
	}
	
	/// Return the context associated with kernel
	CLContext context()
	{
		assert("not implemented yet");
	}
}
}