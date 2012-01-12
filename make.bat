rdmd --force --build-only --chatty -version=CL_VERSION_1_1 -d -release -O -w OpenCL.lib -ofvectorAdd vectorAdd.d && cv2pdb -D2 vectorAdd.exe

rdmd --force --build-only --chatty -version=CL_VERSION_1_1 -d -release -O -w -I../Derelict2/DerelictGL/ -I../Derelict2/DerelictSDL/ -I../Derelict2/DerelictUtil/ OpenCL.lib -ofCLGLInterop CLGLInterop.d && cv2pdb -D2 CLGLInterop.exe

pause
