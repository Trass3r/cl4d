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
module opencl.host;

import opencl.c.cl;
import opencl.error;
import opencl.platform;

///
struct CLHost
{
	/// get an array of all available platforms
	static CLPlatforms getPlatforms()
	{
		cl_uint numPlatforms;
		cl_errcode res;

		// get number of platforms
		res = clGetPlatformIDs(0, null, &numPlatforms);

		version(NO_CL_EXCEPTIONS) {} else
		if(res != CL_SUCCESS)
			throw new CLException(res, "couldn't retrieve number of platforms", __FILE__, __LINE__);

		// get platform IDs
		auto platformIDs = new cl_platform_id[numPlatforms];
		res = clGetPlatformIDs(cast(cl_uint) platformIDs.length, platformIDs.ptr, null);

		version(NO_CL_EXCEPTIONS) {} else
		if(res != CL_SUCCESS)
			throw new CLException(res, "couldn't get platform list", __FILE__, __LINE__);

		return CLPlatforms(platformIDs);
	}

	version(CL_VERSION_1_2) {} else
	/**
	 * allows the implementation to release the resources allocated by the OpenCL compiler.  This is a
	 * hint from the application and does not guarantee that the compiler will not be used in the future
	 * or that the compiler will actually be unloaded by the implementation.  Calls to clBuildProgram
	 * after clUnloadCompiler will reload the compiler, if necessary, to build the appropriate program executable.
	 */
	static void unloadCompiler()
	{
		cl_errcode res = void;
		res = clUnloadCompiler();
		if(res != CL_SUCCESS)
			throw new CLException(res, "failed unloading compiler, this shouldn't happen in OpenCL 1.0");
	}
}
