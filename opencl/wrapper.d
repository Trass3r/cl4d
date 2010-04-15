/**
 * 
 */
module opencl.wrapper;

import opencl.error;
import opencl.c.cl;

// alternate Info getter functions
private alias extern(C) cl_int function(const(void)*, const(void*), cl_uint, size_t, void*, size_t*) Func;

/// abstract base class 
abstract class CLWrapper(T, alias infoFunction)
{
protected:
	T _object = null;

	// should only be used inside here
	package T getObject()
	{
		return _object;
	}
	
	// used for all non-array types
	T getInfo(T)(cl_uint infoname, Func altFunction = null, cl_device_id device = null)
	{
		assert(_object !is null);
		size_t needed;
		cl_int res;
		
		// get number of needed memory
		if (altFunction != null && device != null)
			res = altFunction(_object, device, infoname, 0, null, &needed);
		else
			res = infoFunction(_object, infoname, 0, null, &needed);

		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);
		
		assert(needed == T.sizeof); // TODO:
		
		T info;

		// get actual data
		if (altFunction != null && device != null)
			res = altFunction(_object, device, infoname, T.sizeof, &info, null);
		else
			res = infoFunction(_object, infoname, T.sizeof, &info, null);
		
		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);
		
		return info;
	}
	
	// helper function for all OpenCL Get*Info functions
	// used for all array return types
	T[] getArrayInfo(T)(cl_uint infoname, Func altFunction = null, cl_device_id device = null)
	{
		assert(_object !is null);
		size_t needed;
		cl_int res;

		// get number of needed memory
		if (altFunction != null && device != null)
			res = altFunction(_object, device, infoname, 0, null, &needed);
		else
			res = infoFunction(_object, infoname, 0, null, &needed);

		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);
		
		auto buffer = new T[needed];

		// get actual data
		if (altFunction != null && device != null)
			res = altFunction(_object, device, infoname, buffer.length, cast(void*)buffer.ptr, null);
		else
			res = infoFunction(_object, infoname, buffer.length, cast(void*)buffer.ptr, null);
		
		// error checking
		if (res != CL_SUCCESS)
			throw new CLException(res);
		
		return buffer;
	}
	
	string getStringInfo(cl_uint infoname, Func altFunction = null, cl_device_id device = null)
	{
		return cast(string) getArrayInfo!(char)(infoname, altFunction, device);
	}

	//	static cl_int getInfo(Arg0, Arg1)(Arg0 arg0, Arg1)

public:
	this() {}
	this(T obj)
	{
		_object = obj;
	}
}