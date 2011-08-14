rdmd --force --build-only --chatty -version=CL_VERSION_1_1 -release -O -w -L-lOpenCL -ofvectorAdd vectorAdd.d
rdmd --force --build-only --chatty -version=CL_VERSION_1_1 -release -O -w -I../Derelict2/DerelictGL/ -I../Derelict2/DerelictSDL/ -I../Derelict2/DerelictUtil/ -L-lOpenCL -ofCLGLInterop CLGLInterop.d
