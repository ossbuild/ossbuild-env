
To get the build environment installer setup you'll need to:

  1. Run tools/msys-env.bat

  2. Setup additional tools (e.g. jhbuild) by running setup-env.sh from an 
     msys prompt. e.g.:
     
         /E/Development/ossbuild-git/ossbuild-env/windows/setup-env.sh
     
     Note: The above script modifies the profile, so you will need to restart 
           your terminal (login session) to ensure you've incorporated its 
           modifications.

  3. Run install/generated/generate-msys.wxs.bat to use WiX' heat tool 
     for auto-generating a list of files to add to the installer.
     
     Note: Please ensure that you don't introduce unnecessary files such as  
           .pyc (compiled python files) or Makefile.am's, etc. The home 
           directory should also be completely absent.

  4. Open and build bootstrap.sln from Visual Studio
