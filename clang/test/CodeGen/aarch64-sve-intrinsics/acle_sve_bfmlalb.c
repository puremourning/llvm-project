// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// REQUIRES: aarch64-registered-target

// RUN: %clang_cc1 -triple aarch64-none-linux-gnu -target-feature +sve -target-feature +bf16  -S -disable-O0-optnone -Werror -Wall -emit-llvm -o - %s | opt -S -passes=mem2reg,tailcallelim | FileCheck %s
// RUN: %clang_cc1 -triple aarch64-none-linux-gnu -target-feature +sve -target-feature +bf16  -S -disable-O0-optnone -Werror -Wall -emit-llvm -o - -x c++ %s | opt -S -passes=mem2reg,tailcallelim | FileCheck %s -check-prefix=CPP-CHECK
// RUN: %clang_cc1 -DSVE_OVERLOADED_FORMS -triple aarch64-none-linux-gnu -target-feature +sve -target-feature +bf16 -S -disable-O0-optnone -Werror -Wall -emit-llvm -o - %s | opt -S -passes=mem2reg,tailcallelim | FileCheck %s
// RUN: %clang_cc1 -DSVE_OVERLOADED_FORMS -triple aarch64-none-linux-gnu -target-feature +sve -target-feature +bf16 -S -disable-O0-optnone -Werror -Wall -emit-llvm -o - -x c++ %s | opt -S -passes=mem2reg,tailcallelim | FileCheck %s -check-prefix=CPP-CHECK

#include <arm_sve.h>

#ifdef SVE_OVERLOADED_FORMS
// A simple used,unused... macro, long enough to represent any SVE builtin.
#define SVE_ACLE_FUNC(A1, A2_UNUSED, A3, A4_UNUSED) A1##A3
#else
#define SVE_ACLE_FUNC(A1, A2, A3, A4) A1##A2##A3##A4
#endif

// CHECK-LABEL: @test_svbfmlalb_f32(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <vscale x 4 x float> @llvm.aarch64.sve.bfmlalb(<vscale x 4 x float> [[X:%.*]], <vscale x 8 x bfloat> [[Y:%.*]], <vscale x 8 x bfloat> [[Z:%.*]])
// CHECK-NEXT:    ret <vscale x 4 x float> [[TMP0]]
//
// CPP-CHECK-LABEL: @_Z18test_svbfmlalb_f32u13__SVFloat32_tu14__SVBFloat16_tu14__SVBFloat16_t(
// CPP-CHECK-NEXT:  entry:
// CPP-CHECK-NEXT:    [[TMP0:%.*]] = tail call <vscale x 4 x float> @llvm.aarch64.sve.bfmlalb(<vscale x 4 x float> [[X:%.*]], <vscale x 8 x bfloat> [[Y:%.*]], <vscale x 8 x bfloat> [[Z:%.*]])
// CPP-CHECK-NEXT:    ret <vscale x 4 x float> [[TMP0]]
//
svfloat32_t test_svbfmlalb_f32(svfloat32_t x, svbfloat16_t y, svbfloat16_t z) {
  return SVE_ACLE_FUNC(svbfmlalb, _f32, , )(x, y, z);
}

// CHECK-LABEL: @test_bfmlalb_lane_0_f32(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <vscale x 4 x float> @llvm.aarch64.sve.bfmlalb.lane.v2(<vscale x 4 x float> [[X:%.*]], <vscale x 8 x bfloat> [[Y:%.*]], <vscale x 8 x bfloat> [[Z:%.*]], i32 0)
// CHECK-NEXT:    ret <vscale x 4 x float> [[TMP0]]
//
// CPP-CHECK-LABEL: @_Z23test_bfmlalb_lane_0_f32u13__SVFloat32_tu14__SVBFloat16_tu14__SVBFloat16_t(
// CPP-CHECK-NEXT:  entry:
// CPP-CHECK-NEXT:    [[TMP0:%.*]] = tail call <vscale x 4 x float> @llvm.aarch64.sve.bfmlalb.lane.v2(<vscale x 4 x float> [[X:%.*]], <vscale x 8 x bfloat> [[Y:%.*]], <vscale x 8 x bfloat> [[Z:%.*]], i32 0)
// CPP-CHECK-NEXT:    ret <vscale x 4 x float> [[TMP0]]
//
svfloat32_t test_bfmlalb_lane_0_f32(svfloat32_t x, svbfloat16_t y, svbfloat16_t z) {
  return SVE_ACLE_FUNC(svbfmlalb_lane, _f32, , )(x, y, z, 0);
}

