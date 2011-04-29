#!/bin/bash

#Save off the original PATH
export OSSBUILD_ORIG_PATH=$PATH

#Move up 1 directory to locate where the OSSBuild env was installed.
OSSBUILD_DIR=`cd / && pwd -W`/../

#Export some important directories as env vars
export OSSBUILD_DIR=`cd $OSSBUILD_DIR && pwd -W`
export OSSBUILD_HOME_DIR=$OSSBUILD_DIR/home
export OSSBUILD_BUILD_DIR=$OSSBUILD_DIR/build
export OSSBUILD_PKG_DIR=$OSSBUILD_DIR/pkg
export OSSBUILD_PKG_REG_DIR=$OSSBUILD_PKG_DIR/reg
export OSSBUILD_PKG_DEV_DIR=$OSSBUILD_PKG_DIR/dev
export OSSBUILD_PKG_SYS_DIR=$OSSBUILD_PKG_DIR/sys
export OSSBUILD_BUILD_PKG_DIR=$OSSBUILD_BUILD_DIR/pkg
export OSSBUILD_BUILD_SRC_DIR=$OSSBUILD_BUILD_DIR/src
export OSSBUILD_BUILD_OBJ_DIR=$OSSBUILD_BUILD_DIR/obj/windows/${OSSBUILD_ARCH:=x86}
export OSSBUILD_BUILD_STAGING_DIR=$OSSBUILD_BUILD_DIR/staging/windows/${OSSBUILD_ARCH:=x86}

export OSSBUILD_WIX_HEAT=
export OSSBUILD_WIX_BIN_DIR=
export OSSBUILD_WIX_HEAT_DEFAULT_OPTS="-sw5150 -nologo -ag -sreg -scom -svb6 -sfrag -template fragment "

export OSSBUILD_MSVC_LIB=
export OSSBUILD_MSVC_IDE_DIR=
export OSSBUILD_MSVC_TOOLS_DIR=
export OSSBUILD_MSVC_COMMON_TOOLS_DIR=

#Configure some mount points.
if ! mount | grep -q /ossbuild; then 
	mount "$OSSBUILD_DIR" /ossbuild
fi
if ! mount | grep -q /home; then 
	mount "$OSSBUILD_HOME_DIR" /home
fi
if ! mount | grep -q /build; then 
	mount "$OSSBUILD_BUILD_DIR" /build
fi
if ! mount | grep -q /pkg; then 
	mount "$OSSBUILD_PKG_DIR" /pkg
fi

cd "$HOME"

#Create jhbuild config file.
if [ ! -e .jhbuildrc ]; then
	touch .jhbuildrc
fi

#Set intltool's perl
export INTLTOOL_PERL=/opt/strawberry-perl/perl/bin/perl

#Validate a proper WiX installation.
if [ -z "${WIX}" ]; then 
	echo "WARNING: OSSBuild requires WiX v3.5 or later to properly generate Windows developer merge module (msm) packages."
else
	if [ ! -d "${WIX}bin" ]; then
		echo "WARNING: Unable to locate the WiX bin/ directory. OSSBuild requires WiX v3.5 or later to be properly installed."
	else
		if [ ! -e "${WIX}bin/heat.exe" ]; then 
			echo "WARNING: Unable to locate the WiX heat.exe application for generating WiX scripts. OSSBuild requires WiX v3.5 or later to be properly installed."
		else
			export OSSBUILD_WIX_BIN_DIR=`cd "${WIX}bin" && pwd -W`
			export OSSBUILD_WIX_HEAT=${OSSBUILD_WIX_BIN_DIR}/heat.exe
		fi
	fi
fi

#Check for Microsoft's lib.exe and other tools (cl.exe, etc.).
SUPPORTED_MSVC_COMMON_TOOLS=( VS100COMNTOOLS VS90COMNTOOLS )
for MSVC_COMMON_TOOLS in ${SUPPORTED_MSVC_COMMON_TOOLS[@]}
do
	#Expand the string env variable to its actual value.
	MSVC_COMMON_TOOLS=${!MSVC_COMMON_TOOLS}
	
	if ([ -d "${MSVC_COMMON_TOOLS}" ]) && ([ -d "${MSVC_COMMON_TOOLS}../IDE/" ]) && ([ -d "${MSVC_COMMON_TOOLS}../../VC/bin/" ]); then 
		export OSSBUILD_MSVC_COMMON_TOOLS_DIR=`cd "${MSVC_COMMON_TOOLS}" && pwd -W`
		export OSSBUILD_MSVC_IDE_DIR=`cd "${MSVC_COMMON_TOOLS}" && cd "../IDE/" && pwd -W`
		export OSSBUILD_MSVC_TOOLS_DIR=`cd "${MSVC_COMMON_TOOLS}" && cd "../../VC/bin/" && pwd -W`
		export OSSBUILD_MSVC_LIB=${OSSBUILD_MSVC_TOOLS_DIR}/lib.exe
		break
	fi 
done

if [ "x${OSSBUILD_MSVC_TOOLS_DIR}" == "x" ]; then 
	echo "WARNING: OSSBuild requires Microsoft developer tools to be installed to properly generate Visual C++-compatible lib (.lib) files. Please install Visual Studio or an equivalent platform SDK."
else
	#Augment path to include some libraries needed by lib.exe.
	#Be sure and use msys-style paths when augmenting PATH.
	MSVC_IDE_DIR=`cd "${OSSBUILD_MSVC_IDE_DIR}" && pwd`
	MSVC_TOOLS_DIR=`cd "${OSSBUILD_MSVC_TOOLS_DIR}" && pwd`
	export PATH=$PATH:$MSVC_IDE_DIR:$MSVC_TOOLS_DIR
fi
