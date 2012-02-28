@echo off

REM **********************************************************************
REM * Creates a suitable MSys/MinGW environment for building the Windows 
REM * libraries using GCC and associated auto tools.
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
set BUILDPKGDIR=%TOOLSDIR%\..\build-packages
set BUILDDIR=%BUILDPKGDIR%
set SOURCEDIR=%TMPDIR%\ossbuild-env-src
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
	echo Creating a multi-platform environment...
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
set PKG_MINGWGETPKGINFO_BIN=http://downloads.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.4-alpha-1/pkginfo-0.4-mingw32-alpha-1-bin.tar.xz?use_mirror=voxel
set PKG_MINGW_PEXPORTS_BIN=http://downloads.sourceforge.net/project/mingw/MinGW/Extension/pexports/pexports-0.44-1/pexports-0.44-1-mingw32-bin.tar.lzma?use_mirror=voxel
set PKG_MINGW_PEXPORTS_DOC=http://downloads.sourceforge.net/project/mingw/MinGW/Extension/pexports/pexports-0.44-1/pexports-0.44-1-mingw32-doc.tar.lzma?use_mirror=voxel
set PKG_MINGW_PEXPORTS_LIC=http://downloads.sourceforge.net/project/mingw/MinGW/Extension/pexports/pexports-0.44-1/pexports-0.44-1-mingw32-lic.tar.lzma?use_mirror=voxel

set PKG_MINGW_GLIB_DLL=http://ftp.gnome.org/pub/gnome/binaries/win32/glib/2.28/glib_2.28.8-1_win32.zip
set PKG_MINGW_PKGCONFIG_BIN=http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/pkg-config_0.26-1_win32.zip
set PKG_MINGW_PKGCONFIG_DEV=http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/pkg-config-dev_0.26-1_win32.zip
set PKG_MINGW_GETTEXTRUNTIME_BIN=http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/gettext-runtime_0.18.1.1-2_win32.zip

set PKG_MSYS_FLIP_BIN=https://ccrma.stanford.edu/~craig/utility/flip/flip.exe

set PKG_SYSINTERNALS_JUNCTION_BIN=http://download.sysinternals.com/Files/Junction.zip

set PKG_MSYSGIT_BIN=http://msysgit.googlecode.com/files/PortableGit-1.7.9-preview20120201.7z
set PKG_STRAWBERRY_PERL_BIN=http://strawberry-perl.googlecode.com/files/strawberry-perl-5.14.2.1-32bit-portable.zip

set PKG_SUBVERSION_BIN=http://alagazam.net/svn-1.7.3/svn-win32-1.7.3.zip


rem See http://rubyinstaller.org/downloads/
set PKG_RUBY_BIN=http://rubyforge.org/frs/download.php/75849/ruby-1.9.3-p125-i386-mingw32.7z
set PKG_RUBY_BIN_DIR=ruby-1.9.3-p125-i386-mingw32

set PKG_OSSBUILD_W64_GCC_X86_BIN=http://ossbuild.googlecode.com/files/mingw-w64-x86-ossbuild-bin-r164692.tar.lzma
set PKG_OSSBUILD_W64_GCC_X86_64_BIN=http://ossbuild.googlecode.com/files/mingw-w64-x86_64-ossbuild-bin-r164692.tar.lzma


rem Download
call :download msys-flip-bin "%PKG_MSYS_FLIP_BIN%"
call :download mingw-get-bin "%PKG_MINGWGET_BIN%"
call :download mingw-get-lic "%PKG_MINGWGET_LIC%"
call :download mingw-get-pkginfo-bin "%PKG_MINGWGETPKGINFO_BIN%"
call :download mingw-pexports-bin "%PKG_MINGW_PEXPORTS_BIN%"
call :download mingw-pexports-doc "%PKG_MINGW_PEXPORTS_DOC%"
call :download mingw-pexports-lic "%PKG_MINGW_PEXPORTS_LIC%"
call :download mingw-glib-dll "%PKG_MINGW_GLIB_DLL%"
call :download mingw-pkg-config-bin "%PKG_MINGW_PKGCONFIG_BIN%"
call :download mingw-pkg-config-dev "%PKG_MINGW_PKGCONFIG_DEV%"
call :download mingw-gettext-runtime-bin "%PKG_MINGW_GETTEXTRUNTIME_BIN%"
call :download sysinternals-junction-bin "%PKG_SYSINTERNALS_JUNCTION_BIN%"

echo Retrieving ruby...
wget --quiet --no-check-certificate -O ruby.7z "%PKG_RUBY_BIN%" > nul 2>&1

rem Get msysGit which has a newer version of perl
if "%GCCBUILD%" neq "1" (
	echo Retrieving msys-git...
	wget --quiet --no-check-certificate -O git.7z "%PKG_MSYSGIT_BIN%" > nul 2>&1
)

