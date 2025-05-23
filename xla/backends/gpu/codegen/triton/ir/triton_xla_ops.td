/* Copyright 2024 The OpenXLA Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/


#ifndef XLA_BACKENDS_GPU_CODEGEN_TRITON_IR_TRITON_XLA_OPS_TD_
#define XLA_BACKENDS_GPU_CODEGEN_TRITON_IR_TRITON_XLA_OPS_TD_

include "mlir/IR/OpBase.td"
include "mlir/IR/OpAsmInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td" // Pure
include "mlir/Interfaces/InferTypeOpInterface.td" // SameOperandsAndResultType
include "mlir/Interfaces/ViewLikeInterface.td" // OffsetSizeAndStrideOpInterface
include "xla/backends/gpu/codegen/triton/ir/triton_xla_dialect.td"
include "triton/Dialect/Triton/IR/TritonInterfaces.td"
include "triton/Dialect/Triton/IR/TritonOpInterfaces.td"
include "triton/Dialect/Triton/IR/TritonTypes.td"
include "triton/Dialect/TritonGPU/IR/TritonGPUTypeInterfaces.td"

// -----------------------------------------------------------------------------
// Triton XLA Ops
// -----------------------------------------------------------------------------

class TTXLA_Op<string mnemonic, list<Trait> traits = []> :
      Op<XlaTritonDialect, mnemonic, traits> {
}

def TTXLA_ExtractOp : TTXLA_Op<"extract", [Pure, SameVariadicOperandSize,
    DeclareOpInterfaceMethods<OpAsmOpInterface, ["getAsmResultNames"]>]> {
  let summary = "Extract a tile from a tensor.";
  let description = [{
    Offsets, strides, and destination tensor size are used to specify the tile
    to extract. Minor-to-major layout should also be specified.

    Example:
      ```
      %tensor: tensor<120x320xbf16>
      %of = arith.constant 0 : index
      %st1 = arith.constant 120 : index
      %st2 = arith.constant 1 : index
      ...
      %extracted_tensor = triton_xla.extract %tensor [%of, %of][%st1, %st2]
        {layout = array<i64:1, 0>} : tensor<120x320xbf16> to tensor<16x64xbf16>
      ```
  }];

  let arguments = (ins
    AnyRankedTensor:$src,
    Variadic<Index>:$offsets,
    Variadic<Index>:$strides,
    DenseI64ArrayAttr:$layout
  );
  let results = (outs AnyRankedTensor:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

def TTXLA_InsertOp : TTXLA_Op<"insert", [Pure, SameVariadicOperandSize,
    DeclareOpInterfaceMethods<OpAsmOpInterface, ["getAsmResultNames"]>]> {
  let summary = "Insert a tile into a tensor.";
  let description = [{
    Offsets, strides, and source tensor size are used to specify the tile to
    insert into. Minor-to-major layout should also be specified.

    Example:
      ```
      %src: tensor<16x64xbf16>
      %dst: tensor<120x320xbf16>
      %of = arith.constant 0 : index
      %st1 = arith.constant 120 : index
      %st2 = arith.constant 1 : index
      ...
      %updated_tensor = triton_xla.insert %src into %dst [%of, %of][%st1, %st2]
        {layout = array<i64:1, 0>} : tensor<16x64xbf16> into tensor<120x320xbf16>
      ```
  }];

  let arguments = (ins
    AnyRankedTensor:$src,
    AnyRankedTensor:$dst,
    Variadic<Index>:$offsets,
    Variadic<Index>:$strides,
    DenseI64ArrayAttr:$layout
  );
  let results = (outs AnyRankedTensor:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

#endif // XLA_BACKENDS_GPU_CODEGEN_TRITON_IR_TRITON_XLA_OPS_TD_
