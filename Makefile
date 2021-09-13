# Copyright 2021 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Various FIDL C++ bindings tests that can be built against various versions
# of the FIDL SDK/IDK with various flags.

# What configuration are we building?
CONFIG=cpp14
ARCH=x64
CXXSTD=c++14

# Flags for the C++ compiler
CXXFLAGS=--target=x86_64-unknown-fuchsia \
	-std=${CXXSTD} \
	-fno-exceptions -fno-rtti \
	-Wall -Wextra-semi -Wnewline-eof -Wshadow -Werror 

# Flags for the linker
LDFLAGS=--target=x86_64-unknown-fuchsia

# What are the tests?
SOURCES=tests/hello.cc

# Toolchain
CXX=clang++
LD=clang++

# How to build & include GoogleTest
SOURCES += googletest/googletest/src/gtest-all.cc \
	googletest/googletest/src/gtest_main.cc
CXXFLAGS += -DGTEST_OS_FUCHSIA \
	-Igoogletest/googletest/include -Igoogletest/googletest

# Where is the SDK?
ifeq (${SDK},)
	SDK=sdk
endif

# Where is the sysroot?
SDK_SYSROOT = ${SDK}/arch/${ARCH}/sysroot
CXXFLAGS += --sysroot=${SDK_SYSROOT} -isystem ${SDK_SYSROOT}/include
LDFLAGS += --sysroot=${SDK_SYSROOT}


# What packages do we need from the SDK?
SDK_PKGS=fdio zx

# How does that manifest in our build?
SDK_PKG_DIRS = $(addprefix ${SDK}/pkg/,${SDK_PKGS})
CXXFLAGS += $(addprefix -I,$(addsuffix /include,${SDK_PKG_DIRS}))
SOURCES += $(wildcard $(addsuffix /*.cc,${SDK_PKG_DIRS}))
LDFLAGS += -L${SDK}/arch/${ARCH}/lib -lzircon -lfdio


# What are we building
OUT=out/${CONFIG}-${ARCH}
OBJECTS=$(addprefix ${OUT}/,$(SOURCES:.cc=.o))
BINARY=${OUT}/fidl_tests


build: ${BINARY}

${BINARY}: ${OBJECTS}
	${LD} ${LDFLAGS} -o $@ $^

${OUT}/%.o: %.cc Makefile
	@mkdir -p $(dir $@)
	${CXX} ${CXXFLAGS} -c -o $@ $<


clean:
	rm -rf "${OUT}"

.PHONY: clean out-dir
