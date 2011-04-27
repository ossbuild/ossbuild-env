
To get the build environment installer setup you'll need to:

  1. Ensure that Visual Studio 2010 is installed
  
  2. Ensure that WiX 3.5 or later is installed

  3. Run tools/msys-env.bat

  4. Run install/generated/generate-msys.wxs.bat to use WiX' heat tool 
     for auto-generating a list of files to add to the installer.
     
     Note: Please ensure that you don't introduce unnecessary files such as  
           .pyc (compiled python files) or Makefile.am's, etc. The home 
           directory should also be completely absent.

  5. Open and build bootstrap.sln from Visual Studio 2010.
