To get the build environment installer setup you'll need to:

1. Run tools/msys-env.bat
2. Open a shell and run:

     cd ~/
     mkdir jhbuild && cd jhbuild
     git clone http://git.gitorious.org/~ylatuya/jhbuild/ylatuyas-jhbuild.git
     make -f Makefile.windows install