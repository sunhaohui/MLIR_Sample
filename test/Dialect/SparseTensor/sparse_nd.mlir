// NOTE: Assertions have been autogenerated by utils/generate-test-checks.py
// RUN: mlir-opt %s -sparsification | FileCheck %s

// Example with cyclic iteration graph with sparse and dense constraints,
// but an acyclic iteration graph using sparse constraints only.

#SparseTensor = #sparse_tensor.encoding<{
  dimLevelType = [ "dense", "dense", "dense", "compressed",
                   "compressed", "dense", "dense", "dense" ]
}>

#trait_mul = {
  indexing_maps = [
    affine_map<(i,j,k,l,m,n,o,p) -> (i,j,k,l,m,n,o,p)>,  // A
    affine_map<(i,j,k,l,m,n,o,p) -> (p,o,n,m,l,k,j,i)>,  // B
    affine_map<(i,j,k,l,m,n,o,p) -> (i,j,k,l,m,n,o,p)>   // X
  ],
  iterator_types = ["parallel", "parallel", "parallel", "parallel",
                    "parallel", "parallel", "parallel", "parallel"],
  doc = "X(i,j,k,l,m,n,o,p) = A(i,j,k,l,m,n,o,p) * B(p,o,n,m,l,k,j,i)"
}

// CHECK-LABEL:   func @mul(
// CHECK-SAME:              %[[VAL_0:.*]]: tensor<10x20x30x40x50x60x70x80xf32>,
// CHECK-SAME:              %[[VAL_1:.*]]: tensor<80x70x60x50x40x30x20x10xf32, #sparse_tensor.encoding<{ dimLevelType = [ "dense", "dense", "dense", "compressed", "compressed", "dense", "dense", "dense" ], pointerBitWidth = 0, indexBitWidth = 0 }>>,
// CHECK-SAME:              %[[VAL_2:.*]]: tensor<10x20x30x40x50x60x70x80xf32>) -> tensor<10x20x30x40x50x60x70x80xf32> {
// CHECK:           %[[VAL_3:.*]] = constant 3 : index
// CHECK:           %[[VAL_4:.*]] = constant 4 : index
// CHECK:           %[[VAL_5:.*]] = constant 10 : index
// CHECK:           %[[VAL_6:.*]] = constant 20 : index
// CHECK:           %[[VAL_7:.*]] = constant 30 : index
// CHECK:           %[[VAL_8:.*]] = constant 60 : index
// CHECK:           %[[VAL_9:.*]] = constant 70 : index
// CHECK:           %[[VAL_10:.*]] = constant 80 : index
// CHECK:           %[[VAL_11:.*]] = constant 0 : index
// CHECK:           %[[VAL_12:.*]] = constant 1 : index
// CHECK:           %[[VAL_13:.*]] = memref.buffer_cast %[[VAL_0]] : memref<10x20x30x40x50x60x70x80xf32>
// CHECK:           %[[VAL_14:.*]] = sparse_tensor.pointers %[[VAL_1]], %[[VAL_3]] : tensor<80x70x60x50x40x30x20x10xf32, #sparse_tensor.encoding<{ dimLevelType = [ "dense", "dense", "dense", "compressed", "compressed", "dense", "dense", "dense" ], pointerBitWidth = 0, indexBitWidth = 0 }>> to memref<?xindex>
// CHECK:           %[[VAL_15:.*]] = sparse_tensor.indices %[[VAL_1]], %[[VAL_3]] : tensor<80x70x60x50x40x30x20x10xf32, #sparse_tensor.encoding<{ dimLevelType = [ "dense", "dense", "dense", "compressed", "compressed", "dense", "dense", "dense" ], pointerBitWidth = 0, indexBitWidth = 0 }>> to memref<?xindex>
// CHECK:           %[[VAL_16:.*]] = sparse_tensor.pointers %[[VAL_1]], %[[VAL_4]] : tensor<80x70x60x50x40x30x20x10xf32, #sparse_tensor.encoding<{ dimLevelType = [ "dense", "dense", "dense", "compressed", "compressed", "dense", "dense", "dense" ], pointerBitWidth = 0, indexBitWidth = 0 }>> to memref<?xindex>
// CHECK:           %[[VAL_17:.*]] = sparse_tensor.indices %[[VAL_1]], %[[VAL_4]] : tensor<80x70x60x50x40x30x20x10xf32, #sparse_tensor.encoding<{ dimLevelType = [ "dense", "dense", "dense", "compressed", "compressed", "dense", "dense", "dense" ], pointerBitWidth = 0, indexBitWidth = 0 }>> to memref<?xindex>
// CHECK:           %[[VAL_18:.*]] = sparse_tensor.values %[[VAL_1]] : tensor<80x70x60x50x40x30x20x10xf32, #sparse_tensor.encoding<{ dimLevelType = [ "dense", "dense", "dense", "compressed", "compressed", "dense", "dense", "dense" ], pointerBitWidth = 0, indexBitWidth = 0 }>> to memref<?xf32>
// CHECK:           %[[VAL_19:.*]] = memref.buffer_cast %[[VAL_2]] : memref<10x20x30x40x50x60x70x80xf32>
// CHECK:           %[[VAL_20:.*]] = memref.alloc() : memref<10x20x30x40x50x60x70x80xf32>
// CHECK:           memref.copy %[[VAL_19]], %[[VAL_20]] : memref<10x20x30x40x50x60x70x80xf32> to memref<10x20x30x40x50x60x70x80xf32>
// CHECK:           scf.for %[[VAL_21:.*]] = %[[VAL_11]] to %[[VAL_10]] step %[[VAL_12]] {
// CHECK:             scf.for %[[VAL_22:.*]] = %[[VAL_11]] to %[[VAL_9]] step %[[VAL_12]] {
// CHECK:               %[[VAL_23:.*]] = muli %[[VAL_21]], %[[VAL_9]] : index
// CHECK:               %[[VAL_24:.*]] = addi %[[VAL_23]], %[[VAL_22]] : index
// CHECK:               scf.for %[[VAL_25:.*]] = %[[VAL_11]] to %[[VAL_8]] step %[[VAL_12]] {
// CHECK:                 %[[VAL_26:.*]] = muli %[[VAL_24]], %[[VAL_8]] : index
// CHECK:                 %[[VAL_27:.*]] = addi %[[VAL_26]], %[[VAL_25]] : index
// CHECK:                 %[[VAL_28:.*]] = memref.load %[[VAL_14]]{{\[}}%[[VAL_27]]] : memref<?xindex>
// CHECK:                 %[[VAL_29:.*]] = addi %[[VAL_27]], %[[VAL_12]] : index
// CHECK:                 %[[VAL_30:.*]] = memref.load %[[VAL_14]]{{\[}}%[[VAL_29]]] : memref<?xindex>
// CHECK:                 scf.for %[[VAL_31:.*]] = %[[VAL_28]] to %[[VAL_30]] step %[[VAL_12]] {
// CHECK:                   %[[VAL_32:.*]] = memref.load %[[VAL_15]]{{\[}}%[[VAL_31]]] : memref<?xindex>
// CHECK:                   %[[VAL_33:.*]] = memref.load %[[VAL_16]]{{\[}}%[[VAL_31]]] : memref<?xindex>
// CHECK:                   %[[VAL_34:.*]] = addi %[[VAL_31]], %[[VAL_12]] : index
// CHECK:                   %[[VAL_35:.*]] = memref.load %[[VAL_16]]{{\[}}%[[VAL_34]]] : memref<?xindex>
// CHECK:                   scf.for %[[VAL_36:.*]] = %[[VAL_33]] to %[[VAL_35]] step %[[VAL_12]] {
// CHECK:                     %[[VAL_37:.*]] = memref.load %[[VAL_17]]{{\[}}%[[VAL_36]]] : memref<?xindex>
// CHECK:                     scf.for %[[VAL_38:.*]] = %[[VAL_11]] to %[[VAL_7]] step %[[VAL_12]] {
// CHECK:                       %[[VAL_39:.*]] = muli %[[VAL_36]], %[[VAL_7]] : index
// CHECK:                       %[[VAL_40:.*]] = addi %[[VAL_39]], %[[VAL_38]] : index
// CHECK:                       scf.for %[[VAL_41:.*]] = %[[VAL_11]] to %[[VAL_6]] step %[[VAL_12]] {
// CHECK:                         %[[VAL_42:.*]] = muli %[[VAL_40]], %[[VAL_6]] : index
// CHECK:                         %[[VAL_43:.*]] = addi %[[VAL_42]], %[[VAL_41]] : index
// CHECK:                         scf.for %[[VAL_44:.*]] = %[[VAL_11]] to %[[VAL_5]] step %[[VAL_12]] {
// CHECK:                           %[[VAL_45:.*]] = muli %[[VAL_43]], %[[VAL_5]] : index
// CHECK:                           %[[VAL_46:.*]] = addi %[[VAL_45]], %[[VAL_44]] : index
// CHECK:                           %[[VAL_47:.*]] = memref.load %[[VAL_13]]{{\[}}%[[VAL_44]], %[[VAL_41]], %[[VAL_38]], %[[VAL_37]], %[[VAL_32]], %[[VAL_25]], %[[VAL_22]], %[[VAL_21]]] : memref<10x20x30x40x50x60x70x80xf32>
// CHECK:                           %[[VAL_48:.*]] = memref.load %[[VAL_18]]{{\[}}%[[VAL_46]]] : memref<?xf32>
// CHECK:                           %[[VAL_49:.*]] = mulf %[[VAL_47]], %[[VAL_48]] : f32
// CHECK:                           memref.store %[[VAL_49]], %[[VAL_20]]{{\[}}%[[VAL_44]], %[[VAL_41]], %[[VAL_38]], %[[VAL_37]], %[[VAL_32]], %[[VAL_25]], %[[VAL_22]], %[[VAL_21]]] : memref<10x20x30x40x50x60x70x80xf32>
// CHECK:                         }
// CHECK:                       }
// CHECK:                     }
// CHECK:                   }
// CHECK:                 }
// CHECK:               }
// CHECK:             }
// CHECK:           }
// CHECK:           %[[VAL_50:.*]] = memref.tensor_load %[[VAL_20]] : memref<10x20x30x40x50x60x70x80xf32>
// CHECK:           return %[[VAL_50]] : tensor<10x20x30x40x50x60x70x80xf32>
// CHECK:         }
func @mul(%arga: tensor<10x20x30x40x50x60x70x80xf32>,
          %argb: tensor<80x70x60x50x40x30x20x10xf32, #SparseTensor>,
          %argx: tensor<10x20x30x40x50x60x70x80xf32>)
	      -> tensor<10x20x30x40x50x60x70x80xf32> {
  %0 = linalg.generic #trait_mul
    ins(%arga, %argb: tensor<10x20x30x40x50x60x70x80xf32>,
                      tensor<80x70x60x50x40x30x20x10xf32, #SparseTensor>)
    outs(%argx: tensor<10x20x30x40x50x60x70x80xf32>) {
      ^bb(%a: f32, %b: f32, %x: f32):
        %0 = mulf %a, %b : f32
        linalg.yield %0 : f32
    }      -> tensor<10x20x30x40x50x60x70x80xf32>
  return %0 : tensor<10x20x30x40x50x60x70x80xf32>
}
