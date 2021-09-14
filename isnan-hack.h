// Copyright 2021 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#pragma once

// This works around some really weird issues with libcpp & musl & googletest

#include <math.h>

#ifdef isnan
inline bool isnan_impl(double n) { return isnan(n); }
#undef isnan
inline bool isnan(double n) { return isnan_impl(n); }
#endif
