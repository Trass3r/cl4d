/**********************************************************************************
 * Copyright (c) 2008-2010 The Khronos Group Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and/or associated documentation files (the
 * "Materials"), to deal in the Materials without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Materials, and to
 * permit persons to whom the Materials are furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Materials.
 *
 * THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * MATERIALS OR THE USE OR OTHER DEALINGS IN THE MATERIALS.
 **********************************************************************************/

// $Revision: 11708 $ on $Date: 2010-06-13 23:36:24 -0700 (Sun, 13 Jun 2010) $

module opencl.c.cl_platform;

// calling conventions are extern(System) now
// TODO: on MacOSX API calls are __attribute__((weak_import))

// scalar types
alias byte		cl_char;
alias ubyte		cl_uchar;
alias short		cl_short;
alias ushort	cl_ushort;
alias int		cl_int;
alias uint		cl_uint;
alias long		cl_long;
alias ulong		cl_ulong;

alias ushort	cl_half;
alias float		cl_float;
alias double	cl_double;

/+
// Macro names and corresponding values defined by OpenCL
enum
{
	CL_CHAR_BIT			= 8,
	CL_SCHAR_MAX		= 127,
	CL_SCHAR_MIN		= (-127-1),
	CL_CHAR_MAX			= CL_SCHAR_MAX,
	CL_CHAR_MIN			= CL_SCHAR_MIN,
	CL_UCHAR_MAX		= 255,
	CL_SHRT_MAX			= 32767,
	CL_SHRT_MIN			= (-32767-1),
	CL_USHRT_MAX		= 65535,
	CL_INT_MAX			= 2147483647,
	CL_INT_MIN			= (-2147483647-1),
	CL_UINT_MAX			= 0xffffffffU,
	CL_LONG_MAX			= (cast(cl_long) 0x7FFFFFFFFFFFFFFFLL),
	CL_LONG_MIN			= (cast(cl_long) -0x7FFFFFFFFFFFFFFFLL - 1LL),
	CL_ULONG_MAX		= (cast(cl_ulong) 0xFFFFFFFFFFFFFFFFULL),

	CL_FLT_DIG			= 6,
	CL_FLT_MANT_DIG		= 24,
	CL_FLT_MAX_10_EXP	= +38,
	CL_FLT_MAX_EXP		= +128,
	CL_FLT_MIN_10_EXP	= -37,
	CL_FLT_MIN_EXP		= -125,
	CL_FLT_RADIX		= 2,
	CL_FLT_MAX			= 340282346638528859811704183484516925440.0f,
	CL_FLT_MIN			= 1.175494350822287507969e-38f,
	CL_FLT_EPSILON		= 0x1.0p-23f,

	CL_DBL_DIG			= 15,
	CL_DBL_MANT_DIG		= 53,
	CL_DBL_MAX_10_EXP	= +308,
	CL_DBL_MAX_EXP		= +1024,
	CL_DBL_MIN_10_EXP	= -307,
	CL_DBL_MIN_EXP		= -1021,
	CL_DBL_RADIX		= 2,
	CL_DBL_MAX			= 179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.0,
	CL_DBL_MIN			= 2.225073858507201383090e-308,
	CL_DBL_EPSILON		= 2.220446049250313080847e-16,

	CL_M_E				= 2.718281828459045090796,
	CL_M_LOG2E			= 1.442695040888963387005,
	CL_M_LOG10E			= 0.434294481903251816668,
	CL_M_LN2			= 0.693147180559945286227,
	CL_M_LN10			= 2.302585092994045901094,
	CL_M_PI				= 3.141592653589793115998,
	CL_M_PI_2			= 1.570796326794896557999,
	CL_M_PI_4			= 0.785398163397448278999,
	CL_M_1_PI			= 0.318309886183790691216,
	CL_M_2_PI			= 0.636619772367581382433,
	CL_M_2_SQRTPI		= 1.128379167095512558561,
	CL_M_SQRT2			= 1.414213562373095145475,
	CL_M_SQRT1_2		= 0.707106781186547572737,

