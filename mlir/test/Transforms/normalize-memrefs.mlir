// RUN: mlir-opt -normalize-memrefs -allow-unregistered-dialect %s | FileCheck %s

// This file tests whether the memref type having non-trivial map layouts
// are normalized to trivial (identity) layouts.

// CHECK-LABEL: func @permute()
func @permute() {
  %A = alloc() : memref<64x256xf32, affine_map<(d0, d1) -> (d1, d0)>>
  affine.for %i = 0 to 64 {
    affine.for %j = 0 to 256 {
      %1 = affine.load %A[%i, %j] : memref<64x256xf32, affine_map<(d0, d1) -> (d1, d0)>>
      "prevent.dce"(%1) : (f32) -> ()
    }
  }
  dealloc %A : memref<64x256xf32, affine_map<(d0, d1) -> (d1, d0)>>
  return
}
// The old memref alloc should disappear.
// CHECK-NOT:  memref<64x256xf32>
// CHECK:      [[MEM:%[0-9]+]] = alloc() : memref<256x64xf32>
// CHECK-NEXT: affine.for %[[I:arg[0-9]+]] = 0 to 64 {
// CHECK-NEXT:   affine.for %[[J:arg[0-9]+]] = 0 to 256 {
// CHECK-NEXT:     affine.load [[MEM]][%[[J]], %[[I]]] : memref<256x64xf32>
// CHECK-NEXT:     "prevent.dce"
// CHECK-NEXT:   }
// CHECK-NEXT: }
// CHECK-NEXT: dealloc [[MEM]]
// CHECK-NEXT: return

// CHECK-LABEL: func @shift
func @shift(%idx : index) {
  // CHECK-NEXT: alloc() : memref<65xf32>
  %A = alloc() : memref<64xf32, affine_map<(d0) -> (d0 + 1)>>
  // CHECK-NEXT: affine.load %{{.*}}[symbol(%arg0) + 1] : memref<65xf32>
  affine.load %A[%idx] : memref<64xf32, affine_map<(d0) -> (d0 + 1)>>
  affine.for %i = 0 to 64 {
    %1 = affine.load %A[%i] : memref<64xf32, affine_map<(d0) -> (d0 + 1)>>
    "prevent.dce"(%1) : (f32) -> ()
    // CHECK: %{{.*}} = affine.load %{{.*}}[%arg{{.*}} + 1] : memref<65xf32>
  }
  return
}

// CHECK-LABEL: func @high_dim_permute()
func @high_dim_permute() {
  // CHECK-NOT: memref<64x128x256xf32,
  %A = alloc() : memref<64x128x256xf32, affine_map<(d0, d1, d2) -> (d2, d0, d1)>>
  // CHECK: %[[I:arg[0-9]+]]
  affine.for %i = 0 to 64 {
    // CHECK: %[[J:arg[0-9]+]]
    affine.for %j = 0 to 128 {
      // CHECK: %[[K:arg[0-9]+]]
      affine.for %k = 0 to 256 {
        %1 = affine.load %A[%i, %j, %k] : memref<64x128x256xf32, affine_map<(d0, d1, d2) -> (d2, d0, d1)>>
        // CHECK: %{{.*}} = affine.load %{{.*}}[%[[K]], %[[I]], %[[J]]] : memref<256x64x128xf32>
        "prevent.dce"(%1) : (f32) -> ()
      }
    }
  }
  return
}

// CHECK-LABEL: func @invalid_map
func @invalid_map() {
  %A = alloc() : memref<64x128xf32, affine_map<(d0, d1) -> (d0, -d1 - 10)>>
  // CHECK: %{{.*}} = alloc() : memref<64x128xf32,
  return
}

// A tiled layout.
// CHECK-LABEL: func @data_tiling
func @data_tiling(%idx : index) {
  // CHECK: alloc() : memref<8x32x8x16xf32>
  %A = alloc() : memref<64x512xf32, affine_map<(d0, d1) -> (d0 floordiv 8, d1 floordiv 16, d0 mod 8, d1 mod 16)>>
  // CHECK: affine.load %{{.*}}[symbol(%arg0) floordiv 8, symbol(%arg0) floordiv 16, symbol(%arg0) mod 8, symbol(%arg0) mod 16]
  %1 = affine.load %A[%idx, %idx] : memref<64x512xf32, affine_map<(d0, d1) -> (d0 floordiv 8, d1 floordiv 16, d0 mod 8, d1 mod 16)>>
  "prevent.dce"(%1) : (f32) -> ()
  return
}

