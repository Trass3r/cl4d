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
module opencl.image;

import opencl.c.cl;
import opencl.context;
import opencl.error;
import opencl.memory;
import opencl.wrapper;

//!
class CLImage : CLMemory
{
	
}


class CLImage2D : CLImage
{
public:
	this(CLContext context, cl_mem_flags flags, ImageFormat format, )
}