// Copyright 2021 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include <sdktest.h>

TEST(FlexibleEnum, Comparision) {
  using fidl::sdktest::FlexibleEnum;
  FlexibleEnum fe_foo = FlexibleEnum::FOO;
  FlexibleEnum fe_invalid;

  EXPECT_EQ(fe_foo, FlexibleEnum::FOO);
  EXPECT_NE(fe_foo, FlexibleEnum::BAR);
  EXPECT_NE(fe_foo, fe_invalid);
}


TEST(FlexibleEnum, Switch) {
  using fidl::sdktest::FlexibleEnum;
  FlexibleEnum fe_foo = FlexibleEnum::FOO;

  switch (fe_foo) {
    case FlexibleEnum::FOO:
      break;

    case FlexibleEnum::BAR:
      ASSERT_TRUE(false);
      break;

    default:
      ASSERT_TRUE(false);
      break;
  }
}
