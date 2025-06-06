// Copyright 2022 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#ifndef IREE_COMPILER_CODEGEN_COMMON_TRANSFORMEXTENSIONS_COMMONEXTENSIONS
#define IREE_COMPILER_CODEGEN_COMMON_TRANSFORMEXTENSIONS_COMMONEXTENSIONS

include "mlir/Dialect/Transform/Interfaces/MatchInterfaces.td"
include "mlir/Dialect/Transform/IR/TransformAttrs.td"
include "mlir/Dialect/Transform/IR/TransformDialect.td"
include "mlir/Dialect/Transform/IR/TransformTypes.td"
include "mlir/Dialect/Transform/Interfaces/TransformInterfaces.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Dialect/SCF/IR/DeviceMappingInterface.td"
include "mlir/IR/EnumAttr.td"
include "mlir/IR/OpBase.td"

def ApplyBubbleCollapsePatternsOp : Op<Transform_Dialect,
    "apply_patterns.iree.bubble_collapse",
    [DeclareOpInterfaceMethods<PatternDescriptorOpInterface>,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Populate patterns to fold an expanding tensor.expand_shape operation with
    its producer generic operation by collapsing the dimensions of the generic
    op.
  }];

  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let assemblyFormat = "attr-dict";
}

def ApplyBubbleExpandPatternsOp : Op<Transform_Dialect,
    "apply_patterns.iree.bubble_expand",
    [DeclareOpInterfaceMethods<PatternDescriptorOpInterface>,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Populate patterns to fold an expanding (collapsing) tensor_reshape
    operation with its producer (consumer) generic operation by expanding
    the dimensionality of the loop in the generic op.
  }];

  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let assemblyFormat = "attr-dict";
}

def ApplyBubblePackUnpackPatternsOp : Op<Transform_Dialect,
    "apply_patterns.iree.bubble_pack_unpack",
    [DeclareOpInterfaceMethods<PatternDescriptorOpInterface>,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Populate patterns to bubble up or down data layout ops across other
    operations.
  }];

  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let assemblyFormat = "attr-dict";
}

def ApplyFoldFillIntoPadPatternsOp : Op<Transform_Dialect,
    "apply_patterns.iree.fold_fill_into_pad",
    [DeclareOpInterfaceMethods<PatternDescriptorOpInterface>,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Populates a pattern that folds
    "tensor.pad(cst, tensor.extract*(linalg.fill(cst)))" into
    "linalg.fill(cst, empty)" when the padding constant and the fill constant
    are the same.
  }];

  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let assemblyFormat = "attr-dict";
}

def ApplyFoldReshapeIntoTensorHalInterfacePatternsOp : Op<Transform_Dialect,
    "apply_patterns.iree.fold_reshape_into_tensor_hal_interface",
    [DeclareOpInterfaceMethods<PatternDescriptorOpInterface>,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Populate patterns that fold tensor.expand_shape/tensor.collapse_shape into
    the source hal.interface.binding.subspan op.
  }];

  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let assemblyFormat = "attr-dict";
}

def ApplyFoldTensorSliceIntoTransferPatternsOp : Op<Transform_Dialect,
    "apply_patterns.iree.fold_tensor_slice_into_transfer",
    [DeclareOpInterfaceMethods<PatternDescriptorOpInterface>]> {
  let description = [{
    Indicates that tensor.extract_slice -> vector.transfer_read and
    vector.transfer_write -> tensor.insert_slice op chains should be folded into
    vector tranfer read and write ops
  }];

  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let assemblyFormat = "attr-dict";
}

def ApplyHoistForallFromForPatternsOp : Op<Transform_Dialect,
    "apply_patterns.iree.hoist_forall_from_for",
    [DeclareOpInterfaceMethods<PatternDescriptorOpInterface>]> {
  let description = [{
    Hoists perfectly nested `scf.forall` ops from parent `scf.for` ops if
    the slice the forall loop operates on is loop invariant w.r.t. the for loop.

    This pattern only applies to forall ops that yield tensors. For bufferized
    loops the parallel loop is always trivially hoistable with a barrier and
    happens automatically when lowering the `scf.forall`.

    Currently only supports a single result tensor.
  }];

  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let assemblyFormat = "attr-dict";
}

def ApplyIREELinalgElementwiseGreedyFusionPatternsOp : Op<Transform_Dialect,
    "apply_patterns.iree.linalg_elementwise_greedy_fusion",
    [DeclareOpInterfaceMethods<PatternDescriptorOpInterface>,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Populate patterns to fuse `linalg.generic` -> `linalg.generic` operations
    when both operations are fusable elementwise operations.

    Note: This pattern set is parameterized for usage in IREE, therefore
    it is called "iree.linalg_elementwise_greedy_fusion".
  }];

  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let assemblyFormat = "attr-dict";
}

