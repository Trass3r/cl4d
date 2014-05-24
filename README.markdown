Welcome
=======

*cl4d* is an object-oriented wrapper for the [OpenCL](http://www.khronos.org/opencl/) C API written in the [D programming language](http://www.dlang.org/).\\
Since the package includes bindings to the C API, you may also directly write usual OpenCL code if you need to.

You're welcome to contribute to the project.
* test
* file issues about bugs
* send patches
* whatever else

License
=======

The code is licensed under the terms of the Boost Software License 1.0.

Build instructions
==================
To use the package as dependency add following to you `dub.json` file:
```JSON
"dependencies": {
  "cl4d": "~master"
}
```

* The repo contains some sample modules for your guidance.
To build them you can run following in repo root folder:
```
dub build --config=vector-example
dub build --config=gl-example
```
* Note that cl4d uses Derelict dependencies for the OpenGL interoperability sample.

* Be sure to always use the latest compiler version!
* For maximal performance enable function inlining and set version NO_CL_EXCEPTIONS. Then direct calls to the C API are performed.
  If you additionally use proper dead code elimination (e.g. [gdc](https://bitbucket.org/goshawk/gdc)'s -ffunction-sections -fdata-sections -Wl,--gc-sections) or [LTO](http://en.wikipedia.org/wiki/Link-time_optimization) almost all of the wrapper code should disappear.

Guidelines
==========

The philosophy behind cl4d is to provide a thin layer on top of the C API which makes working with OpenCL less painful by harnessing D's linguistic power. Unlike the official C++ bindings I still try to wrap the C API as good as possible, e.g. object properties are properly exposed as such so you don't have to call something like getInfo!cl_uint(CL_KERNEL_NUM_ARGS) all the time.

The cumbersome C error handling is replaced by proper exception handling. Each OpenCL error gets its own Exception class so it is possible to selectively catch them as needed.
Also expressive error messages are given.
You may use version=NO_CL_EXCEPTIONS or version=BASIC_CL_EXCEPTIONS to reduce the EH overhead.

Reference counts are automatically managed via (copy) constructors and destructors.
Collections of CL objects are handled by a dedicated structure so you won't ever need to deal with pointers at all.
There are no external dependencies and calls to the standard library are kept at a minimum.
