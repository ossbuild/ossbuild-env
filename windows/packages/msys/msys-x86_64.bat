@echo off

REM **********************************************************************
REM * Creates a suitable MSys/MinGW environment for building the Windows 
REM * libraries using GCC and associated auto tools.
REM **********************************************************************

set DIR=%~dp0.
set CURRDIR=%CD%
set MSYSDIR=%DIR%
set MINGWDIR=%MSYSDIR%\mingw
set PERLDIR=%MINGWDIR%\perl\perl
set MINGWARCHDIR=%MSYSDIR%\mingw-x86_64

set PATH=%PATH%;%MINGWARCHDIR%\bin;%PERLDIR%\bin

cd /d "%DIR%"
msys.bat
