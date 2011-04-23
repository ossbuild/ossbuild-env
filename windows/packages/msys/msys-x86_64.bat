@echo off

REM **********************************************************************
REM * Creates a suitable MSys/MinGW environment for building the Windows 
REM * libraries using GCC and associated auto tools.
REM **********************************************************************

set DIR=%~dp0.
set CURR_DIR=%CD%
set OSSBUILD_DIR=%DIR%\..\..
set OSSBUILD_HOME_DIR=%OSSBUILD_DIR%\Home
set MSYS_DIR=%DIR%
set OPT_DIR=%MSYS_DIR%\opt
set MINGW_DIR=%MSYS_DIR%\mingw
set MINGW_W64_DIR=%OPT_DIR%\mingw-w64\x86_64
set OPT_PERL_DIR=%MSYS_DIR%\opt\strawberry-perl
set INTLTOOL_PERL=%OPT_PERL_DIR%\perl\bin\perl.exe

set PATH=%PATH%;%MINGW_W64_DIR%\bin;%OPT_PERL_DIR%\perl\bin;%OPT_PERL_DIR%\c\bin;

if "%HOME%" == "" (
	if not "%USERNAME%" == "" (
		set HOME=%OSSBUILD_HOME_DIR%\%USERNAME%
	)
)

cd /d "%DIR%"
msys.bat
