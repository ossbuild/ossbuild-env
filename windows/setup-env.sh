#!/bin/sh

CURR_DIR=`pwd`
TOP=$(dirname $0)/.
ROOT=$( (cd "$TOP" && pwd) )

#Install jhbuild
echo Installing jhbuild...
cd ~/
mkdir jhbuild && cd jhbuild
git clone http://git.gitorious.org/~ylatuya/jhbuild/ylatuyas-jhbuild.git .
cp -fp `cd / && pwd -W`/../packages/jhbuild/Makefile.windows .
cp -fp `cd / && pwd -W`/../packages/jhbuild/sanitycheck.py ./jhbuild/commands/sanitycheck.py
make -f Makefile.windows install PREFIX=/mingw
cd ../ && rm -rf jhbuild

#Add env var to profile
echo Modifying the default user profile...
echo 'export INTLTOOL_PERL=/opt/strawberry-perl/perl/bin/perl' >> /etc/profile
