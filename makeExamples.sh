rdmd --force --build-only --chatty -release -O -w -L-lOpenCL -ofvectorAdd vectorAdd.d
rdmd --force --build-only --chatty -release -O -w -I../Derelict2/DerelictGL/ -I../Derelict2/DerelictSDL/ -I../Derelict2/DerelictUtil/ -L-lOpenCL -ofCLGLInterop CLGLInterop.d
