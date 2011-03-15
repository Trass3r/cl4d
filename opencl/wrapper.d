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
module opencl.wrapper;

import opencl.error;
import opencl.c.cl;
import opencl.kernel;
import opencl.memory;
import opencl.platform;
import opencl.device;
import opencl.event;

import std.array;

package
{
	alias const(char) cchar; //!
	alias const(wchar) cwchar; //!
	alias const(dchar) cdchar; //!
	alias immutable(char) ichar; //!
	alias immutable(wchar) iwchar; //!
	alias immutable(dchar) idchar; //!
	alias const(char)[] cstring; //!
}

//! all CL Classes inherit from this one to enable is(T : CLObject)
abstract class CLObject
{
}

/**
 *	this function is used to mixin low level CL C object handling into all CL classes
 *	namely info retrieval and reference counting methods
 *
 *	It should be a template mixin, but unfortunately those can't add constructors to classes
 */ 
package string CLWrapper(string T, string classInfoFunction)
{
	return "private:\nalias " ~ T ~ " T;\n" ~ q{
protected:
	T _object = null;

package:
	this() {}

private import std.stdio;
	/**
	 *	create a wrapper around a CL Object
	 *
	 *	Params:
	 *	    increment = increase the object's reference count, necessary e.g. in CLCollection
	 */
	this(T obj, bool increment = false)
	in
	{
		assert(obj !is null, "the " ~ T.stringof ~ " object to be wrapped is null!");
	}
	body
	{
		_object = obj;

		// increment reference count
		if (increment)
			retain();
		
		debug writefln("wrapped a %s object instance. Reference count is now: %d", T.stringof, referenceCount);
	}

	//! release the object
	~this()
	{
		debug writefln("%s object destroyed. Reference count before destruction: %d", typeid(typeof(this)), referenceCount);
		release();
	}

	// return the internal OpenCL C object
	// should only be used inside here so reference counting works
	final package @property T cptr() const
	{
		return _object;
	}
	
/+
	//! ensure that _object isn't null
	invariant()
	{
		assert(_object !is null);
	}
+/
public:
	//! increments the object reference count
	final void retain()
	{
		// NOTE: cl_platform_id and cl_device_id don't have reference counting
		// T.stringof is compared instead of T itself so it also works with T being an alias
		// platform and device will have an empty retain() so it can be safely used in this()
		static if (T.stringof[$-3..$] != "_id")
		{
			mixin("cl_errcode res = clRetain" ~ toCamelCase(T.stringof[2..$].dup) ~ (T.stringof == "cl_mem" ? "Object" : "") ~ "(_object);");
			mixin(exceptionHandling(
				["CL_OUT_OF_RESOURCES",		""],
				["CL_OUT_OF_HOST_MEMORY",	""]
			));
		}
	}
	
	/**
	 *	decrements the context reference count
	 *	The object is deleted once the number of instances that are retained to it become zero
	 */
	final void release()
	{
		static if (T.stringof[$-3..$] != "_id")
		{
			mixin("cl_errcode res = clRelease" ~ toCamelCase(T.stringof[2..$].dup) ~ (T.stringof == "cl_mem" ? "Object" : "") ~ "(_object);");
			mixin(exceptionHandling(
				["CL_OUT_OF_RESOURCES",		""],
				["CL_OUT_OF_HOST_MEMORY",	""]
			));
		}
	}
	private import std.string;
	/**
	 *	Return the reference count
	 *
	 *	The reference count returned should be considered immediately stale. It is unsuitable for general use in 
	 *	applications. This feature is provided for identifying memory leaks
	 */
	final @property cl_uint referenceCount() const
	{
		static if (T.stringof[$-3..$] != "_id")
			mixin("return getInfo!cl_uint(CL_" ~ (T.stringof == "cl_command_queue" ? "QUEUE" : toupper(T.stringof[3..$])) ~ "_REFERENCE_COUNT);");
		else
			return 0;
	}

protected:
	/**
	 *	a wrapper around OpenCL's tedious clGet*Info info retrieval system
	 *	this version is used for all non-array types
	 *
	 *	USE WITH CAUTION!
	 *
	 *	Params:
	 *		U				= the return type of the information to be queried
	 *		infoFunction	= optionally specify a special info function to be used
	 *		infoname		= information op-code
	 *
	 *	Returns:
	 *		queried information
	 */
	// TODO: make infoname type-safe, not cl_uint (can vary for certain _object, see cl_mem)
	final U getInfo(U, alias infoFunction = }~classInfoFunction~q{)(cl_uint infoname) const
	{
		assert(_object !is null);
		cl_errcode res;
		
		debug
		{
			size_t needed;

			// get amount of memory necessary
			res = infoFunction(_object, infoname, 0, null, &needed);
	
			// error checking
			if (res != CL_SUCCESS)
				throw new CLException(res);
			
			assert(needed == U.sizeof);
		}
		
		U info;

		// get actual data
		res = infoFunction(_object, infoname, U.sizeof, &info, null);
		
		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);
		
		return info;
	}
	
	/**
	 *	this special version is only used for clGetProgramBuildInfo and clGetKernelWorkgroupInfo
	 *
	 *	See_Also:
	 *		getInfo
	 */
	final U getInfo2(U, alias altFunction)( cl_device_id device, cl_uint infoname) const
	{
		assert(_object !is null);
		cl_errcode res;
		
		debug
		{
			size_t needed;

			// get amount of memory necessary
			res = altFunction(_object, device, infoname, 0, null, &needed);
	
			// error checking
			if (res != CL_SUCCESS)
				throw new CLException(res);
			
			assert(needed == U.sizeof);
		}
		
		U info;

		// get actual data
		res = altFunction(_object, device, infoname, U.sizeof, &info, null);
		
		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);
		
		return info;
	}

	/**
	 *	this version is used for all array return types
	 *
	 *	Params:
	 *		U	= array element type
	 *
	 *	See_Also:
	 *		getInfo
	 */
	// helper function for all OpenCL Get*Info functions
	// used for all array return types
	final U[] getArrayInfo(U, alias infoFunction = }~classInfoFunction~q{)(cl_uint infoname) const
	{
		assert(_object !is null);
		size_t needed;
		cl_errcode res;

		// get number of needed memory
		res = infoFunction(_object, infoname, 0, null, &needed);

		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);

		// e.g. CL_CONTEXT_PROPERTIES can return needed = 0
		if (needed == 0)
			return null;

		auto buffer = new U[needed/U.sizeof];

		// get actual data
		res = infoFunction(_object, infoname, buffer.sizeof, cast(void*)buffer.ptr, null);
		
		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);
		
		return buffer;
	}
	
	/**
	 *	special version only used for clGetProgramBuildInfo and clGetKernelWorkgroupInfo
	 *
	 *	See_Also:
	 *		getArrayInfo
	 */
	final U[] getArrayInfo2(U, alias altFunction)(cl_device_id device, cl_uint infoname) const
	{
		assert(_object !is null);
		size_t needed;
		cl_errcode res;

		// get number of needed memory
		res = altFunction(_object, device, infoname, 0, null, &needed);

		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);

		// e.g. CL_CONTEXT_PROPERTIES can return needed = 0
		if (needed == 0)
			return null;

		auto buffer = new U[needed/U.sizeof];

		// get actual data
		res = altFunction(_object, device, infoname, buffer.sizeof, cast(void*)buffer.ptr, null);
		
		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);
		
		return buffer;
	}

	/**
	 *	convenience shortcut
	 *
	 *	See_Also:
	 *		getArrayInfo
	 */
	final string getStringInfo(alias infoFunction = }~classInfoFunction~q{)(cl_uint infoname) const
	{
		return cast(string) getArrayInfo!(ichar, infoFunction)(infoname);
	}

};//.replace("classInfoFunction", classInfoFunction); // return q{...}.replace(...)
} // of CLWrapper function

