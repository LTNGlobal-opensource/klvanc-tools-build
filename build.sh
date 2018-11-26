#!/bin/sh

set -x

# Bail out if any command fails...
set -e

[ -z "$KLVANCTOOLS_REPO" ] && KLVANCTOOLS_REPO=https://github.com/dheitmueller/klvanc-tools.git
[ -z "$KLVANCTOOLS_BRANCH" ] && KLVANCTOOLS_BRANCH=player

# Dependencies
[ -z "$KLVANC_REPO" ] && KLVANC_REPO=https://github.com/LTNGlobal-opensource/libklvanc.git
#[ -z "$KLVANC_BRANCH" ] && KLVANC_BRANCH=d868ac42c327a3070194838d149c13b3830ef866
[ -z "$KLBARS_REPO" ] && KLBARS_REPO=https://github.com/dheitmueller/libklbars.git
#[ -z "$KLBARS_BRANCH" ] && KLBARS_BRANCH=d868ac42c327a3070194838d149c13b3830ef866

[ -z "$ZLIB_REPO" ] && ZLIB_REPO=https://github.com/madler/zlib
[ -z "$ZLIB_BRANCH" ] && ZLIB_BRANCH=v1.2.11

BMSDK_REPO=https://github.com/LTNGlobal-opensource/bmsdk.git
DEP_BUILDROOT=$PWD/deps-buildroot
export PKG_CONFIG_PATH=$DEP_BUILDROOT/lib/pkgconfig

# Make available the BlackMagic SDK
if [ ! -d bmsdk ]; then
    git clone $BMSDK_REPO
fi

BMSDK_10_8_5=$PWD/bmsdk/10.8.5
BMSDK_10_1_1=$PWD/bmsdk/10.1.1

mkdir -p $DEP_BUILDROOT/lib
mkdir -p $DEP_BUILDROOT/include

# Build Kernel Labs dependencies
if [ ! -d libklvanc ]; then
	git clone $KLVANC_REPO libklvanc
	cd libklvanc
	if [ "$KLVANC_BRANCH" != "" ]; then
	    echo "Switching to branch [$KLVANC_BRANCH]..."
	    git checkout $KLVANC_BRANCH
	fi
	./autogen.sh --build
	CPPFLAGS=-I${DEP_BUILDROOT}/include LDFLAGS=-L${DEP_BUILDROOT}/lib ./configure --disable-shared --prefix=${DEP_BUILDROOT}
	make
	make install
	cd ..
fi

if [ ! -d libklbars ]; then
	git clone $KLBARS_REPO libklbars
	cd libklbars
	if [ "$KLBARS_BRANCH" != "" ]; then
	    echo "Switching to branch [$KLBARS_BRANCH]..."
	    git checkout $KLBARS_BRANCH
	fi
	./autogen.sh --build
	./configure --disable-shared --prefix=${DEP_BUILDROOT}
	make
	make install
	cd ..
fi

if [ ! -d zlib ]; then
	git clone $ZLIB_REPO zlib
	cd zlib
	if [ "$ZLIB_BRANCH" != "" ]; then
	    echo "Switching to branch [$ZLIB_BRANCH]..."
	    git checkout $ZLIB_BRANCH
	fi
	./configure --static --prefix=${DEP_BUILDROOT}
	make
	make install
	cd ..
fi

if [ ! -d klvanc-tools ]; then
	git clone $KLVANCTOOLS_REPO klvanc-tools
	cd klvanc-tools
	if [ "$KLVANCTOOLS_BRANCH" != "" ]; then
	    echo "Switching to branch [$KLVANCTOOLS_BRANCH]..."
	    git checkout $KLVANCTOOLS_BRANCH
	fi
	cd ..
fi

cd klvanc-tools
./autogen.sh --build
CPPFLAGS=-I${DEP_BUILDROOT}/include LDFLAGS=-L${DEP_BUILDROOT}/lib ./configure --prefix=${DEP_BUILDROOT} --with-bmsdk=$BMSDK_10_8_5
make
