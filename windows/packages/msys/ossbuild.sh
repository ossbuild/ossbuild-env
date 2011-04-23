#!/bin/bash

#Move up 2 directories to locate where the OSSBuild env was installed.
OSSBUILD_DIR=`cd / && pwd -W`/../../

#Export some important directories as env vars
export OSSBUILD_DIR=`cd $OSSBUILD_DIR && pwd -W`
export OSSBUILD_HOME_DIR=$OSSBUILD_DIR/Home
export OSSBUILD_SRC_DIR=$OSSBUILD_DIR/Src
export OSSBUILD_BUILD_DIR=$OSSBUILD_DIR/Build
export OSSBUILD_PACKAGES_DIR=$OSSBUILD_DIR/Packages

#Configure some mount points.
if ! mount | grep -q /ossbuild; then 
	mount "$OSSBUILD_DIR" /ossbuild
fi
if ! mount | grep -q /home; then 
	mount "$OSSBUILD_HOME_DIR" /home
fi
if ! mount | grep -q /src; then 
	mount "$OSSBUILD_SRC_DIR" /src
fi
if ! mount | grep -q /build; then 
	mount "$OSSBUILD_BUILD_DIR" /build
fi
if ! mount | grep -q /packages; then 
	mount "$OSSBUILD_PACKAGES_DIR" /packages
fi

cd "$HOME"

#Create jhbuild config file.
if [ ! -e .jhbuildrc ]; then
	touch .jhbuildrc
fi

#Set intltool's perl
export INTLTOOL_PERL=/opt/strawberry-perl/perl/bin/perl