def ApplyPrepareVectorToMMAPatternsOp : Op<Transform_Dialect,
    "apply_patterns.iree.prepare_vector_to_mma",
    [DeclareOpInterfaceMethods<PatternDescriptorOpInterface>,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Populate patterns that transform vector ops into a canonical form to
    convert to MMA matrix operations. If `useNvGpu` is true, then the patterns
    will populated will prepare for conversion to `nvgpu` mma operations
    rather than the `gpu` dialect WMMA operations.
  }];

  let arguments = (ins DefaultValuedAttr<BoolAttr, "true">:$useNvGpu);
  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let assemblyFormat = "attr-dict";
}

def ApplyUnrollVectorsGpuMmaSyncPatternsOp : Op<Transform_Dialect,
    "apply_patterns.iree.unroll_vectors_gpu_mma_sync",
    [DeclareOpInterfaceMethods<PatternDescriptorOpInterface>,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Populate patterns that unroll vectors. TODO: better documentation.
  }];

  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let assemblyFormat = "attr-dict";
}

def ApplyUnrollVectorsGpuWmmaSyncPatternsOp : Op<Transform_Dialect,
    "apply_patterns.iree.unroll_vectors_gpu_wmma_sync",
    [DeclareOpInterfaceMethods<PatternDescriptorOpInterface>,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Populate patterns that unroll vectors. TODO: better documentation.
  }];

  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let assemblyFormat = "attr-dict";
}

