# Copyright 2021 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Various FIDL C++ bindings tests that can be built against various versions
# of the FIDL SDK/IDK with various flags.

ifeq (${CONFIG},)
# If no CONFIG is specified, build with both c++17 and c++14.
all:
	make CONFIG=cpp17
	make CONFIG=cpp14

clean:
	make CONFIG=cpp17 clean
	make CONFIG=cpp14 clean

else

# What configuration are we building?
ARCH=x64
ifeq (${CONFIG},cpp14)
CXXSTD=c++14
else
CXXSTD=c++17
endif

# Where are we building this?
OUT=out/${CONFIG}-${ARCH}

# Flags for the C and C++ compilers
CFLAGS=--target=x86_64-unknown-fuchsia \
	-Wall -Wextra-semi -Wnewline-eof -Wshadow -Werror 

# Flags for the C++ compiler
CXXFLAGS=-std=${CXXSTD} -fno-exceptions -fno-rtti \
	-include isnan-hack.h

# Flags for the linker
LDFLAGS=--target=x86_64-unknown-fuchsia

# What are the tests?
SOURCES=tests/flexible-enum.cc

# Toolchain
CXX=clang++
CC=clang
LD=clang++

# How to build & include GoogleTest
SOURCES += googletest/googletest/src/gtest-all.cc \
	googletest/googletest/src/gtest_main.cc
CFLAGS += -DGTEST_OS_FUCHSIA \
	-Igoogletest/googletest/include -Igoogletest/googletest \
	-D_LIBCPP_USING_IF_EXISTS

# Where is the SDK?
ifeq (${SDK},)
	SDK=sdk
endif

# Where is the sysroot?
SDK_SYSROOT = ${SDK}/arch/${ARCH}/sysroot
CFLAGS += --sysroot=${SDK_SYSROOT} -isystem ${SDK_SYSROOT}/include
LDFLAGS += --sysroot=${SDK_SYSROOT}


# What packages do we need from the SDK?
SDK_PKGS=fdio zx fidl fidl_base stdcompat fidl_cpp fit fit-promise fidl_cpp_sync fidl_cpp_base async

# How does that manifest in our build?
SDK_PKG_DIRS = $(addprefix ${SDK}/pkg/,${SDK_PKGS})
CFLAGS += $(addprefix -I,$(addsuffix /include,${SDK_PKG_DIRS}))
SOURCES += $(wildcard $(addsuffix /*.cc,${SDK_PKG_DIRS}) $(addsuffix /*.c,${SDK_PKG_DIRS}))
LDFLAGS += -L${SDK}/arch/${ARCH}/lib -lzircon -lfdio


# What FIDL files are we building?
FIDL_SOURCES = fidl/sdktest.fidl
FIDL_IR = ${OUT}/fidl/sdktest.json
FIDLC = ${SDK}/tools/fidlc
FIDLGEN = ${SDK}/tools/fidlgen

SOURCES += ${OUT}/fidl/sdktest.cc
CFLAGS += -I${OUT}/fidl


# What are we building
OBJECTS=$(addprefix ${OUT}/,$(addsuffix .o, $(basename ${SOURCES})))
BINARY=${OUT}/fidl_tests


build: ${BINARY}

${BINARY}: ${OBJECTS}
	${LD} ${LDFLAGS} -o $@ $^

${OUT}/%.o: %.cc ${OUT}/fidl/sdktest.h
	@mkdir -p $(dir $@)
	${CXX} ${CFLAGS} ${CXXFLAGS} -c -o $@ $<

${OUT}/%.o: %.c
	@mkdir -p $(dir $@)
	${CC} ${CFLAGS} -c -o $@ $<

${FIDL_IR}: ${FIDL_SOURCES} ${FIDLC}
	${FIDLC} --json $@ --files ${FIDL_SOURCES}

${OUT}/fidl/sdktest.cc ${OUT}/fidl/sdktest.h ${OUT}/fidl/sdktest_test_base.h: ${FIDL_IR} ${FIDLGEN}
	${FIDLGEN} -json ${FIDL_IR} -output-base ${OUT}/fidl/sdktest -include-base ${OUT}/fidl

clean:
	rm -rf "${OUT}"

.PHONY: clean build

endif