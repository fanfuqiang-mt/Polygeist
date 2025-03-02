// RUN: polygeist-opt --parallel-licm -allow-unregistered-dialect --split-input-file %s | FileCheck %s

module {
  func.func @main(%11 : index) {
    %12 = memref.alloc(%11) : memref<?xf32>
      %28 = memref.alloca() : memref<16x16xf32>
      affine.for %arg4 = 0 to 16 {
        %29 = affine.load %28[0, 0] : memref<16x16xf32>
        %a = affine.load %12[0] : memref<?xf32>
        %z = arith.addf %a, %29 : f32
        affine.store %z, %12[0] : memref<?xf32>
      }
    return
  }
  func.func @main2(%11 : index, %28 : memref<16x16xf32>) {
    %12 = memref.alloc(%11) : memref<?xf32>
      affine.for %arg4 = 0 to 16 {
        %29 = affine.load %28[0, 0] : memref<16x16xf32>
        %a = affine.load %12[0] : memref<?xf32>
        %z = arith.addf %a, %29 : f32
        affine.store %z, %12[0] : memref<?xf32>
      }
    return
  }
  func.func @main3(%11 : index, %c : i1) {
    %12 = memref.alloc(%11) : memref<?xf32>
      %28 = memref.alloca() : memref<16x16xf32>
      affine.for %arg4 = 0 to 16 {
        %29 = scf.if %c -> f32 {
          %l1 = affine.load %28[0, 0] : memref<16x16xf32>
          scf.yield %l1 : f32
        } else {
          %a = affine.load %12[1] : memref<?xf32>
          affine.store %a, %12[0] : memref<?xf32>
          scf.yield %a : f32
        }
        %a = affine.load %12[0] : memref<?xf32>
        %z = arith.addf %a, %29 : f32
        affine.store %z, %12[0] : memref<?xf32>
    }
    return
  }
  func.func @main4(%11 : index, %c : i1) {
    %12 = memref.alloc(%11) : memref<?xf32>
      %28 = memref.alloca() : memref<16x16xf32>
      affine.for %arg4 = 0 to 16 {
      affine.for %barg4 = 0 to 16 {
        %29 = scf.if %c -> f32 {
          %l1 = affine.load %28[%arg4, 0] : memref<16x16xf32>
          scf.yield %l1 : f32
        } else {
          %a = affine.load %12[1] : memref<?xf32>
          affine.store %a, %12[0] : memref<?xf32>
          scf.yield %a : f32
        }
        %a = affine.load %12[0] : memref<?xf32>
        %z = arith.addf %a, %29 : f32
        affine.store %z, %12[0] : memref<?xf32>
      }
    }
    return
  }
}

// CHECK: #set = affine_set<() : (15 >= 0)>
// CHECK:   func.func @main(%arg0: index) {
// CHECK-NEXT:     %0 = memref.alloc(%arg0) : memref<?xf32>
// CHECK-NEXT:     %1 = memref.alloca() : memref<16x16xf32>
// CHECK-NEXT:       %2 = affine.load %1[0, 0] : memref<16x16xf32>
// CHECK-NEXT:       affine.for %arg1 = 0 to 16 {
// CHECK-NEXT:         %3 = affine.load %0[0] : memref<?xf32>
// CHECK-NEXT:         %4 = arith.addf %3, %2 : f32
// CHECK-NEXT:         affine.store %4, %0[0] : memref<?xf32>
// CHECK-NEXT:       }
// CHECK-NEXT:     return
// CHECK-NEXT:   }
// CHECK:   func.func @main2(%arg0: index, %arg1: memref<16x16xf32>) {
// CHECK-NEXT:     %0 = memref.alloc(%arg0) : memref<?xf32>
// CHECK-NEXT:     affine.if #set() {
// CHECK-NEXT:       %1 = affine.load %arg1[0, 0] : memref<16x16xf32>
// CHECK-NEXT:       affine.for %arg2 = 0 to 16 {
// CHECK-NEXT:         %2 = affine.load %0[0] : memref<?xf32>
// CHECK-NEXT:         %3 = arith.addf %2, %1 : f32
// CHECK-NEXT:         affine.store %3, %0[0] : memref<?xf32>
// CHECK-NEXT:       }
// CHECK-NEXT:     }
// CHECK-NEXT:     return
// CHECK-NEXT:   }

// CHECK:   func.func @main3(%arg0: index, %arg1: i1) {
// CHECK-NEXT:     %0 = memref.alloc(%arg0) : memref<?xf32>
// CHECK-NEXT:     %1 = memref.alloca() : memref<16x16xf32>
// CHECK-NEXT:     %2 = affine.load %1[0, 0] : memref<16x16xf32>
// CHECK-NEXT:     affine.for %arg2 = 0 to 16 {
// CHECK-NEXT:       %3 = scf.if %arg1 -> (f32) {
// CHECK-NEXT:         scf.yield %2 : f32
// CHECK-NEXT:       } else {
// CHECK-NEXT:         %6 = affine.load %0[1] : memref<?xf32>
// CHECK-NEXT:         affine.store %6, %0[0] : memref<?xf32>
// CHECK-NEXT:         scf.yield %6 : f32
// CHECK-NEXT:       }
// CHECK-NEXT:       %4 = affine.load %0[0] : memref<?xf32>
// CHECK-NEXT:       %5 = arith.addf %4, %3 : f32
// CHECK-NEXT:       affine.store %5, %0[0] : memref<?xf32>
// CHECK-NEXT:     }
// CHECK-NEXT:     return
// CHECK-NEXT:   }

// CHECK:   func.func @main4(%arg0: index, %arg1: i1) {
// CHECK-NEXT:     %0 = memref.alloc(%arg0) : memref<?xf32>
// CHECK-NEXT:     %1 = memref.alloca() : memref<16x16xf32>
// CHECK-NEXT:     affine.for %arg2 = 0 to 16 {
// CHECK-NEXT:       %2 = affine.load %1[%arg2, 0] : memref<16x16xf32>
// CHECK-NEXT:       affine.for %arg3 = 0 to 16 {
// CHECK-NEXT:         %3 = scf.if %arg1 -> (f32) {
// CHECK-NEXT:           scf.yield %2 : f32
// CHECK-NEXT:         } else {
// CHECK-NEXT:           %6 = affine.load %0[1] : memref<?xf32>
// CHECK-NEXT:           affine.store %6, %0[0] : memref<?xf32>
// CHECK-NEXT:           scf.yield %6 : f32
// CHECK-NEXT:         }
// CHECK-NEXT:         %4 = affine.load %0[0] : memref<?xf32>
// CHECK-NEXT:         %5 = arith.addf %4, %3 : f32
// CHECK-NEXT:         affine.store %5, %0[0] : memref<?xf32>
// CHECK-NEXT:       }
// CHECK-NEXT:     }
// CHECK-NEXT:     return
// CHECK-NEXT:   }
