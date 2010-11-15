/**
 *	cl4d - object-oriented wrapper for the OpenCL C API
 *	written in the D programming language
 *
 *	Copyright:
 *		(c) 2008-2010 The Khronos Group Inc. (original C headers)
 *		(c) 2009-2010 Andreas Hollandt
 *
 *	License:
 *		see LICENSE.txt
 */

/* $Revision: 11708 $ on $Date: 2010-06-13 23:36:24 -0700 (Sun, 13 Jun 2010) $ */

/**
 *	cl_gl_ext.h contains vendor (non-KHR) OpenCL extensions which have OpenGL dependencies.
 */
module opencl.c.cl_gl_ext;

import opencl.c.cl;
import opencl.c.cl_gl;

extern(System):

/+
 * For each extension, follow this template
 * /* cl_VEN_extname extension  */
 * #define cl_VEN_extname 1
 * ... define new types, if any
 * ... define new tokens, if any
 * ... define new APIs, if any
 *
 *  If you need GLtypes here, mirror them with a cl_GLtype, rather than including a GL header
 *  This allows us to avoid having to decide whether to include GL headers or GLES here.
 +/
	
/* 
 *  cl_khr_gl_event  extension
 *  See section 9.9 in the OpenCL 1.1 spec for more information
 */
enum CL_COMMAND_GL_FENCE_SYNC_OBJECT_KHR = 0x200D;

cl_event clCreateEventFromGLsyncKHR(cl_context context,
									cl_GLsync cl_GLsync,
									cl_int* errcode_ret);