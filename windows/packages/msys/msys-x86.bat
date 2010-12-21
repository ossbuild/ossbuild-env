@echo off

REM **********************************************************************
REM * Creates a suitable MSys/MinGW environment for building the Windows 
REM * libraries using GCC and associated auto tools.
REM **********************************************************************

set DIR=%~dp0.
set CURRDIR=%CD%
set MSYSDIR=%DIR%
set MINGWDIR=%MSYSDIR%\mingw-x86

set PATH=%PATH%;%MINGWDIR%\bin

cd /d "%DIR%"
msys.bat
