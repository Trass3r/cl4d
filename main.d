module main;

import common;

//import opencl.c.cl;
import opencl.context;
import opencl.device;
import opencl.platform;

import std.stdio;

void main(istring[] args)
{
	auto platform = CLPlatform.getPlatforms[0];
	writefln("%s %s %s %s %s", platform.name, platform.vendor, platform.clversion, platform.profile, platform.extensions);

	auto devices = platform.getDevices(CL_DEVICE_TYPE_ALL);
	
	foreach(device; devices)
		writefln("%s %s %s %s %s", device.name, device.vendor, device.driverVersion, device.clVersion, device.profile, device.extensions);
	
	auto context = new CLContext(devices);
	
	auto program = context.createProgram(`
			__kernel void sum(	__global const float* a,
								__global const float* b,
								__global float* c)
			{
				int i = get_global_id(0);
				c[i] = a[i] + b[i];
			} `).buildDebug();
	
}