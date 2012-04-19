@echo off

REM **********************************************************************
REM * Creates a suitable MSys/MinGW environment for working with git.
REM **********************************************************************

set DOWNLOAD=1
set UNTAR=1
set CLEAN=1

set X86BUILD=0
set X64BUILD=0
set GCCBUILD=0
set MULTIPLATFORMBUILD=1
set BUILDTYPE=%1

if /i "%1" equ "" (
	set BUILDTYPE=multiplatform
)

set DIR=%~dp0.
set CURRDIR=%CD%
set TOPDIR=%DIR%\..
set TMPDIR=%DIR%\tmp
set PACKAGESDIR=%TOPDIR%\packages
set TOOLSDIR=%DIR%
set TOOLSBINDIR=%TOOLSDIR%\bin
set PATCHESDIR=%TOOLSDIR%\patches
set BUILDPKGDIR=%TOOLSDIR%\..\build-packages-basic-git
set BUILDDIR=%BUILDPKGDIR%
set SOURCEDIR=%TMPDIR%\ossbuild-basic-git-env-src
set WINDOWSENVDIR=%TOOLSDIR%\..
set SHORTCUTDIR=%TOOLSDIR%\..
set RUBYDIR=%BUILDPKGDIR%\ruby
set MSYSDIR=%BUILDDIR%\msys
set MINGWDIR=%MSYSDIR%\mingw
set OPTDIR=%MSYSDIR%\opt
set DEST_MSYS_DIR=%MSYSDIR%
set MINGW_GET="%MINGWDIR%\bin\mingw-get.exe"
set MINGW_GET_PROFILE=%MINGWDIR%\var\lib\mingw-get\data\profile.xml
set MINGW_GET_DEFAULTS=%MINGWDIR%\var\lib\mingw-get\data\defaults.xml
set SHORTCUT_SUFFIX=x86

if /i "%BUILDTYPE%" equ "multiplatform" (
	echo Creating a multi-platform basic git environment...
	set X86BUILD=0
	set X64BUILD=0
	set GCCBUILD=0
	set MULTIPLATFORMBUILD=1
	set MSYSDIR=%BUILDDIR%\msys
	set MINGWDIR=%BUILDDIR%\msys\mingw
	set DEST_MSYS_DIR=%BUILDDIR%\msys
	set SHORTCUT_SUFFIX=multi-platform
)

if /i "%BUILDTYPE%" equ "X86" (
	echo Creating an x86 environment...
	set X86BUILD=1
	set X64BUILD=0
	set GCCBUILD=0
	set MULTIPLATFORMBUILD=0
	set MSYSDIR=%BUILDDIR%\msys\x86
	set MINGWDIR=%BUILDDIR%\msys\x86\mingw
	set DEST_MSYS_DIR=%BUILDDIR%\msys\x86
	set SHORTCUT_SUFFIX=x86
)

if /i "%BUILDTYPE%" equ "X86_64" (
	echo Creating an x86_64 environment...
	set X86BUILD=0
	set X64BUILD=1
	set GCCBUILD=0
	set MULTIPLATFORMBUILD=0
	set MSYSDIR=%BUILDDIR%\msys\x86_64
	set MINGWDIR=%BUILDDIR%\msys\x86_64\mingw
	set DEST_MSYS_DIR=%BUILDDIR%\msys\x86_64
	set SHORTCUT_SUFFIX=x86_64
)

if /i "%BUILDTYPE%" equ "GCCBUILD" (
	echo Creating an x86 environment for building gcc...
	set X86BUILD=0
	set X64BUILD=0
	set GCCBUILD=1
	set MULTIPLATFORMBUILD=0
	set MSYSDIR=%BUILDDIR%\msys\gcc-build
	set MINGWDIR=%BUILDDIR%\msys\gcc-build\mingw
	set DEST_MSYS_DIR=%BUILDDIR%\msys\gcc-build
	set SHORTCUT_SUFFIX=gcc-build
)

set PATH=%TMPDIR%\bin;%TOOLSBINDIR%;%TOOLSDIR%;%PATH%

mkdir "%TMPDIR%" > nul 2>&1
cd /d "%TMPDIR%"
 
rem Clean existing msys dir if we have one
if exist "%DEST_MSYS_DIR%" rmdir /S /Q "%DEST_MSYS_DIR%"

mkdir "%DEST_MSYS_DIR%" > nul 2>&1