if "%X86BUILD%" == "1" (
	rem OSSBuild MinGW-w64 x86
	call :download ossbuild-w64-x86-bin "%PKG_OSSBUILD_W64_GCC_X86_BIN%"
)

if "%X64BUILD%" == "1" (
	rem OSSBuild MinGW-w64 x86_64
	call :download ossbuild-w64-x86_64-bin "%PKG_OSSBUILD_W64_GCC_X86_64_BIN%"
)

if "%GCCBUILD%" == "1" (
	rem OSSBuild MinGW-w64 GCC
	call :download ossbuild-w64-x86-bin "%PKG_OSSBUILD_W64_GCC_X86_BIN%"
)

if "%MULTIPLATFORMBUILD%" == "1" (
	rem OSSBuild MinGW-w64 x86
	call :download ossbuild-w64-x86-bin "%PKG_OSSBUILD_W64_GCC_X86_BIN%"
	
	rem OSSBuild MinGW-w64 x86_64
	call :download ossbuild-w64-x86_64-bin "%PKG_OSSBUILD_W64_GCC_X86_64_BIN%"
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

rem It's a straight up executable from a website
move msys-flip-bin.tar.lzma "%MSYSDIR%\bin\flip.exe" > nul 2>&1

echo Extracting subversion...
7za -y "-o%MINGWDIR%" x "%PACKAGESDIR%\subversion\subversion.zip" > nul 2>&1

echo Extracting cmake...
7za -y "-o%MINGWDIR%" x "%PACKAGESDIR%\cmake\cmake.zip" > nul 2>&1

echo Extracting dmake...
7za -y "-o%MINGWDIR%" x "%PACKAGESDIR%\dmake\dmake.zip" > nul 2>&1

echo Extracting strawberry perl...
7za -y "-o%OPTDIR%\strawberry-perl" x "%PACKAGESDIR%\perl\perl.zip" > nul 2>&1

echo Extracting mingw-gettext-runtime-bin...
move mingw-gettext-runtime-bin.tar.lzma mingw-gettext-runtime-bin.zip > nul 2>&1
7za -y "-o%MINGWDIR%" x mingw-gettext-runtime-bin.zip > nul 2>&1

echo Extracting mingw-glib-dll...
move mingw-glib-dll.tar.lzma mingw-glib-dll.zip > nul 2>&1
7za -y "-o%MINGWDIR%" x mingw-glib-dll.zip > nul 2>&1

echo Extracting mingw-pkg-config-bin...
move mingw-pkg-config-bin.tar.lzma mingw-pkg-config-bin.zip > nul 2>&1
7za -y "-o%MINGWDIR%" x mingw-pkg-config-bin.zip > nul 2>&1

echo Extracting mingw-pkg-config-dev...
move mingw-pkg-config-dev.tar.lzma mingw-pkg-config-dev.zip > nul 2>&1
7za -y "-o%MINGWDIR%" x mingw-pkg-config-dev.zip > nul 2>&1

echo Extracting sysinternals-junction-bin...
move sysinternals-junction-bin.tar.lzma sysinternals-junction-bin.zip > nul 2>&1
7za -y "-o%MSYSDIR%\bin" x sysinternals-junction-bin.zip > nul 2>&1

echo Extracting ruby...
7za -y "-o%RUBYDIR%" x ruby.7z > nul 2>&1
"%TOOLSBINDIR%\mv" "%RUBYDIR%\%PKG_RUBY_BIN_DIR%\*" "%RUBYDIR%" > nul 2>&1
"%TOOLSBINDIR%\rm" -rf "%RUBYDIR%\%PKG_RUBY_BIN_DIR%"

if "%X86BUILD%" == "1" (
	call :extract ossbuild-w64-x86-bin %MINGWDIR%
)

if "%X64BUILD%" == "1" (
	call :extract ossbuild-w64-x86_64-bin %MINGWDIR%
)

if "%GCCBUILD%" == "1" (
	call :extract ossbuild-w64-x86-bin %MINGWDIR%
)

if "%MULTIPLATFORMBUILD%" == "1" (
	call :extract ossbuild-w64-x86-bin %OPTDIR%\mingw-w64\x86
	call :extract ossbuild-w64-x86_64-bin %OPTDIR%\mingw-w64\x86_64
	
	copy /Y "%PACKAGESDIR%\msys\msys-x86.bat" "%MSYSDIR%\msys-x86.bat"
	copy /Y "%PACKAGESDIR%\msys\msys-x86_64.bat" "%MSYSDIR%\msys-x86_64.bat"
)

REM Copy our updated batch file that allows for whitespace in the path.
copy /Y "%PACKAGESDIR%\msys\msys.bat" "%MSYSDIR%\msys.bat"

cd /d "%MSYSDIR%"

call :extract mingw-pexports-bin %MINGWDIR%
call :extract mingw-pexports-doc %MINGWDIR%
call :extract mingw-pexports-lic %MINGWDIR%
call :extract mingw-get-bin %MINGWDIR%
call :extract mingw-get-lic %MINGWDIR%
call :extract mingw-get-pkginfo-bin %MINGWDIR%


 
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

set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-autoconf     msys-autogen      msys-automake     msys-bash         msys-binutils 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-bison        msys-bzip2        msys-console      msys-core         msys-coreutils 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-crypt        msys-cvs          msys-cygutils     msys-dash         msys-diffutils 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-expat        msys-file         msys-flex         msys-gawk         msys-locate 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-gdbm         msys-gettext      msys-gmp          msys-grep         msys-groff 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-guile        msys-gzip         msys-inetutils    msys-less         msys-libarchive 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-libiconv     msys-libtool      msys-libxml2      msys-lndir        msys-lpr-enhanced 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-m4           msys-make         msys-man          msys-minires      msys-mintty 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-mktemp       msys-openssh      msys-openssl      msys-patch        msys-zlib 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-popt         msys-rebase       msys-regex        msys-rxvt         msys-sed 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-tar          msys-termcap      msys-texinfo      msys-unzip        msys-vim 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-wget         msys-xz           msys-zip          msys-autogen      msys-findutils 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% msys-perl         
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% mingw32-autotools mingw32-make      mingw32-gdb       mingw32-bsdtar    mingw32-gendef 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% mingw-get         
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% 
set MINGW_GET_TARGETS=%MINGW_GET_TARGETS% libgomp           libstdc++
%MINGW_GET% install %MINGW_GET_TARGETS%



rem Source
mkdir "%SOURCEDIR%" > nul 2>&1
cd /d "%SOURCEDIR%"
%MINGW_GET% --all-related source %MINGW_GET_TARGETS%
%MINGW_GET% --all-related licence %MINGW_GET_TARGETS%
cd /d ".."
"%TOOLSBINDIR%\rm" -f "..\..\ossbuild-env-msys-src.7z"
7za a -t7z "..\..\ossbuild-env-msys-src.7z" ossbuild-env-src
mkdir "..\..\install\bin\Release\en-us"
copy /Y "..\..\ossbuild-env-msys-src.7z" "..\..\install\bin\Release\en-us\"
rem Remove the downloaded source from the mingw-get cache. It's available as a separate download.
"%TOOLSBINDIR%\rm" -rf "%MINGWDIR%\var\cache\mingw-get\source\"

rem Cleanup
cd /d "%TMPDIR%"
call :clean mingw-pexports-bin
call :clean mingw-pexports-doc
call :clean mingw-pexports-lic
call :clean mingw-get-bin
call :clean mingw-get-lic
call :clean mingw-get-pkginfo-bin

del ruby.7z

if "%X86BUILD%" == "1" (
	call :clean ossbuild-w64-x86-bin
)

if "%X64BUILD%" == "1" (
	call :clean ossbuild-w64-x86_64-bin
)

if "%GCCBUILD%" == "1" (
	call :clean ossbuild-w64-x86-bin
)

if "%GCCBUILD%" neq "1" (
	del git.7z
)

del mingw-gettext-runtime-bin.zip
del mingw-glib-dll.zip
del mingw-pkg-config-bin.zip
del mingw-pkg-config-dev.zip

rem Clean gettext libs and includes that we don't want hanging around
"%TOOLSBINDIR%\rm" -rf "%MSYSDIR%\lib\lib*"
"%TOOLSBINDIR%\rm" -rf "%MSYSDIR%\include\*"

rem Remove temp directory
cd /d "%TOPDIR%"
"%TOOLSBINDIR%\rm" -rf "%TMPDIR%"

rem Move to known directory
cd /d "%MSYSDIR%"

rem Make a shortcut to our shell
if "%MULTIPLATFORMBUILD%" neq "1" (
	"%TOOLSBINDIR%\mklink" "%SHORTCUTDIR%\msys-%SHORTCUT_SUFFIX%.bat.lnk" "/q" "%DEST_MSYS_DIR%\msys.bat"
) else (
	"%TOOLSBINDIR%\mklink" "%SHORTCUTDIR%\msys-x86.bat.lnk" "/q" "%DEST_MSYS_DIR%\msys-x86.bat"
	"%TOOLSBINDIR%\mklink" "%SHORTCUTDIR%\msys-x86_64.bat.lnk" "/q" "%DEST_MSYS_DIR%\msys-x86_64.bat"
)

rem Execute the setup-env script after we're done
"%MSYSDIR%\bin\sh.exe" --login "%WINDOWSENVDIR%\setup-env.sh"
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
