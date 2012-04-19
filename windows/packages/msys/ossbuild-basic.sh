#!/bin/bash

###############################################################################
#                                                                             #
#                          OSSBuild Environment                               #
#                                                                             #
# Configures the OSSBuild environment by setting important environment        #
# variables and adding Microsoft tools to the PATH. Also sets up some         #
# convenient mount points as well as some other misc. janitorial work.        #
#                                                                             #
###############################################################################

#Save off the original PATH
export OSSBUILD_ORIG_PATH=$PATH

#Move up 1 directory to locate where the OSSBuild env was installed.
OSSBUILD_DIR=`cd / && pwd -W`/../

#Export some important directories as env vars
export OSSBUILD_DIR=`cd $OSSBUILD_DIR && pwd -W`
export OSSBUILD_HOME_DIR=$OSSBUILD_DIR/home

#Configure some mount points.
if ! mount | grep -q /ossbuild; then 
	mount "$OSSBUILD_DIR" /ossbuild
fi
if ! mount | grep -q /home; then 
	mount "$OSSBUILD_HOME_DIR" /home
fi

cd "$HOME"

#Execute ossbuild scripts (e.g. setup ms tool environment).
for i in /etc/profile.d/ossbuild/*.sh ; do
	if [ -f $i ]; then
		. $i
	fi
done
