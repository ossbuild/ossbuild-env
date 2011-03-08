@echo off

REM **********************************************************************
REM * Creates a suitable MSys/MinGW environment for building the Windows 
REM * libraries using GCC and associated auto tools.
REM **********************************************************************

set DIR=%~dp0.
set CURRDIR=%CD%
set MSYSDIR=%DIR%
set OPTDIR=%MSYSDIR%\opt
set MINGWDIR=%MSYSDIR%\mingw
set MINGWARCHDIR=%OPTDIR%\mingw-w64\x86
set OPTPERLDIR=%MSYSDIR%\opt\strawberry-perl
set INTLTOOL_PERL=%OPTPERLDIR%\perl\bin\perl.exe

set PATH=%PATH%;%MINGWARCHDIR%\bin;%OPTPERLDIR%\perl\bin;%OPTPERLDIR%\c\bin;

cd /d "%DIR%"
msys.bat
