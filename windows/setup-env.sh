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
git apply $PACKAGES/jhbuild/msys.patch
make -f Makefile.ossbuild install PREFIX=/mingw
cd ../ && rm -rf jhbuild

#Add env var to profile
profile=/etc/profile
echo Modifying the default user profile...
echo '#Move up 2 directories to locate where the OSSBuild env was installed.' >> $profile
echo 'OSSBUILD_HOME=`cd / && pwd -W`/../../' >> $profile
echo '' >> $profile
echo '#Export some important directories as env vars' >> $profile
echo 'export OSSBUILD_HOME=`cd $OSSBUILD_HOME && pwd -W`' >> $profile
echo 'export OSSBUILD_SRC=$OSSBUILD_HOME/Src' >> $profile
echo 'export OSSBUILD_BUILD=$OSSBUILD_HOME/Build' >> $profile
echo 'export OSSBUILD_PACKAGES=$OSSBUILD_HOME/Packages' >> $profile
echo '' >> $profile
echo '#Configure some mount points.' >> $profile
echo 'if ! mount | grep -q /ossbuild; then ' >> $profile
echo '	mount "$OSSBUILD_HOME" /ossbuild' >> $profile
echo 'fi' >> $profile
echo 'if ! mount | grep -q /src; then ' >> $profile
echo '	mount "$OSSBUILD_SRC" /src' >> $profile
echo 'fi' >> $profile
echo 'if ! mount | grep -q /build; then ' >> $profile
echo '	mount "$OSSBUILD_BUILD" /build' >> $profile
echo 'fi' >> $profile
echo 'if ! mount | grep -q /packages; then ' >> $profile
echo '	mount "$OSSBUILD_PACKAGES" /packages' >> $profile
echo 'fi' >> $profile
echo '' >> $profile
echo '#Create jhbuild config file.' >> $profile
echo 'if [ ! -e .jhbuildrc ]; then' >> $profile
echo '	touch .jhbuildrc' >> $profile
echo 'fi' >> $profile
echo '' >> $profile
echo "#Set intltool's perl" >> $profile
echo 'export INTLTOOL_PERL=/opt/strawberry-perl/perl/bin/perl' >> $profile

jhbuild_defaults=/mingw/lib/python/site-packages/jhbuild/jhbuild/defaults.jhbuildrc
echo Modifying jhbuild defaults...
#modulesets_dir='E:/Development/ossbuild-git/ossbuild-packages/packages/'
#moduleset = modulesets_dir + 'ossbuild.modules'
echo "modules = ['ossbuild']" >> $jhbuild_defaults
echo "use_local_modulesets = True" >> $jhbuild_defaults
echo "build_policy = 'updated'" >> $jhbuild_defaults
echo "alwaysautogen = True" >> $jhbuild_defaults
echo "module_extra_env['msys-intltool']={ 'PERL': os.environ['INTLTOOL_PERL'] }" >> $jhbuild_defaults
echo "prefix = os.environ['OSSBUILD_BUILD'] + '/'" >> $jhbuild_defaults
echo "checkoutroot = os.environ['OSSBUILD_SRC']" >> $jhbuild_defaults
echo "tarballdir = os.environ['OSSBUILD_SRC']" >> $jhbuild_defaults
echo "buildroot = os.environ['OSSBUILD_BUILD']" >> $jhbuild_defaults
echo "os.environ['CFLAGS'] = '-m32 -mms-bitfields -pipe -DWINVER=0x0501'" >> $jhbuild_defaults
echo "os.environ['CPPFLAGS'] = '-DMINGW64 -D__MINGW64__ -DMINGW32 -D__MINGW32__'" >> $jhbuild_defaults
echo "os.environ['LDFLAGS'] = '-Wl,--enable-auto-image-base -Wl,--enable-auto-import -Wl,--enable-runtime-pseudo-reloc-v2 -Wl,--kill-at '" >> $jhbuild_defaults
echo "os.environ['CXXFLAGS'] = os.environ['CFLAGS']" >> $jhbuild_defaults
