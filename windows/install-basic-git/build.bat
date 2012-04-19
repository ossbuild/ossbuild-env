@echo off

REM **********************************************************************
REM * Uses MSBuild to create an MSI package (installer).
REM **********************************************************************

set MSBUILDPARAMS=/t:Rebuild /p:Configuration=Release

set ORIGPATH=%PATH%
set CURR=%CD%
set DIR=%~dp0.
set TOPDIR=%DIR%\..\..
set TOOLSDIR=%TOPDIR%\windows\tools
set TOOLSBINDIR=%TOOLSDIR%\bin

set WIXDIR=%WIX%

for /F "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows Installer XML\3.5" /v "InstallRoot" 2^>nul') do set "REG32WIXDIR=%%B..\"
for /F "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows Installer XML\3.5" /v "InstallRoot" 2^>nul') do set "REG64WIXDIR=%%B..\"
if not exist "%WIXDIR%" set WIXDIR=%REG32WIXDIR%
if not exist "%WIXDIR%" set WIXDIR=%REG64WIXDIR%

set WIXBINDIR=%WIXDIR%bin
set HEAT="%WIXBINDIR%\heat.exe"

set DOTNETFRAMEWORKDIR=
for /F "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client" /v "InstallPath" 2^>nul') do set "DOTNETFRAMEWORKDIR1=%%B"
for /F "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Wow6432Node\Microsoft\NET Framework Setup\NDP\v4\Client" /v "InstallPath" 2^>nul') do set "DOTNETFRAMEWORKDIR2=%%B"
for /F "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" /v "InstallPath" 2^>nul') do set "DOTNETFRAMEWORKDIR3=%%B"
for /F "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Wow6432Node\Microsoft\NET Framework Setup\NDP\v3.5" /v "InstallPath" 2^>nul') do set "DOTNETFRAMEWORKDIR4=%%B"
if not exist "%DOTNETFRAMEWORKDIR%" set DOTNETFRAMEWORKDIR=%DOTNETFRAMEWORKDIR1%
if not exist "%DOTNETFRAMEWORKDIR%" set DOTNETFRAMEWORKDIR=%DOTNETFRAMEWORKDIR2%
if not exist "%DOTNETFRAMEWORKDIR%" set DOTNETFRAMEWORKDIR=%DOTNETFRAMEWORKDIR3%
if not exist "%DOTNETFRAMEWORKDIR%" set DOTNETFRAMEWORKDIR=%DOTNETFRAMEWORKDIR4%

if not exist "%DOTNETFRAMEWORKDIR%" (
	echo Unable to locate the .NET framework directory.
	goto exit
)
set MSBUILD="%DOTNETFRAMEWORKDIR%\MSBuild.exe"

set PATH=%WIXBINDIR%;%DOTNETFRAMEWORKDIR%;%TOOLSBINDIR%;%SystemRoot%;%SystemRoot%\system32

:start
cd /d "%DIR%"



echo Building installer...
%MSBUILD% "%DIR%\basicgitenv.sln" %MSBUILDPARAMS%



goto exit

:exit
set PATH=%ORIGPATH%
cd /d "%CURR%"