def CopyTensorOperandOp :  Op<Transform_Dialect, "iree.copy_tensor_operand",
    [DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
     FunctionalStyleTransformOpTrait,
     TransformEachOpTrait,
     TransformOpInterface,
     ReportTrackingListenerFailuresOpTrait]> {
  let summary = [{Create a linalg copy of a specified value.}];
  let description = [{
    Inserts a copy of the specified operand of the target operation.

    #### Return modes
    Returns a handle to the new copy.

    It does not consume the target handle and emits a definite failure if the
    operand index is out of range or if the operand is not a tensor type.
  }];

  let arguments = (ins
    TransformHandleTypeInterface:$target,
    I64Attr:$operand_index);
  let results = (outs TransformHandleTypeInterface:$result);

  let assemblyFormat = [{
    $target `[` $operand_index `]` attr-dict
    `:` functional-type(operands, results)
  }];
  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::Operation *target,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def GpuDistributeSharedMemoryCopyOp :
  Op<Transform_Dialect, "iree.gpu_distribute_shared_memory_copy",
    [DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
     TransformOpInterface, TransformEachOpTrait]> {
  let summary = [{Distribute shared memory copies.}];
  let description = [{
    Find copies to/from shared memory and distribute the copies based on the
    workgroup size.

    #### Return modes
    This operation applies to the entire function and does not consume the
    target handle. It always return success.
  }];

  let arguments = (ins TransformHandleTypeInterface:$target);
  let results = (outs);

  let assemblyFormat = "$target attr-dict `:` functional-type(operands, results)";
  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::FunctionOpInterface target,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def HoistStaticAllocOp :  Op<Transform_Dialect, "iree.hoist_static_alloc",
    [DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
     TransformEachOpTrait,
     TransformOpInterface,
     ReportTrackingListenerFailuresOpTrait]> {
  let summary = [{Hoist static allocations.}];
  let description = [{
    Find static allocations and hoist them to the top level.

    #### Return modes
    This transform applies static alloc hoisting the whole region of the operand.

    It does not consume the target handle and always return success.
  }];

  let arguments = (ins TransformHandleTypeInterface:$target);
  let results = (outs);

  let assemblyFormat = "$target attr-dict `:` functional-type(operands, results)";
  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::FunctionOpInterface funcOp,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def FlattenForallMappingOp : Op<Transform_Dialect, "iree.flatten_forall_mapping",
    [TransformEachOpTrait,
     DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
     TransformOpInterface,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Flattens the thread mapping of an `scf.forall` op.

    #### Return modes
    Emits a definite failure if the target is not an scf.forall op or if
    the mapping type is not `gpu.thread` or `gpu.warp` with linear dims in
    descending order.
  }];

  let arguments = (ins TransformHandleTypeInterface:$target);
  let results = (outs TransformHandleTypeInterface:$result);

  let assemblyFormat = [{
    $target attr-dict `:` functional-type(operands, results)
  }];
  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::scf::ForallOp target,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def ForallToWorkgroupOp : Op<Transform_Dialect,
    "iree.forall_to_workgroup",
    [DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
     TransformEachOpTrait,
     TransformOpInterface,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Target the whole hal.executable_variant op and rewrite the unique topLevel
    scf.forall to distributed workgroup_id and workgroup_count.

    The mapping of threads to workgroup_id is currently one-to-one and in order.
    Only **bufferized** scf.forall are currently supported.
    Only scf.forall distributed to **at most 3 dimensions** are currently
    supported.

    Return modes:
    =============
    This operation ignores non-Func ops and drops them in the return.

    If no unique scf.forall topLevel operation is found, then the
    transform definitely fails.
    If the unique topLevel scf.forall has results (i.e. tensors), then
    the transform definitely fails.

    If the unique topLevel scf.forall maps to a dynamic number of
    threads, then the transform definitely fails. This is a temporary
    limitation until the backward slice computing scf.forall.num_threads
    can be extracted into the hal::executable_export workgroup_count region.
    This region may require arbitrary computations and cannot magically match
    what the `stream.cmd.dispatch` has already imposed on us at a distance.
    For now we must specify the number of values properly when applying the
    topLevel tile_using_forall.

    If the unique topLevel scf.forall operation contained within the
    FuncOp referred to by the `target` transform handle lowers to workgroup
    properly, the transform succeeds.

    Otherwise the transform definitely fails.

    This transform does not consume its input handle and produces no result.
  }];

  let arguments = (ins TransformHandleTypeInterface:$target);
  let results = (outs);

  let assemblyFormat = "$target attr-dict `:` functional-type($target, results)";
  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::FunctionOpInterface target,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def IREEApplyLoopIndependentCodeMotionOp : Op<Transform_Dialect, "iree.apply_licm",
    [DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
     TransformEachOpTrait,
     TransformOpInterface,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Apply loop-independent code motion and single iteration loop promotion.
    This transform is applied to all FuncOps within the target. Distinguished
    from the upstream `apply_licm` op that only applies to a single loop with
    the `iree` prefix.

    #### Return modes

    This operation does not consume the target handle and does not produce any
    handle.
  }];

  let arguments = (ins TransformHandleTypeInterface:$target);
  let assemblyFormat = "$target attr-dict `:` type($target)";
  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::Operation *target,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def IREEBufferizeOp : Op<Transform_Dialect, "iree.bufferize",
    [FunctionalStyleTransformOpTrait,
     MemoryEffectsOpInterface,
     DeclareOpInterfaceMethods<TransformOpInterface>,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Target the whole hal.executable_variant op and call upstream comprehensive
    bufferize with extra IREE hooks.

    By default, CPU allocations are emitted. This behavior can be modified by
    using the following attributes:
      - target_gpu: if set, GPU allocations are emitted.

    #### Return modes

    This operation calls the upstream one-shot bufferization pass with extra
    registered patterns for IREE.

    The pass is ran on all the ModuleOp nested under the top-level op on which
    the transform dialect interpreter pass is applied.

    If any of the pass on any of the ModuleOp fails, the transformation
    definitely fails. Otherwise the transformation succeeds.

    This transform consumes the target handle and produces a result handle.
  }];

  let arguments = (
      ins TransformHandleTypeInterface:$target,
          UnitAttr:$target_gpu,
          UnitAttr:$test_analysis_only,
          UnitAttr:$print_conflicts
  );
  let results = (outs TransformHandleTypeInterface:$result);

  let assemblyFormat = "attr-dict $target `:` functional-type($target, results)";
  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";

  let builders = [
    OpBuilder<(ins "Value":$target,
                   CArg<"bool", "false">:$targetGpu,
                   CArg<"bool", "false">:$testAnalysisOnly,
                   CArg<"bool", "false">:$printConflicts)>
  ];
}

