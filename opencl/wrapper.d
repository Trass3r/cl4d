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

//! all CL Objects "inherit" from this one to enable is(T : CLObject)
struct CLObject
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
	package T _object = null;
	//public alias _object this; // TODO any merit?
	//alias CLObject this;
	package alias T CType; // remember the C type

public:
	// don't need a constructor if nothing special
	this(T obj) { _object = obj; }

debug private import std.stdio;

	this(this)
	{
		// increment reference count
		retain();
		debug writef("copied a %s object instance. Reference count is now: %d\n", T.stringof, referenceCount);
	}

	//! release the object
	~this()
	{
		debug writef("%s object destroyed. Reference count before destruction: %d\n", typeid(typeof(this)), referenceCount);
		release();
	}

	//! ensure that _object isn't null
	invariant()
	{
		assert(this._object !is null);
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
		// NOTE: cl_platform_id and cl_device_id don't have reference counting
		// T.stringof is compared instead of T itself so it also works with T being an alias
		// platform and device will have an empty retain() so it can be safely used in this()
		static if (T.stringof[$-3..$] != "_id")
		{
			mixin("cl_errcode res = clRetain" ~ toCamelCase(T.stringof[2..$]) ~ (T.stringof == "cl_mem" ? "Object" : "") ~ "(this._object);");
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
		static if (T.stringof[$-3..$] != "_id")
		{
			mixin("cl_errcode res = clRelease" ~ toCamelCase(T.stringof[2..$]) ~ (T.stringof == "cl_mem" ? "Object" : "") ~ "(this._object);");
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
		static if (T.stringof[$-3..$] != "_id")
		{
			// HACK: not even toUpper works in CTFE anymore as of 2.054 *sigh*
			mixin("return getInfo!cl_uint(CL_" ~ (T.stringof == "cl_command_queue" ? "QUEUE" : (){char[] tmp = T.stringof[3..$].dup; toUpperInPlace(tmp); return tmp;}()) ~ "_REFERENCE_COUNT);");
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
		assert(this._object !is null);
		cl_errcode res;
		
		debug
		{
			size_t needed;

			// get amount of memory necessary
			res = infoFunction(this._object, infoname, 0, null, &needed);
	
			// error checking
			if (res != CL_SUCCESS)
				throw new CLException(res);
			
			assert(needed == U.sizeof);
		}
		
		U info;

		// get actual data
		res = infoFunction(this._object, infoname, U.sizeof, &info, null);
		
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
		assert(this._object !is null);
		cl_errcode res;
		
		debug
		{
			size_t needed;

			// get amount of memory necessary
			res = altFunction(this._object, device, infoname, 0, null, &needed);
	
			// error checking
			if (res != CL_SUCCESS)
				throw new CLException(res);
			
			assert(needed == U.sizeof);
		}
		
		U info;

		// get actual data
		res = altFunction(this._object, device, infoname, U.sizeof, &info, null);
		
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
		assert(this._object !is null);
		size_t needed;
		cl_errcode res;

		// get amount of needed memory
		res = infoFunction(this._object, infoname, 0, null, &needed);

		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);

		// e.g. CL_CONTEXT_PROPERTIES can return needed = 0
		if (needed == 0)
			return null;

		auto buffer = new U[needed/U.sizeof];

		// get actual data
		res = infoFunction(this._object, infoname, needed, cast(void*)buffer.ptr, null);
		
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
		assert(this._object !is null);
		size_t needed;
		cl_errcode res;

		// get amount of needed memory
		res = altFunction(this._object, device, infoname, 0, null, &needed);

		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);

		// e.g. CL_CONTEXT_PROPERTIES can return needed = 0
		if (needed == 0)
			return null;

		auto buffer = new U[needed/U.sizeof];

		// get actual data
		res = altFunction(this._object, device, infoname, needed, cast(void*)buffer.ptr, null);
		
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
 *		T = an OpenCL C object like cl_kernel
 */
package struct CLObjectCollection(T)
// TODO: if (is(T : CLObject))
{
//private:
	T[] _objects;

	static if(is(T == CLPlatform))
		alias cl_platform_id CType;
	else static if(is(T == CLDevice))
		alias cl_device_id CType;
	else static if(is(T == CLKernel))
		alias cl_kernel CType;
	else static if(is(T : CLEvent))
		alias cl_event CType;
	else static if(is(T : CLMemory))
		alias cl_mem CType;
	else
		static assert(0, "object type not supported by CLObjectCollection");

public:
	// TODO: re-enable once bug 6492 is fixed
	//alias _objects this;

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
	// TODO: so these are already allocated and don't need to be dup'ed?!
	// TODO: change CType to T.Ctype and remove the static if crap above, once that is sorted out
	this(CType[] objects)//, bool transferOwnership = true)
	in
	{
		assert(objects !is null);
	}
	body
	{
		// TODO: just .dup if retain() calls are needed
		_objects = cast(T[]) objects;
	}

	this(this)
	{
		_objects = _objects.dup; // calls postblits :)
	}
/* TODO reenable when bug 6473 is fixed
	//! release all objects
	~this()
	{
		foreach (object; _objects)
			object.release();
	}*/

	//!
	package @property auto ptr() const
	{
		return cast(const(CType)*) _objects.ptr;
	}

	//! get number of Objects
	@property size_t length() const
	{
		return _objects.length;
	}

	/// returns a new instance wrapping object i
	T opIndex(size_t i) const
	{
		// increment reference count
		return this._objects[i];
	}

	// TODO: delete this once bug 2781 is fixed
	/// for foreach to work
	int opApply(scope int delegate(ref T) dg)
	{
		int result = 0;
		
		for(uint i=0; i<_objects.length; i++)
		{
			result = dg(this._objects[i]);
			if(result)
				break;
		}
		
		return result;
	}
}
