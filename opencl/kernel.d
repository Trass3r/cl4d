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
module opencl.kernel;

import opencl.c.cl;
import opencl.context;
import opencl.device;
import opencl.error;
import opencl.program;
import opencl.wrapper;

import std.string : toStringz;

//! NDRange struct
// TODO: more dimensions needed? => CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS
struct NDRange
{
	size_t[3] sizes;

	//!
	this(size_t x, size_t y = 0, size_t z = 0)
	{
		sizes[0] = x;
		sizes[1] = y;
		sizes[2] = z;
	}

	//! returns a pointer to the sizes array
	@property const ptr()
	{
		// TODO: any better way to make a NullRange return null?
		if (dimensions == 0)
			return cast(const(size_t)*) null;
		else
			return &sizes[0];
	}
	
	//! returns number of work dimensions
	@property cl_uint dimensions() const
	{
		return sizes[2] != 0 ? 3 : (sizes[1] != 0 ? 2 : (sizes[0] != 0 ? 1 : 0));
	}
}

//! null for NDRange
__gshared immutable NullRange = NDRange();

//! collection of several devices
alias CLObjectCollection!(cl_kernel) CLKernels;

/**
 *	Kernel objects can only be created once you have a program object with a valid program source
 *	or binary loaded into the program object and the program executable has been successfully built
 *	for one or more devices associated with program.  No changes to the program executable are
 *	allowed while there are kernel objects associated with a program object.
 */
class CLKernel
{
	mixin(CLWrapper("cl_kernel", "clGetKernelInfo"));

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

		_program = program;
		_kernelName = kernelName;
		
		_object = clCreateKernel(program.getObject(), toStringz(kernelName), &res);
		
		mixin(exceptionHandling(
			["CL_INVALID_PROGRAM",				"program is not a valid program object"],
			["CL_INVALID_PROGRAM_EXECUTABLE",	"there is no successfully built executable for program"],
			["CL_INVALID_KERNEL_NAME",			"kernelName is not found in program"],
			["CL_INVALID_KERNEL_DEFINITION",	"the function definition for __kernel function given by kernelName such as the number of arguments, the argument types are not the same for all devices for which the program executable has been built"],
			["CL_INVALID_VALUE",				"kernelName is NULL"],
			["CL_OUT_OF_RESOURCES",				""],
			["CL_OUT_OF_HOST_MEMORY",			""]
			));
	}
	
	/**
	 *	A shorthand function for setting all the arguments for a kernel
	 */
	void setArgs(ArgTypes...)(ArgTypes args)
	in
	{
		assert(args.length == numArgs);
	}
	body
	{
		foreach(idx, arg; args)
			setArg(idx, arg.sizeof, &arg);
	}
	
	/**
	 *	set the argument value for a specific argument of a kernel
	 *
	 *	Params:
	 *		idx	=	indices go from 0 for the leftmost argument to n - 1
	 *		value=	TODO: go through specs pp. 127f
	 */
	void setArg(cl_uint idx, size_t size, const void* value)
	{
		// clSetKernelArg is safe to call from any host thread, and is safe to call re-entrantly so long as concurrent calls operate on different cl_kernel objects
		// the behavior of the cl_kernel object is undefined if clSetKernelArg is called from multiple host threads on the same cl_kernel object at the same time
		// TODO: thus, if multiple CLKernel objects wrap the same cl_kernel one, this still makes problems
		cl_int res = void;
		synchronized(this) res = clSetKernelArg(_object, idx, size, value);
		
		mixin(exceptionHandling(
			["CL_INVALID_KERNEL",		""],
			["CL_INVALID_ARG_INDEX",	""],
			["CL_INVALID_ARG_VALUE",	""],
			["CL_INVALID_MEM_OBJECT",	"argument declared to be a memory object when the specified value is not a valid memory object"],
			["CL_INVALID_SAMPLER",		"argument declared to be of type sampler_t when the specified arg_value is not a valid sampler object"],
			["CL_INVALID_ARG_SIZE",		"arg_size does not match the size of the data type for an argument that is not a memory object or if the argument is a memory object and arg_size != cl_mem.sizeof or if arg_size is zero and the argument is declared with the __local qualifier or if the argument is a sampler and arg_size != cl_sampler.sizeof"],
			["CL_OUT_OF_RESOURCES",		""],
			["CL_OUT_OF_HOST_MEMORY",	""]
		));
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
		
		/// Return the context associated with kernel
		CLContext context()
		{
			assert(0, "not implemented yet");
			return new CLContext(getInfo!(cl_context)(CL_KERNEL_CONTEXT));
		}
		
		//! Return the program object associated with kernel
		CLProgram program()
		{
			// TODO: return new CLProgram(getInfo!(cl_program)(CL_KERNEL_PROGRAM));
			return _program;
		}

		/**
		 *	This provides a mechanism for the application to query the maximum
		 *	work-group size that can be used to execute a kernel on a specific device
		 *	given by device. The OpenCL implementation uses the resource requirements of the kernel (register
		 *	usage etc.) to determine what this workgroup size should be.
		 */
		size_t workGroupSize(CLDevice device)
		{
			return getInfo2!(size_t, clGetKernelWorkGroupInfo)(device.getObject(), CL_KERNEL_WORK_GROUP_SIZE);
		}
		
		/**
		 *	Returns the work-group size specified by the __attribute__((reqd_work_group_size(X, Y, Z))) qualifier.
		 *	Refer to section 6.8.2.
		 *	If the work-group size is not specified using the above attribute qualifier (0, 0, 0) is returned
		 */
		size_t[3] compileWorkGroupSize(CLDevice device)
		{
			// TODO: check if this works
			return getInfo2!(size_t[3], clGetKernelWorkGroupInfo)(device.getObject(), CL_KERNEL_COMPILE_WORK_GROUP_SIZE);
		}
		
		/**
		 *	Returns the amount of local memory in bytes being used by a kernel. This includes local memory that may be
		 *	needed by an implementation to execute the kernel, variables declared inside the kernel with the __local address
		 *	qualifier and local memory to be allocated for arguments to the kernel declared as pointers with the __local
		 *	address qualifier and whose size is specified with clSetKernelArg. If the local memory size, for any pointer
		 *	argument to the kernel declared with the __local address qualifier, is not specified, its size is assumed to be 0.
		 */
		cl_ulong localMemSize(CLDevice device)
		{
			return getInfo2!(cl_ulong, clGetKernelWorkGroupInfo)(device.getObject(), CL_KERNEL_LOCAL_MEM_SIZE);
		}
		
		/**
		 *	Returns the preferred multiple of workgroup size for launch. This is a performance hint. Specifying a workgroup
		 *	size that is not a multiple of the value returned by this query as the value of the local work size argument to
		 *	clEnqueueNDRangeKernel will not fail to enqueue the kernel for execution unless the work-group size specified is
		 *	larger than the device maximum.
		 */
		size_t preferredWorkGroupSizeMultiple(CLDevice device)
		{
			return getInfo2!(size_t, clGetKernelWorkGroupInfo)(device.getObject(), CL_KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE);
		}
		
		/**
		 *	Returns the minimum amount of private memory, in bytes, used by each workitem in the kernel. This value may
		 *	include any private memory needed by an implementation to execute the kernel, including that used by the language
		 *	built-ins and variable declared inside the kernel with the __private qualifier.
		 */
		cl_ulong privateMemSize(CLDevice device)
		{
			return getInfo2!(cl_ulong, clGetKernelWorkGroupInfo)(device.getObject(), CL_KERNEL_PRIVATE_MEM_SIZE);
		}
	} // of @property
}