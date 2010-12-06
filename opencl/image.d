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
package:
	this(cl_mem object)
	{
		super(object);
	}
	
	@property
	{
		//!image format descriptor specified when image was created
		auto format()
		{
			return getInfo!(cl_image_format, clGetImageInfo)(CL_IMAGE_FORMAT);
		}
		
		/**
		 *	size of each element of the image memory object given by image. An
		 *	element is made up of n channels. The value of n is given in cl_image_format descriptor.
		 */
		size_t elementSize()
		{
			return getInfo!(size_t, clGetImageInfo)(CL_IMAGE_ELEMENT_SIZE);
		}
		
		//! size in bytes of a row of elements of the image object given by image
		size_t rowPitch()
		{
			return getInfo!(size_t, clGetImageInfo)(CL_IMAGE_ROW_PITCH);
		}

		/**
		 *	size in bytes of a 2D slice for the 3D image object given by image.
		 *
		 *	For a 2D image object this value will be 0.
		 */
		size_t slicePitch()
		{
			return getInfo!(size_t, clGetImageInfo)(CL_IMAGE_SLICE_PITCH);
		}

		//! width in pixels
		size_t width()
		{
			return getInfo!(size_t, clGetImageInfo)(CL_IMAGE_WIDTH);
		}

		//! height in pixels 
		size_t height()
		{
			return getInfo!(size_t, clGetImageInfo)(CL_IMAGE_HEIGHT);
		}

		/**
		 *	depth of the image in pixels
		 *
		 *	For a 2D image object, depth = 0
		 */
		size_t depth()
		{
			return getInfo!(size_t, clGetImageInfo)(CL_IMAGE_DEPTH);
		}
	} // of @property
}

//!
class CLImage2D : CLImage
{
public:
	this(CLContext context, cl_mem_flags flags, ImageFormat format, )
}