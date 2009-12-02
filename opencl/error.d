/**
 * 
 */
module opencl.error;

import opencl.c.opencl;

class CLException : Exception
{
protected:
	cl_int _errcode;
	
public:
    this(cl_int errcode, string msg = "", CLException next = null)
    {
    	_errcode = errcode;
    	
    	// TODO: mapping
    	switch(errcode)
    	{
    		
    	}
        super(msg, next);
    }

    this(cl_int errcode, string file, size_t line, CLException next = null)
    {
    	_errcode = errcode;
    	
    	super("CLException: ", file, line, next);
    }
    
    /// errcode getter
    cl_int errCode() {return _errcode;}
}

/// an unrecognized exception
class CLUnrecognizedException : CLException {this(cl_int errcode) {super(errcode, "unrecognized OpenCL exception occured");}}

/// 
class CLInvalidValueException : CLException {this(string msg = "") {super(CL_INVALID_VALUE, msg);}}

/// 
class CLInvalidPlatformException : CLException {this(string msg = "") {super(CL_INVALID_PLATFORM, msg);}}

/// 
class CLInvalidDeviceException : CLException {this(string msg = "") {super(CL_INVALID_DEVICE, msg);}}

/// 
class CLInvalidDeviceTypeException : CLException {this(string msg = "") {super(CL_INVALID_DEVICE_TYPE, msg);}}

/// 
class CLDeviceNotFoundException : CLException {this(string msg = "") {super(CL_DEVICE_NOT_FOUND, msg);}}

/// 
class CLDeviceNotAvailableException : CLException {this(string msg = "") {super(CL_DEVICE_NOT_AVAILABLE, msg);}}

/// 
class CLOutOfHostMemoryException : CLException {this(string msg = "") {super(CL_OUT_OF_HOST_MEMORY, msg);}}

/// 
class CLInvalidContextException : CLException {this(string msg = "") {super(CL_INVALID_CONTEXT, msg);}}

/// 
class CLInvalidProgramException : CLException {this(string msg = "") {super(CL_INVALID_PROGRAM, msg);}}

/// 
//class Exception : CLException {this(string msg = "") {super(CL_, msg);}}
