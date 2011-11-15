@echo off

REM **********************************************************************
REM * Uses WiX' setupbld tool to generate a very simple bootstrapper 
REM * that chains all of the installers one after the other.
REM **********************************************************************

set ORIGPATH=%PATH%
set CURR=%CD%
set DIR=%~dp0.
set TOPDIR=%DIR%\..\..\..
set TOOLSDIR=%TOPDIR%\windows\tools
set TOOLSBINDIR=%TOOLSDIR%\bin

set WIXDIR=%WIX%
set WIXBINDIR=%WIXDIR%bin
set SETUPBLD="%WIXBINDIR%\setupbld.exe"

set BUILDPKGDIR=%DIR%\..\..\build-packages
set MSYSDIR=%BUILDPKGDIR%\msys
set MSYSHOME=%MSYSDIR%\home
set GENTMPDIR=%DIR%\tmp

set PATH=%WIXBINDIR%;%TOOLSBINDIR%;%SystemRoot%;%SystemRoot%\system32

:start
cd /d "%DIR%"



echo In the future, please evaluate using WiX' burn.exe.
echo Using WiX setupbld.exe to generate a simple bootstrapper...
%SETUPBLD% -mts "..\..\installers\python.msi" -mts "..\bin\Release\en-us\env.msi" -title "OSSBuild Build Environment" -setup "%WIXBINDIR%\setup.exe" -license "..\..\..\shared\licenses\lgpl.rtf" -out "..\bin\Release\ossbuild-build-env.exe"



goto exit

:exit
set PATH=%ORIGPATH%
cd /d "%CURR%"
