// RUN: mlir-opt -test-ir-visitors -allow-unregistered-dialect -split-input-file %s | FileCheck %s

// Verify the different configurations of IR visitors.
// Constant, yield and other terminator ops are not matched for simplicity.
// Module and function op and their immediately nested blocks are not erased in
// callbacks with return so that the output includes more cases in pre-order.

func @structured_cfg() {
  %c0 = constant 0 : index
  %c1 = constant 1 : index
  %c10 = constant 10 : index
  scf.for %i = %c1 to %c10 step %c1 {
    %cond = "use0"(%i) : (index) -> (i1)
    scf.if %cond {
      "use1"(%i) : (index) -> ()
    } else {
      "use2"(%i) : (index) -> ()
    }
    "use3"(%i) : (index) -> ()
  }
  return
}

// CHECK-LABEL: Op pre-order visit
// CHECK:       Visiting op 'module'
// CHECK:       Visiting op 'func'
// CHECK:       Visiting op 'scf.for'
// CHECK:       Visiting op 'use0'
// CHECK:       Visiting op 'scf.if'
// CHECK:       Visiting op 'use1'
// CHECK:       Visiting op 'use2'
// CHECK:       Visiting op 'use3'
// CHECK:       Visiting op 'std.return'

// CHECK-LABEL: Block pre-order visits
// CHECK:       Visiting block ^bb0 from region 0 from operation 'module'
// CHECK:       Visiting block ^bb0 from region 0 from operation 'func'
// CHECK:       Visiting block ^bb0 from region 0 from operation 'scf.for'
// CHECK:       Visiting block ^bb0 from region 0 from operation 'scf.if'
// CHECK:       Visiting block ^bb0 from region 1 from operation 'scf.if'

// CHECK-LABEL: Region pre-order visits
// CHECK:       Visiting region 0 from operation 'module'
// CHECK:       Visiting region 0 from operation 'func'
// CHECK:       Visiting region 0 from operation 'scf.for'
// CHECK:       Visiting region 0 from operation 'scf.if'
// CHECK:       Visiting region 1 from operation 'scf.if'

// CHECK-LABEL: Op post-order visits
// CHECK:       Visiting op 'use0'
// CHECK:       Visiting op 'use1'
// CHECK:       Visiting op 'use2'
// CHECK:       Visiting op 'scf.if'
// CHECK:       Visiting op 'use3'
// CHECK:       Visiting op 'scf.for'
// CHECK:       Visiting op 'std.return'
// CHECK:       Visiting op 'func'
// CHECK:       Visiting op 'module'

// CHECK-LABEL: Block post-order visits
// CHECK:       Visiting block ^bb0 from region 0 from operation 'scf.if'
// CHECK:       Visiting block ^bb0 from region 1 from operation 'scf.if'
// CHECK:       Visiting block ^bb0 from region 0 from operation 'scf.for'
// CHECK:       Visiting block ^bb0 from region 0 from operation 'func'
// CHECK:       Visiting block ^bb0 from region 0 from operation 'module'

// CHECK-LABEL: Region post-order visits
// CHECK:       Visiting region 0 from operation 'scf.if'
// CHECK:       Visiting region 1 from operation 'scf.if'
// CHECK:       Visiting region 0 from operation 'scf.for'
// CHECK:       Visiting region 0 from operation 'func'
// CHECK:       Visiting region 0 from operation 'module'

// CHECK-LABEL: Op pre-order erasures
// CHECK:       Erasing op 'scf.for'
// CHECK:       Erasing op 'std.return'

// CHECK-LABEL: Block pre-order erasures
// CHECK:       Erasing block ^bb0 from region 0 from operation 'scf.for'

// CHECK-LABEL: Op post-order erasures (skip)
// CHECK:       Erasing op 'use0'
// CHECK:       Erasing op 'use1'
// CHECK:       Erasing op 'use2'
// CHECK:       Erasing op 'scf.if'
// CHECK:       Erasing op 'use3'
// CHECK:       Erasing op 'scf.for'
// CHECK:       Erasing op 'std.return'

// CHECK-LABEL: Block post-order erasures (skip)
// CHECK:       Erasing block ^bb0 from region 0 from operation 'scf.if'
// CHECK:       Erasing block ^bb0 from region 1 from operation 'scf.if'
// CHECK:       Erasing block ^bb0 from region 0 from operation 'scf.for'

// CHECK-LABEL: Op post-order erasures (no skip)
// CHECK:       Erasing op 'use0'
// CHECK:       Erasing op 'use1'
// CHECK:       Erasing op 'use2'
// CHECK:       Erasing op 'scf.if'
// CHECK:       Erasing op 'use3'
// CHECK:       Erasing op 'scf.for'
// CHECK:       Erasing op 'std.return'
// CHECK:       Erasing op 'func'
// CHECK:       Erasing op 'module'