	CL_M_E_F			= 2.71828174591064f,
	CL_M_LOG2E_F		= 1.44269502162933f,
	CL_M_LOG10E_F		= 0.43429449200630f,
	CL_M_LN2_F			= 0.69314718246460f,
	CL_M_LN10_F			= 2.30258512496948f,
	CL_M_PI_F			= 3.14159274101257f,
	CL_M_PI_2_F			= 1.57079637050629f,
	CL_M_PI_4_F			= 0.78539818525314f,
	CL_M_1_PI_F			= 0.31830987334251f,
	CL_M_2_PI_F			= 0.63661974668503f,
	CL_M_2_SQRTPI_F		= 1.12837922573090f,
	CL_M_SQRT2_F		= 1.41421353816986f,
	CL_M_SQRT1_2_F		= 0.70710676908493f,

	CL_NAN				= (CL_INFINITY - CL_INFINITY),
	CL_HUGE_VALF		= (cast(cl_float) 1e50),
	CL_HUGE_VAL			= (cast(cl_double) 1e500),
	CL_MAXFLOAT			= CL_FLT_MAX,
	CL_INFINITY			= CL_HUGE_VALF,
}
+/

// Mirror types to GL types. Mirror types allow us to avoid deciding which headers to load based on whether we are using GL or GLES here.
typedef uint	cl_GLuint;
typedef int		cl_GLint;
typedef uint	cl_GLenum;

/*
 * Vector types 
 *
 *  Note:   OpenCL requires that all types be naturally aligned. 
 *          This means that vector types must be naturally aligned.
 *          For example, a vector of four floats must be aligned to
 *          a 16 byte boundary (calculated as 4 * the natural 4-byte 
 *          alignment of the float).  The alignment qualifiers here
 *          will only function properly if your compiler supports them
 *          and if you don't actively work to defeat them.  For example,
 *          in order for a cl_float4 to be 16 byte aligned in a struct,
 *          the start of the struct must itself be 16-byte aligned. 
 *
 *          Maintaining proper alignment is the user's responsibility.
 */

import std.cpuid;

alias byte[2]		cl_char2;
alias cl_char4		cl_char3;
alias byte[4]		cl_char4;
alias byte[8]		cl_char8;
alias byte[16]		cl_char16;
alias ubyte[2]		cl_uchar2;
alias cl_uchar4		cl_uchar3;
alias ubyte[4]		cl_uchar4;
alias ubyte[8]		cl_uchar8;
alias ubyte[16]		cl_uchar16;

alias short[2]		cl_short2;
alias cl_short4		cl_short3;
alias short[4]		cl_short4;
alias short[8]		cl_short8;
alias short[16]		cl_short16;
alias ushort[2]		cl_ushort2;
alias cl_ushort4	cl_ushort3;
alias ushort[4]		cl_ushort4;
alias ushort[8]		cl_ushort8;
alias ushort[16]	cl_ushort16;

alias int[2]		cl_int2;
alias cl_int4		cl_int3;
alias int[4]		cl_int4;
alias int[8]		cl_int8;
alias int[16]		cl_int16;
alias uint[2]		cl_uint2;
alias cl_uint4		cl_uint3;
alias uint[4]		cl_uint4;
alias uint[8]		cl_uint8;
alias uint[16]		cl_uint16;

alias long[2]		cl_long2;
alias cl_long4		cl_long3;
alias long[4]		cl_long4;
alias long[8]		cl_long8;
alias long[16]		cl_long16;
alias ulong[2]		cl_ulong2;
alias cl_ulong4		cl_ulong3;
alias ulong[4]		cl_ulong4;
alias ulong[8]		cl_ulong8;
alias ulong[16]		cl_ulong16;

alias float[2]		cl_float2;
alias cl_float4		cl_float3;
alias float[4]		cl_float4;
alias float[8]		cl_float8;
alias float[16]		cl_float16;

alias double[2]		cl_double2;
alias cl_double		cl_double3;
alias double[4]		cl_double4;
alias double[8]		cl_double8;
alias double[16]	cl_double16;

/* There are no vector types for half */