/**
 *	a collection of OpenCL objects returned by some methods
 *	Params:
 *		T = an OpenCL C object like cl_kernel
 */
class CLObjectCollection(T)
{
protected:
	T[] _objects;

	static if(is(T == cl_platform_id))
		alias CLPlatform Wrapper;
	else static if(is(T == cl_device_id))
		alias CLDevice Wrapper;
	else static if(is(T == cl_kernel))
		alias CLKernel Wrapper;
	else static if(is(T == cl_event))
		alias CLEvent Wrapper;
	else static if(is(T == cl_mem))
		alias CLMemory Wrapper;
	else
		static assert(0, "object type not supported by CLObjectCollection");

public:
	//! takes a list of cl4d CLObjects
	this(Wrapper[] clObjects, bool increment = true)
	in
	{
		assert(clObjects !is null);
	}
	body
	{
		T[] tmp = new T[clObjects.length];
		foreach(i, obj; clObjects)
			tmp[i] = obj.cptr;

		this(tmp, increment);
	}

	//! takes a list of OpenCL C objects returned by some OpenCL functions like GetPlatformIDs
	this(T[] objects, bool increment = false)
	in
	{
		assert(objects !is null);
	}
	body
	{
		_objects = objects.dup;
		
		if (increment)
		for(uint i=0; i<objects.length; i++)
		{
			// increment the reference counter so the objects won't be destroyed
			// TODO: is there a better way than replicating the retain/release code from above?
			static if (T.stringof[$-3..$] != "_id")
			{
				mixin("cl_errcode res = clRetain" ~ toCamelCase(T.stringof[2..$].dup) ~ (T.stringof == "cl_mem" ? "Object" : "") ~ "(objects[i]);");
				mixin(exceptionHandling(
					["CL_OUT_OF_RESOURCES",		""],
					["CL_OUT_OF_HOST_MEMORY",	""]
				));
			}
		}
	}
	
	//! release all objects
	~this()
	{
		for(uint i=0; i<_objects.length; i++)
		{
			// release all held objects
			static if (T.stringof[$-3..$] != "_id")
			{
				mixin("cl_errcode res = clRelease" ~ toCamelCase(T.stringof[2..$].dup) ~ (T.stringof == "cl_mem" ? "Object" : "") ~ "(_objects[i]);");
				mixin(exceptionHandling(
					["CL_OUT_OF_RESOURCES",		""],
					["CL_OUT_OF_HOST_MEMORY",	""]
				));
			}
		}
	}

	/// used to internally get the underlying object pointers
	package T[] getObjArray()
	{
		return _objects;
	}

	//!
	package @property const(T)* ptr() const
	{
		return _objects.ptr;
	}

	//! get number of Objects
	@property size_t length() const
	{
		return _objects.length;
	}

	/// returns a new instance wrapping object i
	Wrapper opIndex(size_t i) const
	in
	{
		assert(i < _objects.length, "index out of bounds");
	}
	body
	{
		// increment reference count
		return new Wrapper(_objects[i], true);
	}

	/// for foreach to work
	int opApply(scope int delegate(ref Wrapper) dg)
	{
		int result = 0;
		
		for(uint i=0; i<_objects.length; i++)
		{
			Wrapper w = new Wrapper(_objects[i], true);
			result = dg(w);
			if(result)
				break;
		}
		
		return result;
	}
}