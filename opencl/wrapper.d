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

/**
 *	this function is used to mixin low level CL C object handling into all CL classes
 *	namely info retrieval and reference counting methods
 *
 *	It should be a template mixin, but unfortunately those can't add constructors to classes
 */ 
package string CLWrapper(string T, string classInfoFunction)
{
	return "private:\nalias " ~ T ~ " T;\n" ~ 
	"enum TName = \"" ~ T ~ "\";\n" ~ q{
	package T _object;
	//public alias _object this; // TODO any merit?
	package alias T CType; // remember the C type

public:
	//! wrap OpenCL C API object
	//! this doesn't change the reference count
	this(T obj)
	{
		_object = obj;
		debug writef("wrapped %s %X\n", TName, cast(void*) _object);
	}

debug private import std.stdio;

	//! copy and increase reference count
	this(this)
	{
		// increment reference count
		retain();
		debug writef("copied %s %X. Reference count is now: %d\n", TName, cast(void*) _object, referenceCount);
	}

	//! release the object
	~this()
	{
		if (_object is null)
			return;

		debug writef("releasing %s %X. Reference count before: %d\n", TName, cast(void*) _object, referenceCount);
		release();
	}

	//! ensure that _object isn't null
	invariant()
	{
		assert(_object !is null, "invariant violated: _object is null");
	}

package:
	// return the internal OpenCL C object
	// should only be used inside here so reference counting works
	final @property T cptr() const
	{
		return _object;
	}

	//! increments the object reference count
	void retain()
	{
		// HACK: really need a proper system for OpenCL version handling
		version(CL_VERSION_1_2)
			static if (TName == "cl_device_id")
				clRetainDevice(_object);

		// NOTE: cl_platform_id and cl_device_id aren't reference counted
		// TName is compared instead of T itself so it also works with T being an alias
		// platform and device will have an empty retain() so it can be safely used in this()
		static if (TName[$-3..$] != "_id")
		{
			mixin("cl_errcode res = clRetain" ~ toCamelCase(TName[2..$]) ~ (TName == "cl_mem" ? "Object" : "") ~ "(_object);");
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
	void release()
	{
		// HACK: really need a proper system for OpenCL version handling
		version(CL_VERSION_1_2)
			static if (TName == "cl_device_id")
				clReleaseDevice(_object);

		static if (TName[$-3..$] != "_id")
		{
			mixin("cl_errcode res = clRelease" ~ toCamelCase(TName[2..$]) ~ (TName == "cl_mem" ? "Object" : "") ~ "(_object);");
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
	public @property cl_uint referenceCount() const
	{
		static if (TName[$-3..$] != "_id")
		{
			// HACK: not even toUpper works in CTFE anymore as of 2.054 *sigh*
			mixin("return getInfo!cl_uint(CL_" ~ (TName == "cl_command_queue" ? "QUEUE" : (){char[] tmp = TName[3..$].dup; toUpperInPlace(tmp); return tmp;}()) ~ "_REFERENCE_COUNT);");
		}
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
		// TODO: should be in invariant
		assert(_object !is null, "_object is null");
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
		res = infoFunction(_object, infoname, U.sizeof, cast(void*)&info, null);
		
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
	U getInfo2(U, alias altFunction)( cl_device_id device, cl_uint infoname) const
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

		// get amount of needed memory
		res = infoFunction(_object, infoname, 0, null, &needed);

		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);

		// e.g. CL_CONTEXT_PROPERTIES can return needed = 0
		if (needed == 0)
			return null;

		auto buffer = new U[needed/U.sizeof];

		// get actual data
		res = infoFunction(_object, infoname, needed, cast(void*)buffer.ptr, null);
		
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
	U[] getArrayInfo2(U, alias altFunction)(cl_device_id device, cl_uint infoname) const
	{
		assert(_object !is null);
		size_t needed;
		cl_errcode res;

		// get amount of needed memory
		res = altFunction(_object, device, infoname, 0, null, &needed);

		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);

		// e.g. CL_CONTEXT_PROPERTIES can return needed = 0
		if (needed == 0)
			return null;

		auto buffer = new U[needed/U.sizeof];

		// get actual data
		res = altFunction(_object, device, infoname, needed, cast(void*)buffer.ptr, null);
		
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

}; // return q{...}
} // of CLWrapper function

/**
 *	a collection of OpenCL objects returned by some methods
 *	Params:
 *		T = a cl4d object like CLKernel
 */
package struct CLObjectCollection(T)
{
	T[] _objects;
	alias _objects this;

	//! takes a list of cl4d CLObjects
	this(T[] objects...)
	in
	{
		assert(objects !is null);
	}
	body
	{
		// they were already copy-constructed (due to variadic?!)
		_objects = objects;
	}

	//! takes a list of OpenCL C objects returned by some OpenCL functions like GetPlatformIDs
	this(T.CType[] objects)
	in
	{
		assert(objects !is null);
	}
	body
	{
		// we safely reinterpret cast here since T just wraps a T.CType
		_objects = cast(T[]) objects;
	}

	this(this)
	{
		_objects = _objects.dup; // calls postblits :)
	}

	//! release all objects
	~this()
	{
		foreach (object; _objects)
			object.release();
	}

	//!
	package @property auto ptr() const
	{
		return cast(const(T.CType)*) _objects.ptr;
	}
}


version(unittest)
{
	struct CLDummy
	{
		alias uint CType;
		uint referenceCount = 1;

		this(this) {retain();}
		~this() {release();}
		void retain() {++referenceCount;}
		void release() {--referenceCount;}
	}

	alias CLObjectCollection!CLDummy CLDummies;
}

unittest
{
	import std.conv;
	CLDummy a;
	CLDummy b;
	assert(a.referenceCount == 1);

	CLDummies c = CLDummies(a, b);
	foreach (d; c)
		assert(d.referenceCount == 2);

	CLDummy d = c[0];
	assert(d.referenceCount == 3, to!string(d.referenceCount));

	uint[5] s = [1,2,3,4,5];
	CLDummies g = CLDummies(s);
}
