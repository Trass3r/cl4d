/**
 * 
 */
module opencl.context;

import opencl.c.opencl;
import opencl.device;
import opencl.error;
import opencl.platform;
import opencl.program;
import opencl.wrapper;

/**
 * context class
 * Contexts are used by the OpenCL runtime for managing objects such as command-queues, memory,
 * program and kernel objects and for executing kernels on one or more devices specified in the context.
 */
class CLContext : CLWrapper!(cl_context, clGetContextInfo)
{
private:
	CLPlatform	_platform;
	CLDevice[]	_devices;

public:
	/// creates an OpenCL context with the given devices
	this(CLDevice[] devices)
	{
		cl_int res;
		
		// TODO: add platform_id verification and
		auto deviceIDs = new cl_device_id[devices.length];
		for(uint i=0; i<devices.length; i++)
			deviceIDs[i] = devices[i].getObject();

		// TODO: user notification function
		_object = clCreateContext(null, deviceIDs.length, deviceIDs.ptr, null, null, &res);
		if(!_object)
			switch(res)
			{
				case CL_INVALID_PLATFORM:
					throw new CLInvalidPlatformException("no valid platform could be selected for context creation");
					break;
				case CL_INVALID_VALUE:
					throw new CLInvalidValueException("devices array has length 0 or a null pointer");
					break;
				case CL_INVALID_DEVICE:
					throw new CLInvalidDeviceException("devices contains an invalid device or are not associated with the specified platform");
					break;
				case CL_DEVICE_NOT_AVAILABLE:
					throw new CLDeviceNotAvailableException("a device is currently not available even though the device was returned by getDevices");
					break;
				case CL_OUT_OF_HOST_MEMORY:
					throw new CLOutOfHostMemoryException("couldn't allocate resources required by the OpenCL implementation on the host");
					break;
				default:
					throw new CLUnrecognizedException(res);
			}
		
		
	}
	
	/// create a context from all available devices
	this()
	{
		cl_int res;
		_object = clCreateContextFromType(null, CL_DEVICE_TYPE_ALL, null, null, &res);
		
		switch(res)
		{
			case CL_SUCCESS:
				break;
			case CL_INVALID_PLATFORM:
				throw new CLInvalidPlatformException("no platform could be selected");
				break;
			case CL_INVALID_VALUE:
				throw new CLInvalidValueException("internal invalid value error");
				break;
			case CL_DEVICE_NOT_AVAILABLE:
				throw new CLDeviceNotAvailableException("no devices currently available");
				break;
			case CL_DEVICE_NOT_FOUND:
				throw new CLDeviceNotFoundException("no devices were found");
				break;
			case CL_OUT_OF_HOST_MEMORY:
				throw new CLOutOfHostMemoryException();
				break;
			default:
				throw new CLUnrecognizedException(res);
		}
	}
	
	~this()
	{
		release();
	}
	
	/// increments the context reference count
	CLContext retain()
	{
		cl_int res;
		res = clRetainContext(_object);
		if(res != CL_SUCCESS)
			throw new CLInvalidContextException("internal context object is not a valid OpenCL context");
		
		return this;
	}
	
	/// decrements the context reference count
	void release()
	{
		cl_int res;
		res = clReleaseContext(_object);
		if(res != CL_SUCCESS)
			throw new CLInvalidContextException("internal context object is not a valid OpenCL context");
	}
	
	CLProgram createProgram(string sourceCode)
	{
		return new CLProgram(this, sourceCode);
	}
}

/**
 * a context using all available GPU devices
 */
class CLGPUContext : CLContext
{
	this()
	{
		cl_int res;
		_object = clCreateContextFromType(null, CL_DEVICE_TYPE_GPU, null, null, &res);
		
		switch(res)
		{
			case CL_SUCCESS:
				break;
			case CL_INVALID_PLATFORM:
				throw new CLInvalidPlatformException("no platform could be selected");
				break;
			case CL_INVALID_VALUE:
				throw new CLInvalidValueException("internal invalid value error");
				break;
			case CL_DEVICE_NOT_AVAILABLE:
				throw new CLDeviceNotAvailableException("no GPU devices currently available");
				break;
			case CL_DEVICE_NOT_FOUND:
				throw new CLDeviceNotFoundException("no GPU devices were found");
				break;
			case CL_OUT_OF_HOST_MEMORY:
				throw new CLOutOfHostMemoryException();
				break;
			default:
				throw new CLUnrecognizedException(res);
		}
	}
}

/**
* a context using all available CPU devices
*/
class CLCPUContext : CLContext
{
	this()
	{
		cl_int res;
		_object = clCreateContextFromType(null, CL_DEVICE_TYPE_CPU, null, null, &res);
		
		switch(res)
		{
			case CL_SUCCESS:
				break;
			case CL_INVALID_PLATFORM:
				throw new CLInvalidPlatformException("no platform could be selected");
				break;
			case CL_INVALID_VALUE:
				throw new CLInvalidValueException("internal invalid value error");
				break;
			case CL_DEVICE_NOT_AVAILABLE:
				throw new CLDeviceNotAvailableException("no CPU devices currently available");
				break;
			case CL_DEVICE_NOT_FOUND:
				throw new CLDeviceNotFoundException("no CPU devices were found");
				break;
			case CL_OUT_OF_HOST_MEMORY:
				throw new CLOutOfHostMemoryException();
				break;
			default:
				throw new CLUnrecognizedException(res);
		}
	}
}

/**
* a context using all available accelerator devices
*/
class CLAccelContext : CLContext
{
	this()
	{
		cl_int res;
		_object = clCreateContextFromType(null, CL_DEVICE_TYPE_ACCELERATOR, null, null, &res);
		
		switch(res)
		{
			case CL_SUCCESS:
				break;
			case CL_INVALID_PLATFORM:
				throw new CLInvalidPlatformException("no platform could be selected");
				break;
			case CL_INVALID_VALUE:
				throw new CLInvalidValueException("internal invalid value error");
				break;
			case CL_DEVICE_NOT_AVAILABLE:
				throw new CLDeviceNotAvailableException("no accelerator devices currently available");
				break;
			case CL_DEVICE_NOT_FOUND:
				throw new CLDeviceNotFoundException("no accelerator devices were found");
				break;
			case CL_OUT_OF_HOST_MEMORY:
				throw new CLOutOfHostMemoryException();
				break;
			default:
				throw new CLUnrecognizedException(res);
		}
	}
}

/**
* a context using all available default devices
*/
class CLDefaultContext : CLContext
{
	this()
	{
		cl_int res;
		_object = clCreateContextFromType(null, CL_DEVICE_TYPE_DEFAULT, null, null, &res);
		
		switch(res)
		{
			case CL_SUCCESS:
				break;
			case CL_INVALID_PLATFORM:
				throw new CLInvalidPlatformException("no platform could be selected");
				break;
			case CL_INVALID_VALUE:
				throw new CLInvalidValueException("internal invalid value error");
				break;
			case CL_DEVICE_NOT_AVAILABLE:
				throw new CLDeviceNotAvailableException("no devices currently available");
				break;
			case CL_DEVICE_NOT_FOUND:
				throw new CLDeviceNotFoundException("no devices were found");
				break;
			case CL_OUT_OF_HOST_MEMORY:
				throw new CLOutOfHostMemoryException();
				break;
			default:
				throw new CLUnrecognizedException(res);
		}
	}
}