// CHECK-LABEL: @test_bfmlalb_lane_7_f32(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call <vscale x 4 x float> @llvm.aarch64.sve.bfmlalb.lane.v2(<vscale x 4 x float> [[X:%.*]], <vscale x 8 x bfloat> [[Y:%.*]], <vscale x 8 x bfloat> [[Z:%.*]], i32 7)
// CHECK-NEXT:    ret <vscale x 4 x float> [[TMP0]]
//
// CPP-CHECK-LABEL: @_Z23test_bfmlalb_lane_7_f32u13__SVFloat32_tu14__SVBFloat16_tu14__SVBFloat16_t(
// CPP-CHECK-NEXT:  entry:
// CPP-CHECK-NEXT:    [[TMP0:%.*]] = tail call <vscale x 4 x float> @llvm.aarch64.sve.bfmlalb.lane.v2(<vscale x 4 x float> [[X:%.*]], <vscale x 8 x bfloat> [[Y:%.*]], <vscale x 8 x bfloat> [[Z:%.*]], i32 7)
// CPP-CHECK-NEXT:    ret <vscale x 4 x float> [[TMP0]]
//
svfloat32_t test_bfmlalb_lane_7_f32(svfloat32_t x, svbfloat16_t y, svbfloat16_t z) {
  return SVE_ACLE_FUNC(svbfmlalb_lane, _f32, , )(x, y, z, 7);
}

// CHECK-LABEL: @test_bfmlalb_n_f32(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[DOTSPLATINSERT:%.*]] = insertelement <vscale x 8 x bfloat> poison, bfloat [[Z:%.*]], i64 0
// CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <vscale x 8 x bfloat> [[DOTSPLATINSERT]], <vscale x 8 x bfloat> poison, <vscale x 8 x i32> zeroinitializer
// CHECK-NEXT:    [[TMP1:%.*]] = tail call <vscale x 4 x float> @llvm.aarch64.sve.bfmlalb(<vscale x 4 x float> [[X:%.*]], <vscale x 8 x bfloat> [[Y:%.*]], <vscale x 8 x bfloat> [[TMP0]])
// CHECK-NEXT:    ret <vscale x 4 x float> [[TMP1]]
//
// CPP-CHECK-LABEL: @_Z18test_bfmlalb_n_f32u13__SVFloat32_tu14__SVBFloat16_tu6__bf16(
// CPP-CHECK-NEXT:  entry:
// CPP-CHECK-NEXT:    [[DOTSPLATINSERT:%.*]] = insertelement <vscale x 8 x bfloat> poison, bfloat [[Z:%.*]], i64 0
// CPP-CHECK-NEXT:    [[TMP0:%.*]] = shufflevector <vscale x 8 x bfloat> [[DOTSPLATINSERT]], <vscale x 8 x bfloat> poison, <vscale x 8 x i32> zeroinitializer
// CPP-CHECK-NEXT:    [[TMP1:%.*]] = tail call <vscale x 4 x float> @llvm.aarch64.sve.bfmlalb(<vscale x 4 x float> [[X:%.*]], <vscale x 8 x bfloat> [[Y:%.*]], <vscale x 8 x bfloat> [[TMP0]])
// CPP-CHECK-NEXT:    ret <vscale x 4 x float> [[TMP1]]
//
svfloat32_t test_bfmlalb_n_f32(svfloat32_t x, svbfloat16_t y, bfloat16_t z) {
  return SVE_ACLE_FUNC(svbfmlalb, _n_f32, , )(x, y, z);
}
