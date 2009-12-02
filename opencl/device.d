/**
 * 
 */
module opencl.device;

import opencl.c.opencl;
import opencl.platform;
import opencl.wrapper;

/// device class
class CLDevice : CLWrapper!(cl_device_id, clGetDeviceInfo)
{
private:
	CLPlatform _platform;

public:
	///
	this(CLPlatform platform, cl_device_id device)
	{
		super(device);
		_platform = platform;
	}
	
	/// get the associated platform
	CLPlatform platform() {return _platform;} // TODO: maybe check with GetDeviceInfo if IDs match
	
	/// get device name
	string name() {return getStringInfo(CL_DEVICE_NAME);}
	
	/// get device vendor
	string vendor() {return getStringInfo(CL_DEVICE_VENDOR);}
	
	/// get device OpenCL driver version in the form major_number.minor_number
	string driverVersion() {return getStringInfo(CL_DRIVER_VERSION);}
	
	/**
	 * get OpenCL profile string
	 * 
	 * Returns the profile name supported by the device. 
	 * The profile name returned can be one of the following strings:
	 *		FULL_PROFILE - if the device supports the OpenCL specification
	 *		(functionality defined as part of the core specification and does not require 
	 *		any extensions to be supported). 
	 * 
	 *		EMBEDDED_PROFILE - if the device supports the OpenCL embedded profile.
	 */
	string profile() {return getStringInfo(CL_DEVICE_PROFILE);}
	
	/**
	 * get OpenCL version string
	 * 
	 * Returns:
	 *		OpenCL version supported by the device.
	 *		This version string has the following format: 
 	 *		OpenCL<space><major_version.minor_version><space><vendor-specific information>
	 */
	string clVersion() {return getStringInfo(CL_DEVICE_VERSION);}
	
	/**
	 * get extensions supported by the device
	 * 
	 * Returns:
	 *		Returns a space separated list of extension names
	 *		(the extension names themselves do not contain any spaces).  
	 */
	string extensions() {return getStringInfo(CL_DEVICE_EXTENSIONS);}
	
	
}