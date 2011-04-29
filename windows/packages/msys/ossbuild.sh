#!/bin/bash

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
