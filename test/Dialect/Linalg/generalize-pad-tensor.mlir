// RUN: mlir-opt -split-input-file --test-linalg-transform-patterns="test-generalize-pad-tensor"  %s | FileCheck --check-prefix=CHECK %s

// CHECK-LABEL:   func @generalize_pad_tensor_static_shape(
// CHECK-SAME:                                             %[[IN:.*]]: tensor<1x28x28x1xf32>) -> tensor<1x32x32x1xf32> {
// CHECK:           %[[C0:.*]] = constant 0.000000e+00 : f32
// CHECK:           %[[INIT:.*]] = linalg.init_tensor [1, 32, 32, 1] : tensor<1x32x32x1xf32>
// CHECK:           %[[FILL:.*]] = linalg.fill(%[[C0]], %[[INIT]]) : f32, tensor<1x32x32x1xf32> -> tensor<1x32x32x1xf32>
// CHECK:           %[[PADDED:.*]] = tensor.insert_slice %[[IN]] into %[[FILL]][0, 2, 2, 0] [1, 28, 28, 1] [1, 1, 1, 1] : tensor<1x28x28x1xf32> into tensor<1x32x32x1xf32>
// CHECK:           return %[[PADDED]] : tensor<1x32x32x1xf32>
func @generalize_pad_tensor_static_shape(%arg0: tensor<1x28x28x1xf32>) -> tensor<1x32x32x1xf32> {
  %cst = constant 0.000000e+00 : f32
  %0 = linalg.pad_tensor %arg0 low[0, 2, 2, 0] high[0, 2, 2, 0]  {
  ^bb0(%arg1: index, %arg2: index, %arg3: index, %arg4: index):  // no predecessors
    linalg.yield %cst : f32
  } : tensor<1x28x28x1xf32> to tensor<1x32x32x1xf32>
  return %0 : tensor<1x32x32x1xf32>
}

// CHECK-LABEL:   func @generalize_pad_tensor_dynamic_shape(
// CHECK-SAME:                                              %[[IN:.*]]: tensor<4x?x2x?xf32>,
// CHECK-SAME:                                              %[[OFFSET:.*]]: index) -> tensor<4x?x?x?xf32> {
// CHECK:           %[[C0:.*]] = constant 0 : index
// CHECK:           %[[CST:.*]] = constant 0.000000e+00 : f32
// CHECK:           %[[C2:.*]] = constant 2 : index
// CHECK:           %[[C1:.*]] = constant 1 : index
// CHECK:           %[[C3:.*]] = constant 3 : index
// CHECK:           %[[DIM1:.*]] = tensor.dim %[[IN]], %[[C1]] : tensor<4x?x2x?xf32>
// CHECK:           %[[OUT_DIM2:.*]] = addi %[[OFFSET]], %[[C2]] : index
// CHECK:           %[[DIM3:.*]] = tensor.dim %[[IN]], %[[C3]] : tensor<4x?x2x?xf32>
// CHECK:           %[[OUT_DIM3:.*]] = addi %[[DIM3]], %[[OFFSET]] : index
// CHECK:           %[[INIT:.*]] = linalg.init_tensor [4, %[[DIM1]], %[[OUT_DIM2]], %[[OUT_DIM3]]] : tensor<4x?x?x?xf32>
// CHECK:           %[[FILL:.*]] = linalg.fill(%[[CST]], %[[INIT]]) : f32, tensor<4x?x?x?xf32> -> tensor<4x?x?x?xf32>
// CHECK:           %[[DIM1_1:.*]] = tensor.dim %[[IN]], %[[C1]] : tensor<4x?x2x?xf32>
// CHECK:           %[[DIM3_1:.*]] = tensor.dim %[[IN]], %[[C3]] : tensor<4x?x2x?xf32>
// CHECK:           %[[PADDED:.*]] = tensor.insert_slice %[[IN]] into %[[FILL]]{{\[}}%[[C0]], %[[C0]], %[[OFFSET]], %[[C0]]] [4, %[[DIM1_1]], 2, %[[DIM3_1]]] [1, 1, 1, 1] : tensor<4x?x2x?xf32> into tensor<4x?x?x?xf32>
// CHECK:           return %[[PADDED]] : tensor<4x?x?x?xf32>
// CHECK:         }
func @generalize_pad_tensor_dynamic_shape(%arg0: tensor<4x?x2x?xf32>, %arg1: index) -> tensor<4x?x?x?xf32> {
  %c0 = constant 0 : index
  %cst = constant 0.0 : f32
  %out = linalg.pad_tensor %arg0 low[%c0, %c0, %arg1, %c0] high[%c0, %c0, %c0, %arg1]  {
  ^bb0(%gen_arg1: index, %gen_arg2: index, %gen_arg3: index, %gen_arg4: index):  // no predecessors
    linalg.yield %cst : f32
  } : tensor<4x?x2x?xf32> to tensor<4x?x?x?xf32>
  return %out : tensor<4x?x?x?xf32>
}