// CHECK-LABEL: Block post-order erasures (no skip)
// CHECK:       Erasing block ^bb0 from region 0 from operation 'scf.if'
// CHECK:       Erasing block ^bb0 from region 1 from operation 'scf.if'
// CHECK:       Erasing block ^bb0 from region 0 from operation 'scf.for'
// CHECK:       Erasing block ^bb0 from region 0 from operation 'func'
// CHECK:       Erasing block ^bb0 from region 0 from operation 'module'

// -----

func @unstructured_cfg() {
  "regionOp0"() ({
    ^bb0:
      "op0"() : () -> ()
      br ^bb2
    ^bb1:
      "op1"() : () -> ()
      br ^bb2
    ^bb2:
      "op2"() : () -> ()
  }) : () -> ()
  return
}

// CHECK-LABEL: Op pre-order visits
// CHECK:       Visiting op 'module'
// CHECK:       Visiting op 'func'
// CHECK:       Visiting op 'regionOp0'
// CHECK:       Visiting op 'op0'
// CHECK:       Visiting op 'std.br'
// CHECK:       Visiting op 'op1'
// CHECK:       Visiting op 'std.br'
// CHECK:       Visiting op 'op2'
// CHECK:       Visiting op 'std.return'

// CHECK-LABEL: Block pre-order visits
// CHECK:       Visiting block ^bb0 from region 0 from operation 'module'
// CHECK:       Visiting block ^bb0 from region 0 from operation 'func'
// CHECK:       Visiting block ^bb0 from region 0 from operation 'regionOp0'
// CHECK:       Visiting block ^bb1 from region 0 from operation 'regionOp0'
// CHECK:       Visiting block ^bb2 from region 0 from operation 'regionOp0'

// CHECK-LABEL: Region pre-order visits
// CHECK:       Visiting region 0 from operation 'module'
// CHECK:       Visiting region 0 from operation 'func'
// CHECK:       Visiting region 0 from operation 'regionOp0'

// CHECK-LABEL: Op post-order visits
// CHECK:       Visiting op 'op0'
// CHECK:       Visiting op 'std.br'
// CHECK:       Visiting op 'op1'
// CHECK:       Visiting op 'std.br'
// CHECK:       Visiting op 'op2'
// CHECK:       Visiting op 'regionOp0'
// CHECK:       Visiting op 'std.return'
// CHECK:       Visiting op 'func'
// CHECK:       Visiting op 'module'

// CHECK-LABEL: Block post-order visits
// CHECK:       Visiting block ^bb0 from region 0 from operation 'regionOp0'
// CHECK:       Visiting block ^bb1 from region 0 from operation 'regionOp0'
// CHECK:       Visiting block ^bb2 from region 0 from operation 'regionOp0'
// CHECK:       Visiting block ^bb0 from region 0 from operation 'func'
// CHECK:       Visiting block ^bb0 from region 0 from operation 'module'

// CHECK-LABEL: Region post-order visits
// CHECK:       Visiting region 0 from operation 'regionOp0'
// CHECK:       Visiting region 0 from operation 'func'
// CHECK:       Visiting region 0 from operation 'module'

// CHECK-LABEL: Op pre-order erasures (skip)
// CHECK:       Erasing op 'regionOp0'
// CHECK:       Erasing op 'std.return'

// CHECK-LABEL: Block pre-order erasures (skip)
// CHECK:       Erasing block ^bb0 from region 0 from operation 'regionOp0'
// CHECK:       Erasing block ^bb0 from region 0 from operation 'regionOp0'
// CHECK:       Erasing block ^bb0 from region 0 from operation 'regionOp0'

// CHECK-LABEL: Op post-order erasures (skip)
// CHECK:       Erasing op 'op0'
// CHECK:       Erasing op 'std.br'
// CHECK:       Erasing op 'op1'
// CHECK:       Erasing op 'std.br'
// CHECK:       Erasing op 'op2'
// CHECK:       Erasing op 'regionOp0'
// CHECK:       Erasing op 'std.return'

// CHECK-LABEL: Block post-order erasures (skip)
// CHECK:       Erasing block ^bb0 from region 0 from operation 'regionOp0'
// CHECK:       Erasing block ^bb0 from region 0 from operation 'regionOp0'
// CHECK:       Erasing block ^bb0 from region 0 from operation 'regionOp0'

// CHECK-LABEL: Op post-order erasures (no skip)
// CHECK:       Erasing op 'op0'
// CHECK:       Erasing op 'std.br'
// CHECK:       Erasing op 'op1'
// CHECK:       Erasing op 'std.br'
// CHECK:       Erasing op 'op2'
// CHECK:       Erasing op 'regionOp0'
// CHECK:       Erasing op 'std.return'

// CHECK-LABEL: Block post-order erasures (no skip)
// CHECK:       Erasing block ^bb0 from region 0 from operation 'regionOp0'
// CHECK:       Erasing block ^bb0 from region 0 from operation 'regionOp0'
// CHECK:       Erasing block ^bb0 from region 0 from operation 'regionOp0'
// CHECK:       Erasing block ^bb0 from region 0 from operation 'func'
// CHECK:       Erasing block ^bb0 from region 0 from operation 'module'
