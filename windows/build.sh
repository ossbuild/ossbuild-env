#!/bin/sh

CURR_DIR=`pwd`
TOP=$(dirname $0)/.
ROOT=$( (cd "$TOP" && pwd) )
GCC_PATH=`which gcc`
GCC_DIR=$(dirname $GCC_PATH)

PKG_DIR=$ROOT/packages
BUILD_DIR=$ROOT/build

SRC_DIR=$BUILD_DIR/src
INT_DIR=$BUILD_DIR/obj
INSTALL_DIR=$BUILD_DIR

BIN_DIR=$INSTALL_DIR/bin
LIB_DIR=$INSTALL_DIR/lib
ETC_DIR=$INSTALL_DIR/etc
SHARED_DIR=$INSTALL_DIR/shared

#Changes uname from MINGW32 to MSYS
MSYSTEM=MSYS

MAKE="make -j2"
NULL="/dev/null"
TAR="tar --no-same-owner --strip-components=1 -xjv "

cd $GCC_DIR/
ln -s gcc gcc-4 2>$NULL
ln -s g++ g++-4 2>$NULL

cd $ROOT
mkdir -p $BUILD_DIR
mkdir -p $SRC_DIR
mkdir -p $INT_DIR
mkdir -p $INSTALL_DIR



# #Perl
# if [ ! -d $SRC_DIR/perl/ ]; then 
	# echo Extracting perl...
	
	# mkdir -p $SRC_DIR/perl/
	# $TAR -C $SRC_DIR/perl/ -f $PKG_DIR/perl/perl.tar.bz2 > NUL
# fi

# #if [ ! -d $INT_DIR/perl/ ]; then 
	# echo Building perl...
	
	# mkdir -p $INT_DIR/perl/
	# cd $INT_DIR/perl/

	# #Copy over the source since it needs to be built in the same 
	# #directory as the source or it won't compile. Copying it helps 
	# #ensure that we don't muddy the original source.
	# if [ ! -f $INT_DIR/perl/build ]; then 
		# echo Copying from source...
		# cp -p $SRC_DIR/perl/* .
	# fi

	
	# #./build all
	# cc=gcc ld=gcc ./build all
# #fi

  