// Strides 2 and 4 along respective dimensions.
// CHECK-LABEL: func @strided
func @strided() {
  %A = alloc() : memref<64x128xf32, affine_map<(d0, d1) -> (2*d0, 4*d1)>>
  // CHECK: affine.for %[[IV0:.*]] =
  affine.for %i = 0 to 64 {
    // CHECK: affine.for %[[IV1:.*]] =
    affine.for %j = 0 to 128 {
      // CHECK: affine.load %{{.*}}[%[[IV0]] * 2, %[[IV1]] * 4] : memref<127x509xf32>
      %1 = affine.load %A[%i, %j] : memref<64x128xf32, affine_map<(d0, d1) -> (2*d0, 4*d1)>>
      "prevent.dce"(%1) : (f32) -> ()
    }
  }
  return
}

// Strided, but the strides are in the linearized space.
// CHECK-LABEL: func @strided_cumulative
func @strided_cumulative() {
  %A = alloc() : memref<2x5xf32, affine_map<(d0, d1) -> (3*d0 + 17*d1)>>
  // CHECK: affine.for %[[IV0:.*]] =
  affine.for %i = 0 to 2 {
    // CHECK: affine.for %[[IV1:.*]] =
    affine.for %j = 0 to 5 {
      // CHECK: affine.load %{{.*}}[%[[IV0]] * 3 + %[[IV1]] * 17] : memref<72xf32>
      %1 = affine.load %A[%i, %j]  : memref<2x5xf32, affine_map<(d0, d1) -> (3*d0 + 17*d1)>>
      "prevent.dce"(%1) : (f32) -> ()
    }
  }
  return
}

// Symbolic operand for alloc, although unused. Tests replaceAllMemRefUsesWith
// when the index remap has symbols.
// CHECK-LABEL: func @symbolic_operands
func @symbolic_operands(%s : index) {
  // CHECK: alloc() : memref<100xf32>
  %A = alloc()[%s] : memref<10x10xf32, affine_map<(d0,d1)[s0] -> (10*d0 + d1)>>
  affine.for %i = 0 to 10 {
    affine.for %j = 0 to 10 {
      // CHECK: affine.load %{{.*}}[%{{.*}} * 10 + %{{.*}}] : memref<100xf32>
      %1 = affine.load %A[%i, %j] : memref<10x10xf32, affine_map<(d0,d1)[s0] -> (10*d0 + d1)>>
      "prevent.dce"(%1) : (f32) -> ()
    }
  }
  return
}

// Memref escapes; no normalization.
// CHECK-LABEL: func @escaping() -> memref<64xf32, #map{{[0-9]+}}>
func @escaping() ->  memref<64xf32, affine_map<(d0) -> (d0 + 2)>> {
  // CHECK: %{{.*}} = alloc() : memref<64xf32, #map{{[0-9]+}}>
  %A = alloc() : memref<64xf32, affine_map<(d0) -> (d0 + 2)>>
  return %A : memref<64xf32, affine_map<(d0) -> (d0 + 2)>>
}

// Semi-affine maps, normalization not implemented yet.
// CHECK-LABEL: func @semi_affine_layout_map
func @semi_affine_layout_map(%s0: index, %s1: index) {
  %A = alloc()[%s0, %s1] : memref<256x1024xf32, affine_map<(d0, d1)[s0, s1] -> (d0*s0 + d1*s1)>>
  affine.for %i = 0 to 256 {
    affine.for %j = 0 to 1024 {
      // CHECK: memref<256x1024xf32, #map{{[0-9]+}}>
      affine.load %A[%i, %j] : memref<256x1024xf32, affine_map<(d0, d1)[s0, s1] -> (d0*s0 + d1*s1)>>
    }
  }
  return
}

