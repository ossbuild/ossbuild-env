@echo off

REM **********************************************************************
REM * Uses WiX' heat tool to generate the XML for the ruby portion of the 
REM * installer.
REM * 
REM * After generating output, it's then processed via XSLT, which 
REM * modifies some values, inserts some elements, and removes others.
REM **********************************************************************

set ORIGPATH=%PATH%
set CURR=%CD%
set DIR=%~dp0.
set TOPDIR=%DIR%\..\..\..
set TOOLSDIR=%TOPDIR%\windows\tools
set TOOLSBINDIR=%TOOLSDIR%\bin

set WIXDIR=%WIX%
set WIXBINDIR=%WIXDIR%bin
set HEAT="%WIXBINDIR%\heat.exe"

set BUILDPKGDIR=%DIR%\..\..\build-packages
set MSYSDIR=%BUILDPKGDIR%\msys
set MINGWDIR=%MSYSDIR%\mingw
set RUBYDIR=%BUILDPKGDIR%\ruby
set GENTMPDIR=%DIR%\tmp

set PATH=%WIXBINDIR%;%TOOLSBINDIR%;%SystemRoot%;%SystemRoot%\system32

:start
cd /d "%DIR%"



echo Using WiX heat.exe to generate Ruby installer output...
%HEAT% dir "%RUBYDIR%" -sw5150 -nologo -ag -sreg -scom -svb6 -sfrag -template fragment -dr OSSBuildInstallMinGWDir -var var.RUBY_DIR -t ruby.xslt -cg OSSBuildBuildEnvRuby -out "%DIR%\ruby.wxs"



goto exit

:exit
set PATH=%ORIGPATH%
cd /d "%CURR%"