def IREEEliminateEmptyTensorsOp : Op<
    Transform_Dialect, "iree.eliminate_empty_tensors",
    [DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
     TransformEachOpTrait,
     TransformOpInterface,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    This is a pre-processing pass for iree.bufferize. It tries to remove
    tensor.empty ops by replacing them with suitable destination tensors,
    which can reduce the number of allocations when bufferizing.

    This transform is not part of iree.bufferize because additional
    canonicalization are sometimes possible after eliminate_empty_tensors but
    before iree.bufferize.

    #### Return modes

    This transform does not consume the target handle and always return success.
  }];

  let arguments = (ins TransformHandleTypeInterface:$target);
  let results = (outs);
  let assemblyFormat = "attr-dict $target `:` functional-type($target, results)";
  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::Operation *target,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def MatchHasNoLoweringConfigOp : Op<Transform_Dialect, "iree.match.has_no_lowering_config",
    [MatchOpInterface,
     SingleOpMatcher,
     MemoryEffectsOpInterface]> {
  let summary = [{
    Checks that the payload op does not carry a lowering config or compilation info.
  }];
  let description = [{
    Verifies that the payload does not have a "compilation_info" or
    "lowering_config" attribute. This is a very common check needed for external
    matchers to avoid overwriting already configured ops.

    #### Return modes

    Succeeds if the payload lacks a configuration. Produces a silenceable
    failure otherwise. Produces a definite failure if the operand is not
    associated with a single payload op.
  }];

  let arguments = (ins TransformHandleTypeInterface:$operand_handle);
  let results = (outs);
  let assemblyFormat = "$operand_handle attr-dict `:` type($operand_handle)";
  let extraClassDeclaration = SingleOpMatcher.extraDeclaration;

  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
}

def PopulateWorkgroupCountRegionUsingNumThreadsSliceOp :
    Op<Transform_Dialect, "iree.populate_workgroup_count_region_using_num_threads_slice",
      [DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
       TransformEachOpTrait,
       TransformOpInterface,
       ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Populate the workgroup_count region on the `hal.executable.export` op.

    The default dispatch region formation expects that the workgroup count
    be computed from within the dispatch by using a program slice. The utility
    method `lowerWorkgroupCountFromSliceOp` handles populating the
    workgroup count region given the values in the dispatch that represent the
    number of workgroups. This transform op calls the underlying function using
    the `num_threads` value from the `scf.for_all` op that distributes the work
    to different workgroups.
  }];

  let arguments = (ins TransformHandleTypeInterface:$for_all_op);
  let results = (outs);
  let assemblyFormat = [{
    attr-dict $for_all_op `:` functional-type($for_all_op, results)
  }];
  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";
  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
      ::mlir::transform::TransformRewriter &rewriter,
      ::mlir::Operation *target,
      ::mlir::transform::ApplyToEachResultList &results,
      ::mlir::transform::TransformState &state);
  }];
}

