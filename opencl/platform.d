/**
 * 
 */
module opencl.platform;

public import opencl.c.opencl;
import opencl.device;
import opencl.error;
import opencl.wrapper;

//! Platform class
class CLPlatform : CLWrapper!(cl_platform_id, clGetPlatformInfo)
{
public:
	/// constructor
	this(cl_platform_id platform)
	{
		_object = platform;
	}
	
	/// get the platform name
	string name()
	{
		 return getStringInfo(CL_PLATFORM_NAME);
	}
	
	/// get platform vendor
	string vendor()
	{
		 return getStringInfo(CL_PLATFORM_VENDOR);
	}

	/// get platform version
	string clversion()
	{
		 return getStringInfo(CL_PLATFORM_VERSION);
	}

	/// get platform profile
	string profile()
	{
		 return getStringInfo(CL_PLATFORM_PROFILE);
	}

	/// get platform extensions
	string extensions()
	{
		 return getStringInfo(CL_PLATFORM_EXTENSIONS);
	}
	
	/// returns a list of all devices available on the platform matching deviceType
	CLDevice[] getDevices(cl_device_type deviceType)
	{
		cl_uint numDevices;
		cl_int res;
		
		// get number of devices
		res = clGetDeviceIDs(_object, deviceType, 0, null, &numDevices);
		switch(res)
		{
			case CL_SUCCESS:
				break;
			case CL_INVALID_PLATFORM:
				throw new CLInvalidPlatformException();
				break;
			case CL_INVALID_DEVICE_TYPE:
				throw new CLInvalidDeviceTypeException("There's no such device type");
				break;
			case CL_DEVICE_NOT_FOUND:
				throw new CLDeviceNotFoundException("Couldn't find an OpenCL device matching the given type");
				break;
			default:
				throw new CLException(res, "unexpected error while getting device count");
		}
			
		// get device IDs
		auto deviceIDs = new cl_device_id[numDevices];
		res = clGetDeviceIDs(_object, deviceType, deviceIDs.length, deviceIDs.ptr, null);
		if(res != CL_SUCCESS)
			throw new CLException(res);
		
		// create CLDevice array
		auto devices = new CLDevice[numDevices];
		for(uint i=0; i<numDevices; i++)
			devices[i] = new CLDevice(this, deviceIDs[i]);
		
		return devices;
	}
	
	/// returns a list of all devices
	CLDevice[] allDevices()	{return getDevices(CL_DEVICE_TYPE_ALL);}
	
	/// returns a list of all CPU devices
	CLDevice[] cpuDevices()	{return getDevices(CL_DEVICE_TYPE_CPU);}
	
	/// returns a list of all GPU devices
	CLDevice[] gpuDevices()	{return getDevices(CL_DEVICE_TYPE_GPU);}
	
	/// returns a list of all accelerator devices
	CLDevice[] accelDevices() {return getDevices(CL_DEVICE_TYPE_ACCELERATOR);}
	
	/// get an array of all available platforms
	static CLPlatform[] getPlatforms()
	{
		cl_uint numPlatforms;
		cl_int res;
		
		// get number of platforms
		res = clGetPlatformIDs(0, null, &numPlatforms);
		if(res != CL_SUCCESS)
			throw new CLInvalidValueException();
			
		// get platform IDs
		auto platformIDs = new cl_platform_id[numPlatforms];
		res = clGetPlatformIDs(platformIDs.length, platformIDs.ptr, null);
		if(res != CL_SUCCESS)
			throw new CLInvalidValueException();
		
		// create CLPlatform array
		auto platforms = new CLPlatform[numPlatforms];
		for(uint i=0; i<numPlatforms; i++)
			platforms[i] = new CLPlatform(platformIDs[i]);
		
		return platforms;
	}
}