mkdir "%MSYSDIR%" > nul 2>&1
mkdir "%MINGWDIR%" > nul 2>&1

rem Re-add the .gitignore file
echo !.gitignore> "%DEST_MSYS_DIR%\.gitignore"
echo *>>          "%DEST_MSYS_DIR%\.gitignore"

rem Mark .gitignore as hidden
attrib +H "%DEST_MSYS_DIR%\.gitignore"



set PKG_MINGWGET_BIN=http://downloads.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.4-alpha-1/mingw-get-0.4-mingw32-alpha-1-bin.tar.xz?use_mirror=voxel
set PKG_MINGWGET_LIC=http://downloads.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.4-alpha-1/mingw-get-0.4-mingw32-alpha-1-lic.tar.xz?use_mirror=voxel

set PKG_SYSINTERNALS_JUNCTION_BIN=http://download.sysinternals.com/files/Junction.zip

set PKG_MSYSGIT_BIN=http://msysgit.googlecode.com/files/PortableGit-1.7.10-preview20120409.7z


rem Download
call :download mingw-get-bin "%PKG_MINGWGET_BIN%"
call :download mingw-get-lic "%PKG_MINGWGET_LIC%"
call :download sysinternals-junction-bin "%PKG_SYSINTERNALS_JUNCTION_BIN%"

rem Get msysGit which has a newer version of perl
if "%GCCBUILD%" neq "1" (
	echo Retrieving msys-git...
	wget --quiet --no-check-certificate -O git.7z "%PKG_MSYSGIT_BIN%" > nul 2>&1
)


cd /d "%MSYSDIR%"


 
 rem Extract (uncompress)
cd /d "%TMPDIR%"
if "%GCCBUILD%" neq "1" (
	rem Get git commands
	echo Extracting msys-git...
	7za -y "-o%MSYSDIR%" x git.7z > nul 2>&1
	
	rem Remove msysgit version of perl because we'll be using mingw.org's shortly
	"%TOOLSBINDIR%\rm" -rf "%MSYSDIR%\lib\perl5"
	"%TOOLSBINDIR%\rm" -f "%MSYSDIR%\bin\perl*"
)

echo Extracting sysinternals-junction-bin...
move sysinternals-junction-bin.tar.lzma sysinternals-junction-bin.zip > nul 2>&1
7za -y "-o%MSYSDIR%\bin" x sysinternals-junction-bin.zip > nul 2>&1



if "%MULTIPLATFORMBUILD%" == "1" (
	copy /Y "%PACKAGESDIR%\msys\msys-x86.bat" "%MSYSDIR%\msys-x86.bat"
	copy /Y "%PACKAGESDIR%\msys\msys-x86_64.bat" "%MSYSDIR%\msys-x86_64.bat"
)

rem Copy our updated batch file that allows for whitespace in the path.
copy /Y "%PACKAGESDIR%\msys\msys.bat" "%MSYSDIR%\msys.bat"

cd /d "%MSYSDIR%"

call :extract mingw-get-bin %MINGWDIR%
call :extract mingw-get-lic %MINGWDIR%


 
if not exist "%MINGW_GET_PROFILE%" (
	rem Outputs the following:
	rem 
	rem <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
	rem <profile project="MinGW" application="mingw-get">
	rem     <repository uri="http://prdownloads.sourceforge.net/mingw/%F.xml.lzma?download">
	rem     </repository>
	rem     <system-map id="default">
	rem     <sysroot subsystem="mingw32" path="%R/../mingw" />
	rem         <sysroot subsystem="MSYS" path="%R/.." />
	rem     </system-map>
	rem </profile>
	echo Updating mingw-get profile...
	echo ^<?xml version="1.0" encoding="UTF-8" standalone="yes"?^>                                              > %MINGW_GET_PROFILE%
	echo ^<!-- --^>    ^<profile project="MinGW" application="mingw-get"^>                                     >> %MINGW_GET_PROFILE%
	echo ^<!-- --^>        ^<repository uri="http://prdownloads.sourceforge.net/mingw/%%F.xml.lzma?download"^> >> %MINGW_GET_PROFILE%
	echo ^<!-- --^>        ^</repository^>                                                                     >> %MINGW_GET_PROFILE%
	echo ^<!-- --^>        ^<system-map id="default"^>                                                         >> %MINGW_GET_PROFILE%
	echo ^<!-- --^>        ^<sysroot subsystem="mingw32" path="%%R/../mingw" /^>                               >> %MINGW_GET_PROFILE%
	echo ^<!-- --^>            ^<sysroot subsystem="MSYS" path="%%R/.." /^>                                    >> %MINGW_GET_PROFILE%
	echo ^<!-- --^>        ^</system-map^>                                                                     >> %MINGW_GET_PROFILE%
	echo ^<!-- --^>    ^</profile^>                                                                            >> %MINGW_GET_PROFILE%
)

