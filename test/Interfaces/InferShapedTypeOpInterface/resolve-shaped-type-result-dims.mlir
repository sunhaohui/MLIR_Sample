// RUN: mlir-opt %s -resolve-shaped-type-result-dims -split-input-file | FileCheck %s

func @result_shape(%arg0 : tensor<2x3x?xf32>, %arg1 : tensor<?x5xf32>)
    -> (index, index, index, index, index) {
  %c0 = constant 0 : index
  %c1 = constant 1 : index
  %c2 = constant 2 : index
  %0:2 = "test.op_with_result_shape_interface"(%arg0, %arg1)
      : (tensor<2x3x?xf32>, tensor<?x5xf32>) -> (tensor<?x5xf32>, tensor<2x3x?xf32>)
  %1 = tensor.dim %0#0, %c0 : tensor<?x5xf32>
  %2 = tensor.dim %0#0, %c1 : tensor<?x5xf32>
  %3 = tensor.dim %0#1, %c0 : tensor<2x3x?xf32>
  %4 = tensor.dim %0#1, %c1 : tensor<2x3x?xf32>
  %5 = tensor.dim %0#1, %c2 : tensor<2x3x?xf32>
  return %1, %2, %3, %4, %5 : index, index, index, index, index
}
// CHECK-LABEL: func @result_shape(
//  CHECK-SAME:   %[[ARG_0:[a-z0-9]*]]: tensor<2x3x?xf32>
//  CHECK-SAME:   %[[ARG_1:[a-z0-9]*]]: tensor<?x5xf32>)
//   CHECK-DAG:   %[[C0:.+]] = constant 0 : index
//   CHECK-DAG:   %[[C2:.+]] = constant 2 : index
//   CHECK-DAG:   %[[C3:.+]] = constant 3 : index
//   CHECK-DAG:   %[[C5:.+]] = constant 5 : index
//   CHECK-DAG:   %[[D0:.+]] = tensor.dim %[[ARG_1]], %[[C0]]
//   CHECK-DAG:   %[[S0:.+]] = tensor.from_elements %[[D0]], %[[C5]]
//   CHECK-DAG:   %[[D0_OUT:.+]] = tensor.extract %[[S0]][%[[C0]]]
//   CHECK-DAG:   %[[D1:.+]] = tensor.dim %[[ARG_0]], %[[C2]]
//   CHECK-DAG:   %[[S1:.+]] = tensor.from_elements %[[C2]], %[[C3]], %[[D1]]
//   CHECK-DAG:   %[[D1_OUT:.+]] = tensor.extract %[[S1]][%[[C2]]]
//       CHECK:   return %[[D0_OUT]], %[[C5]], %[[C2]], %[[C3]], %[[D1_OUT]]

// -----

func @result_shape_per_dim(%arg0 : tensor<2x3x?xf32>, %arg1 : tensor<?x5xf32>)
    -> (index, index, index, index, index) {
  %c0 = constant 0 : index
  %c1 = constant 1 : index
  %c2 = constant 2 : index
  %0:2 = "test.op_with_result_shape_per_dim_interface"(%arg0, %arg1)
      : (tensor<2x3x?xf32>, tensor<?x5xf32>) -> (tensor<?x5xf32>, tensor<2x3x?xf32>)
  %1 = tensor.dim %0#0, %c0 : tensor<?x5xf32>
  %2 = tensor.dim %0#0, %c1 : tensor<?x5xf32>
  %3 = tensor.dim %0#1, %c0 : tensor<2x3x?xf32>
  %4 = tensor.dim %0#1, %c1 : tensor<2x3x?xf32>
  %5 = tensor.dim %0#1, %c2 : tensor<2x3x?xf32>
  return %1, %2, %3, %4, %5 : index, index, index, index, index
}
// CHECK-LABEL: func @result_shape_per_dim(
//  CHECK-SAME:   %[[ARG_0:[a-z0-9]*]]: tensor<2x3x?xf32>
//  CHECK-SAME:   %[[ARG_1:[a-z0-9]*]]: tensor<?x5xf32>)
//   CHECK-DAG:   %[[C0:.+]] = constant 0 : index
//   CHECK-DAG:   %[[C2:.+]] = constant 2 : index
//   CHECK-DAG:   %[[C3:.+]] = constant 3 : index
//   CHECK-DAG:   %[[C5:.+]] = constant 5 : index
//   CHECK-DAG:   %[[D0:.+]] = tensor.dim %[[ARG_1]], %[[C0]]
//   CHECK-DAG:   %[[D1:.+]] = tensor.dim %[[ARG_0]], %[[C2]]
//       CHECK:   return %[[D0]], %[[C5]], %[[C2]], %[[C3]], %[[D1]]
