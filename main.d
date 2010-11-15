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
module main;

//import common;

import opencl.all;

import std.stdio;

void main(string[] args)
{
	auto platform = CLPlatform.getPlatforms[0];
	writefln("%s\n\t%s\n\t%s\n\t%s\n\t%s", platform.name, platform.vendor, platform.clversion, platform.profile, platform.extensions);

	auto devices = platform.allDevices;
	
	foreach(device; devices)
		writefln("%s\n\t%s\n\t%s\n\t%s\n\t%s", device.name, device.vendor, device.driverVersion, device.clVersion, device.profile, device.extensions);
	
	auto context = new CLContext(devices);
	
	auto program = context.createProgram(`
			__kernel void sum(	__global const float* a,
								__global const float* b,
								__global float* c)
			{
				int i = get_global_id(0);
				c[i] = a[i] + b[i];
			} `);
	program.build("-Werror");
	
	auto kernel = new CLKernel(program, "sum");
	
	auto buffer = new CLBuffer(context);
}