%MINGW_GET% update



set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-bash         msys-bzip2        msys-console      msys-core         msys-coreutils 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-crypt        msys-cvs          msys-cygutils     msys-dash         msys-diffutils 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-file         msys-gzip         msys-less         msys-man          msys-minires 

set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-mintty       msys-openssh      msys-openssl      msys-patch        msys-zlib 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-rebase       msys-gettext      msys-gmp          msys-grep         msys-regex 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-sed          msys-tar          msys-unzip        msys-vim          msys-wget 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-xz           msys-zip          msys-findutils           
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% mingw32-bsdtar    mingw-get  
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% mingw-get         
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% libgomp           libstdc++
%MINGW_GET% install %MINGW_GET_TARGETS%



rem Create profile directory
mkdir "%MSYSDIR%\etc" > nul 2>&1
mkdir "%MSYSDIR%\etc\profile.d" > nul 2>&1
copy /Y "%PACKAGESDIR%\msys\ossbuild-basic.sh" "%MSYSDIR%\etc\profile.d\"



rem Source
mkdir "%SOURCEDIR%" > nul 2>&1
cd /d "%SOURCEDIR%"
%MINGW_GET% --all-related source %MINGW_GET_TARGETS%
%MINGW_GET% --all-related licence %MINGW_GET_TARGETS%
cd /d ".."
"%TOOLSBINDIR%\rm" -f "..\..\ossbuild-basic-git-env-src.7z"
7za a -t7z "..\..\ossbuild-basic-git-env-src.7z" ossbuild-basic-git-env-src
mkdir "..\..\install-basic-git\bin\Release\en-us"
copy /Y "..\..\ossbuild-basic-git-env-src.7z" "..\..\install-basic-git\bin\Release\en-us"
rem Remove the downloaded source from the mingw-get cache. It's available as a separate download.
"%TOOLSBINDIR%\rm" -rf "%MINGWDIR%\var\cache\mingw-get\source\"

rem Cleanup
cd /d "%TMPDIR%"
call :clean mingw-get-bin
call :clean mingw-get-lic



if "%GCCBUILD%" neq "1" (
	del git.7z
)

rem Clean gettext libs and includes that we don't want hanging around
"%TOOLSBINDIR%\rm" -rf "%MSYSDIR%\lib\lib*"
"%TOOLSBINDIR%\rm" -rf "%MSYSDIR%\include\*"

rem Remove temp directory
cd /d "%TOPDIR%"
"%TOOLSBINDIR%\rm" -rf "%TMPDIR%"

rem Move to known directory
cd /d "%MSYSDIR%"

rem Cleanup the home directory if it exists.
"%TOOLSBINDIR%\rm" -rf "%MSYSDIR%\home"

goto done



:download %filename% %url%
setlocal
set filename=%~1&set url=%~2
set currdirectory=%CD%
cd /d "%TMPDIR%"
echo Retrieving %filename%...
wget --quiet --no-check-certificate -O %filename%.tar.lzma "%url%" > nul 2>&1
cd /d "%currdirectory%"
endlocal&goto :EOF

:extract %filename% %destdir%
setlocal ENABLEEXTENSIONS
set filename=%~1&set destdir=%~2
set currdirectory=%CD%
cd /d "%TMPDIR%"
echo Extracting %filename%...
7za -y x %filename%.tar.lzma > nul 2>&1
7za -y "-o%destdir%" x %filename%.tar > nul 2>&1
del %filename%.tar
rem Don't remove the .tar.lzma file -- leave it for the cleaning stage
cd /d "%currdirectory%"
endlocal&goto :EOF

:clean %filename%
setlocal ENABLEEXTENSIONS
set filename=%~1
set currdirectory=%CD%
cd /d "%TMPDIR%"
del %filename%.tar.lzma
cd /d "%currdirectory%"
endlocal&goto :EOF

:done
cd /d "%CURRDIR%"
rem exit 0
