@echo off

REM **********************************************************************
REM * Uses WiX' heat tool to generate the XML for the msys portion of the 
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

set MSYSDIR=%DIR%\..\..\msys
set MSYSHOME=%MSYSDIR%\home
set GENTMPDIR=%DIR%\tmp

set PATH=%WIXBINDIR%;%TOOLSBINDIR%;%SystemRoot%;%SystemRoot%\system32

:start
cd /d "%DIR%"



echo Cleaning up msys...
if exist "%MSYSHOME%" (
	echo Creating temporary directory...
	mkdir "%GENTMPDIR%"
	
	echo Moving home directories...
	mv "%MSYSHOME%\*" "%GENTMPDIR%"
)



echo Using WiX heat.exe to generate MSys/MinGW installer output...
%HEAT% dir "%MSYSDIR%" -sw5150 -nologo -ag -sreg -scom -svb6 -sfrag -template fragment -dr OSSBuildInstallEnvironmentDir -var var.MSYS_DIR -t msys.xslt -cg OSSBuildBuildEnvMSys -out "%DIR%\msys.wxs"



echo Restoring msys environment...
if exist "%GENTMPDIR%" (
	echo Moving home directories back...
	mv "%GENTMPDIR%\*" "%MSYSHOME%"
	
	echo Removing temporary directory...
	rm -rf "%GENTMPDIR%"
)



goto exit

:exit
set PATH=%ORIGPATH%
cd /d "%CURR%"