// CHECK-LABEL: func @alignment
func @alignment() {
  %A = alloc() {alignment = 32 : i64}: memref<64x128x256xf32, affine_map<(d0, d1, d2) -> (d2, d0, d1)>>
  // CHECK-NEXT: alloc() {alignment = 32 : i64} : memref<256x64x128xf32>
  return
}

#tile = affine_map < (i)->(i floordiv 4, i mod 4) >

// Following test cases check the inter-procedural memref normalization.

// Test case 1: Check normalization for multiple memrefs in a function argument list.
// CHECK-LABEL: func @multiple_argument_type
// CHECK-SAME:  (%[[A:arg[0-9]+]]: memref<4x4xf64>, %[[B:arg[0-9]+]]: f64, %[[C:arg[0-9]+]]: memref<2x4xf64>, %[[D:arg[0-9]+]]: memref<24xf64>) -> f64
func @multiple_argument_type(%A: memref<16xf64, #tile>, %B: f64, %C: memref<8xf64, #tile>, %D: memref<24xf64>) -> f64 {
  %a = affine.load %A[0] : memref<16xf64, #tile>
  %p = mulf %a, %a : f64
  affine.store %p, %A[10] : memref<16xf64, #tile>
  call @single_argument_type(%C): (memref<8xf64, #tile>) -> ()
  return %B : f64
}

// CHECK: %[[a:[0-9]+]] = affine.load %[[A]][0, 0] : memref<4x4xf64>
// CHECK: %[[p:[0-9]+]] = mulf %[[a]], %[[a]] : f64
// CHECK: affine.store %[[p]], %[[A]][2, 2] : memref<4x4xf64>
// CHECK: call @single_argument_type(%[[C]]) : (memref<2x4xf64>) -> ()
// CHECK: return %[[B]] : f64

// Test case 2: Check normalization for single memref argument in a function.
// CHECK-LABEL: func @single_argument_type
// CHECK-SAME: (%[[C:arg[0-9]+]]: memref<2x4xf64>)
func @single_argument_type(%C : memref<8xf64, #tile>) {
  %a = alloc(): memref<8xf64, #tile>
  %b = alloc(): memref<16xf64, #tile>
  %d = constant 23.0 : f64
  %e = alloc(): memref<24xf64>
  call @single_argument_type(%a): (memref<8xf64, #tile>) -> ()
  call @single_argument_type(%C): (memref<8xf64, #tile>) -> ()
  call @multiple_argument_type(%b, %d, %a, %e): (memref<16xf64, #tile>, f64, memref<8xf64, #tile>, memref<24xf64>) -> f64
  return
}

// CHECK: %[[a:[0-9]+]] = alloc() : memref<2x4xf64>
// CHECK: %[[b:[0-9]+]] = alloc() : memref<4x4xf64>
// CHECK: %cst = constant 2.300000e+01 : f64
// CHECK: %[[e:[0-9]+]] = alloc() : memref<24xf64>
// CHECK: call @single_argument_type(%[[a]]) : (memref<2x4xf64>) -> ()
// CHECK: call @single_argument_type(%[[C]]) : (memref<2x4xf64>) -> ()
// CHECK: call @multiple_argument_type(%[[b]], %cst, %[[a]], %[[e]]) : (memref<4x4xf64>, f64, memref<2x4xf64>, memref<24xf64>) -> f64

// Test case 3: Check function returning any other type except memref.
// CHECK-LABEL: func @non_memref_ret
// CHECK-SAME: (%[[C:arg[0-9]+]]: memref<2x4xf64>) -> i1
func @non_memref_ret(%A: memref<8xf64, #tile>) -> i1 {
  %d = constant 1 : i1
  return %d : i1
}

// Test case 4: No normalization should take place because the function is returning the memref.
// CHECK-LABEL: func @memref_used_in_return
// CHECK-SAME: (%[[A:arg[0-9]+]]: memref<8xf64, #map{{[0-9]+}}>) -> memref<8xf64, #map{{[0-9]+}}>
func @memref_used_in_return(%A: memref<8xf64, #tile>) -> (memref<8xf64, #tile>) {
  return %A : memref<8xf64, #tile>
}
