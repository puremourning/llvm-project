; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mcpu=skx | FileCheck %s

define <8 x float> @select_and_v8i1(<8 x i1> %a, <8 x i1> %b, <8 x i1> %c, <8 x float> %d) {
; CHECK-LABEL: select_and_v8i1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpsllw $15, %xmm2, %xmm4
; CHECK-NEXT:    vpsllw $15, %xmm0, %xmm0
; CHECK-NEXT:    vpmovw2m %xmm0, %k1
; CHECK-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    vpcmpgtw %xmm4, %xmm0, %k0 {%k1}
; CHECK-NEXT:    vpand %xmm1, %xmm2, %xmm0
; CHECK-NEXT:    vpsllw $15, %xmm0, %xmm0
; CHECK-NEXT:    vpmovw2m %xmm0, %k2
; CHECK-NEXT:    kandnb %k2, %k1, %k1
; CHECK-NEXT:    korb %k1, %k0, %k1
; CHECK-NEXT:    vbroadcastss {{.*#+}} ymm0 = [1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0]
; CHECK-NEXT:    vmovaps %ymm3, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %t2 = select <8 x i1> %a, <8 x i1> <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>, <8 x i1> %b
  %t3 = and <8 x i1> %c, %t2
  %t4= select <8 x i1> %t3, <8 x float> %d, <8 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  ret <8 x float> %t4
}

define <8 x float> @select_and_v8i1_2(i8 %m1, i8 %m2, i8 %m3, <8 x float> %d) {
; CHECK-LABEL: select_and_v8i1_2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    kmovd %edi, %k0
; CHECK-NEXT:    andl %edx, %esi
; CHECK-NEXT:    kmovd %edx, %k1
; CHECK-NEXT:    kandb %k0, %k1, %k1
; CHECK-NEXT:    kmovd %esi, %k2
; CHECK-NEXT:    kandnb %k2, %k0, %k0
; CHECK-NEXT:    korb %k0, %k1, %k1
; CHECK-NEXT:    vbroadcastss {{.*#+}} ymm1 = [1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0]
; CHECK-NEXT:    vmovaps %ymm0, %ymm1 {%k1}
; CHECK-NEXT:    vmovaps %ymm1, %ymm0
; CHECK-NEXT:    retq
  %a = bitcast i8 %m1 to <8 x i1>
  %b = bitcast i8 %m2 to <8 x i1>
  %c = bitcast i8 %m3 to <8 x i1>
  %t2 = select <8 x i1> %a, <8 x i1> <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>, <8 x i1> %b
  %t3 = and <8 x i1> %c, %t2
  %t4= select <8 x i1> %t3, <8 x float> %d, <8 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  ret <8 x float> %t4
}

define <8 x float> @select_and_v8i1_3(<8 x i16> %m1, <8 x i16> %m2, <8 x i16> %m3, <8 x float> %d) {
; CHECK-LABEL: select_and_v8i1_3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpcmpeqw %xmm2, %xmm1, %k1
; CHECK-NEXT:    vpcmpeqw %xmm1, %xmm0, %k0 {%k1}
; CHECK-NEXT:    vpcmpeqw %xmm2, %xmm0, %k1 {%k1}
; CHECK-NEXT:    vpcmpneqw %xmm1, %xmm0, %k1 {%k1}
; CHECK-NEXT:    korb %k1, %k0, %k1
; CHECK-NEXT:    vbroadcastss {{.*#+}} ymm0 = [1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0]
; CHECK-NEXT:    vmovaps %ymm3, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %a = icmp eq <8 x i16> %m1, %m2
  %b = icmp eq <8 x i16> %m1, %m3
  %c = icmp eq <8 x i16> %m2, %m3
  %t2 = select <8 x i1> %a, <8 x i1> <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>, <8 x i1> %b
  %t3 = and <8 x i1> %c, %t2
  %t4= select <8 x i1> %t3, <8 x float> %d, <8 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  ret <8 x float> %t4
}

define <8 x float> @select_or_v8i1(<8 x i1> %a, <8 x i1> %b, <8 x i1> %c, <8 x float> %d) {
; CHECK-LABEL: select_or_v8i1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpsllw $15, %xmm2, %xmm4
; CHECK-NEXT:    vpsllw $15, %xmm0, %xmm0
; CHECK-NEXT:    vpmovw2m %xmm0, %k1
; CHECK-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    vpcmpgtw %xmm4, %xmm0, %k0 {%k1}
; CHECK-NEXT:    vpor %xmm1, %xmm2, %xmm0
; CHECK-NEXT:    vpsllw $15, %xmm0, %xmm0
; CHECK-NEXT:    vpmovw2m %xmm0, %k2
; CHECK-NEXT:    kandnb %k2, %k1, %k1
; CHECK-NEXT:    korb %k1, %k0, %k1
; CHECK-NEXT:    vbroadcastss {{.*#+}} ymm0 = [1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0]
; CHECK-NEXT:    vmovaps %ymm3, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %t2 = select <8 x i1> %a, <8 x i1> <i1 0, i1 0, i1 0, i1 0, i1 0, i1 0, i1 0, i1 0>, <8 x i1> %b
  %t3 = or <8 x i1> %c, %t2
  %t4= select <8 x i1> %t3, <8 x float> %d, <8 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  ret <8 x float> %t4
}

define <8 x float> @select_or_v8i1_2(i8 %m1, i8 %m2, i8 %m3, <8 x float> %d) {
; CHECK-LABEL: select_or_v8i1_2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    kmovd %edi, %k0
; CHECK-NEXT:    orl %edx, %esi
; CHECK-NEXT:    kmovd %edx, %k1
; CHECK-NEXT:    kandb %k0, %k1, %k1
; CHECK-NEXT:    kmovd %esi, %k2
; CHECK-NEXT:    kandnb %k2, %k0, %k0
; CHECK-NEXT:    korb %k0, %k1, %k1
; CHECK-NEXT:    vbroadcastss {{.*#+}} ymm1 = [1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0]
; CHECK-NEXT:    vmovaps %ymm0, %ymm1 {%k1}
; CHECK-NEXT:    vmovaps %ymm1, %ymm0
; CHECK-NEXT:    retq
  %a = bitcast i8 %m1 to <8 x i1>
  %b = bitcast i8 %m2 to <8 x i1>
  %c = bitcast i8 %m3 to <8 x i1>
  %t2 = select <8 x i1> %a, <8 x i1> <i1 0, i1 0, i1 0, i1 0, i1 0, i1 0, i1 0, i1 0>, <8 x i1> %b
  %t3 = or <8 x i1> %c, %t2
  %t4= select <8 x i1> %t3, <8 x float> %d, <8 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  ret <8 x float> %t4
}

define <8 x float> @select_or_v8i1_3(<8 x i16> %m1, <8 x i16> %m2, <8 x i16> %m3, <8 x float> %d) {
; CHECK-LABEL: select_or_v8i1_3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpcmpeqw %xmm2, %xmm0, %k0
; CHECK-NEXT:    vpcmpeqw %xmm2, %xmm1, %k1
; CHECK-NEXT:    korb %k0, %k1, %k2
; CHECK-NEXT:    vpcmpneqw %xmm1, %xmm0, %k0 {%k2}
; CHECK-NEXT:    vpcmpeqw %xmm1, %xmm0, %k1 {%k1}
; CHECK-NEXT:    korb %k0, %k1, %k1
; CHECK-NEXT:    vbroadcastss {{.*#+}} ymm0 = [1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0,1.0E+0]
; CHECK-NEXT:    vmovaps %ymm3, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %a = icmp eq <8 x i16> %m1, %m2
  %b = icmp eq <8 x i16> %m1, %m3
  %c = icmp eq <8 x i16> %m2, %m3
  %t2 = select <8 x i1> %a, <8 x i1> <i1 0, i1 0, i1 0, i1 0, i1 0, i1 0, i1 0, i1 0>, <8 x i1> %b
  %t3 = or <8 x i1> %c, %t2
  %t4= select <8 x i1> %t3, <8 x float> %d, <8 x float> <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
  ret <8 x float> %t4
}