def ReduceSharedMemoryBankConflictsOp :  Op<Transform_Dialect, "iree.reduce_shared_memory_bank_conflicts",
    [DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
     TransformEachOpTrait,
     TransformOpInterface,
     ReportTrackingListenerFailuresOpTrait]> {
  let summary = [{Add padding to 'memref.alloc' ops reduce shared memory bank conflicts.}];
  let description = [{
    The `paddingSizeBits` argument should be picked based on the target
    architecture, striking balance between minimizing bank conflicts and keeping
    the data aligned. Smaller values (close to the bank bitwidth) achieve the
    former, while larger (~= widest load size) the latter. We want to **misalign**
    the rows, but not too much. For gfx942, 64 is a good default.

    #### Return modes

    This transform does not consume the target handle and always return success.
  }];

  let arguments = (
      ins TransformHandleTypeInterface:$target,
          DefaultValuedOptionalAttr<I64Attr, "64">:$padding_size_bits
  );
  let results = (outs);

  let assemblyFormat = "$target attr-dict `:` functional-type(operands, results)";
  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::FunctionOpInterface funcOp,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def ShareForallOperandsOp : Op<
    Transform_Dialect, "iree.share_forall_operands", [
      FunctionalStyleTransformOpTrait,
      MemoryEffectsOpInterface,
      TransformEachOpTrait,
      TransformOpInterface,
      ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Target a single scf.forall op and shares all uses of the specified
    `share_operands` operand indices.

    Sharing can be thought of as the inverse of traditional privatization.
    Privatization consists in determining that a part of memory is only accessed
    by a single thread to and subsequently slicing out that part into a
    thread_private storage that has smaller footprint, better locality and better
    alignment properties.
    In the case of scf.forall on tensors, tensor values are immutable
    and the same tensor value may be passed as `shared_outs` and also captured
    for internal uses.
    Due to the immutability property, the whole tensor values are private by
    construction and result in alloc + copy of the whole tensor on every thread
    to maintain the original SSA value after bufferizing.

    An analysis similar to privatization is needed to ensure that only a private
    slice is needed and that the whole tensor can be shared.
    This transformation amounts to injecting the result of such an analysis as
    static information in the program.
    The transformation checks that the values captured are `tensor.extract_slice`
    with a matching `tensor.parallel_insert_slice`, to approximate the lack of
    a cross-thread dependence analysis.
    However this can still be unsafe wrt parallelism so use carefully!

    Sharing consists in rewriting all uses of the operands passed as
    `shared_outs` that are also captured wihtin the `scf.forall` region
    into the matching `shared_outs` bbarg.

    Only those operands whose indices are specified in `share_operands` are
    shared. An empty `share_operands` specification considers all operands to
    be shared.

    #### Return modes

    If any of the `share_operands` indices overflow, a definite error is produced.

    If a `share_operands` fails a sharing precondition, it is ignored.
    In the future, we should emit a notification.

    This transform consumes the target handle and produces a result handle to
    the modified `scf.forall` op.
  }];

  let arguments = (
      ins TransformHandleTypeInterface:$forall_op,
          DefaultValuedOptionalAttr<DenseI64ArrayAttr, "{}">:$share_operands
  );
  let results = (outs TransformHandleTypeInterface:$result);

  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";

  let assemblyFormat = [{
    $forall_op (`share_operands` `=` $share_operands^ )? attr-dict
      `:` functional-type(operands, results)
  }];

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::scf::ForallOp forallOp,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def TestGpuVectorDistribution :
  Op<Transform_Dialect, "iree.test_gpu_vector_distribution",
    [DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
     TransformEachOpTrait,
     TransformOpInterface,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Run GPUVectorDistribution on the target as the root.

    The anchor points are set by using the attribute
    "__vector_layout_test_anchor_operand_x" and
    "__vector_layout_test_anchor_result_x", where "x" is the operand/result
    number.

    The distribution is done for a single warp using gpu.thread x as the lane
    ID. The optional experimental attribute enabled experimental distribution
    patterns.

    #### Return modes

    This transform does not consume the target handle and always return success.
    }];

    let arguments = (ins TransformHandleTypeInterface:$target,
                         DefaultValuedOptionalAttr<BoolAttr, "false">:$experimental,
                         DefaultValuedOptionalAttr<I64Attr, "64">:$subgroup_size);
    let results = (outs);

    let assemblyFormat = [{ $target attr-dict `:` type($target)}];
    let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";

    let extraClassDeclaration = [{
      ::mlir::DiagnosedSilenceableFailure applyToOne(
          ::mlir::transform::TransformRewriter &rewriter,
          ::mlir::FunctionOpInterface funcOp,
          ::mlir::transform::ApplyToEachResultList &results,
          ::mlir::transform::TransformState &state);
    }];
}

def TestVectorLayoutAnalysisOp :
  Op<Transform_Dialect, "iree.test_vector_layout_analysis",
    [DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
     TransformEachOpTrait,
     TransformOpInterface,
     ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Run VectorLayoutAnalysis on the target as the root.

    The anchor points are set by using the attribute
    "__vector_layout_test_anchor_operand_x" and
    "__vector_layout_test_anchor_result_x", where "x" is the operand/result
    number.

    The analysis emits remarks for the layout for each SSA value infered
    on it's owning operation.

    #### Return modes

    This transform does not consume the target handle and always return success.
    }];

    let arguments = (ins TransformHandleTypeInterface:$target);
    let results = (outs);

    let assemblyFormat = [{ $target attr-dict `:` type($target)}];
    let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";

    let extraClassDeclaration = [{
      ::mlir::DiagnosedSilenceableFailure applyToOne(
          ::mlir::transform::TransformRewriter &rewriter,
          ::mlir::FunctionOpInterface funcOp,
          ::mlir::transform::ApplyToEachResultList &results,
          ::mlir::transform::TransformState &state);
    }];
}

def FuseConsumerOp : Op<Transform_Dialect, "iree.fuse_consumer",
       [DeclareOpInterfaceMethods<TransformOpInterface>,
        DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
        ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Fuses the consumer of the operation pointed to by the target handle
    using the options provided as attributes.
  }];
  let cppNamespace = "mlir::iree_compiler::IREE::transform_dialect";

  let arguments =(ins
      TransformHandleTypeInterface:$target,
      Variadic<TransformHandleTypeInterface>:$loops);
  let results = (outs TransformHandleTypeInterface:$consumer,
                      TransformHandleTypeInterface:$fused_consumer);

  let assemblyFormat = [{
    $target `in` `(` $loops `)` attr-dict `:` functional-type(operands, results)
  }];
}

#endif // IREE_COMPILER_CODEGEN_COMMON_TRANSFORMEXTENSIONS_COMMONEXTENSIONS
