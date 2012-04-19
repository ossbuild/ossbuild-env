@echo off

REM **********************************************************************
REM * Runs the installer with logging enabled for testing purposes.
REM **********************************************************************

set CURR=%CD%
set DIR=%~dp0.

:start
cd /d "%DIR%"



echo Executing msi package with logging enabled...
msiexec /i "bin\Release\en-us\env-git-only.msi" /l*v "install.log"



goto exit

:exit
cd /d "%CURR%"
