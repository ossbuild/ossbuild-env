#!/bin/sh

CURR_DIR=`pwd`
TOP=$(dirname $0)/.
ROOT=$( (cd "$TOP" && pwd) )
PACKAGES=`cd / && pwd -W`/../packages

#Install jhbuild
echo Installing jhbuild...
cd ~/
mkdir jhbuild && cd jhbuild
git clone http://git.gitorious.org/~ylatuya/jhbuild/ylatuyas-jhbuild.git .
cp -fp $PACKAGES/jhbuild/Makefile.ossbuild .
git apply --ignore-whitespace --ignore-space-change $PACKAGES/jhbuild/msys.patch
make -f Makefile.ossbuild install PREFIX=/mingw
cd ../ && rm -rf jhbuild

#Add env var to profile
echo Modifying the default user profile...
mkdir -p /etc/profile.d/
cp -p -f $PACKAGES/msys/ossbuild.sh /etc/profile.d/ossbuild.sh
mkdir -p /etc/profile.d/ossbuild/
cp -p -f $PACKAGES/msys/ossbuild/* /etc/profile.d/ossbuild/

jhbuild_defaults=/mingw/lib/python/site-packages/jhbuild/jhbuild/defaults.jhbuildrc
echo Modifying jhbuild defaults...
echo " " >> $jhbuild_defaults
#modulesets_dir='E:/Development/ossbuild-git/ossbuild-packages/packages/'
#moduleset = modulesets_dir + 'ossbuild.modules'
echo "moduleset = 'https://github.com/ossbuild/ossbuild-packages/raw/master/packages/ossbuild.modules'" >> $jhbuild_defaults
echo "modules = ['ossbuild']" >> $jhbuild_defaults
echo "use_local_modulesets = True" >> $jhbuild_defaults
echo "build_policy = 'updated'" >> $jhbuild_defaults
echo "alwaysautogen = True" >> $jhbuild_defaults
echo "module_extra_env['msys-intltool']={ 'PERL': os.environ['INTLTOOL_PERL'] }" >> $jhbuild_defaults
echo "prefix = os.environ['OSSBUILD_BUILD_STAGING_DIR'] + '/'" >> $jhbuild_defaults
echo "checkoutroot = os.environ['OSSBUILD_BUILD_SRC_DIR']" >> $jhbuild_defaults
echo "tarballdir = os.environ['OSSBUILD_BUILD_PKG_DIR']" >> $jhbuild_defaults
echo "buildroot = os.environ['OSSBUILD_BUILD_OBJ_DIR']" >> $jhbuild_defaults
echo "os.environ['CFLAGS'] = '-m32 -mms-bitfields -pipe -DWINVER=0x0501'" >> $jhbuild_defaults
echo "os.environ['CPPFLAGS'] = '-DMINGW64 -D__MINGW64__ -DMINGW32 -D__MINGW32__'" >> $jhbuild_defaults
echo "os.environ['LDFLAGS'] = '-Wl,--enable-auto-image-base -Wl,--enable-auto-import -Wl,--enable-runtime-pseudo-reloc-v2 -Wl,--kill-at '" >> $jhbuild_defaults
echo "os.environ['CXXFLAGS'] = os.environ['CFLAGS']" >> $jhbuild_defaults
