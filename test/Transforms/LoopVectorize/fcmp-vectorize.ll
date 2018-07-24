; RUN: opt -loop-vectorize -force-vector-width=4 -force-vector-interleave=1 -S %s | FileCheck %s

; Avoid crashing while trying to vectorize fcmp that can be folded to vector of
; i1 true.
define void @test1() {
; CHECK-LABEL: test1(
; CHECK-LABEL: vector.body:
; CHECK-NEXT:    %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
; CHECK-NEXT:    %broadcast.splatinsert = insertelement <4 x i32> undef, i32 %index, i32 0
; CHECK:         %induction = add <4 x i32> %broadcast.splat, <i32 0, i32 1, i32 2, i32 3>
; CHECK:         %index.next = add i32 %index, 4

entry:
  br label %loop

loop:                                              ; preds = %loop, %entry
  %iv = phi i32 [ 0, %entry ], [ %ivnext, %loop ]
  %fcmp = fcmp uno float 0.000000e+00, 0.000000e+00
  %ivnext = add nsw i32 %iv, 1
  %cnd = icmp sgt i32 %iv, 142
  br i1 %cnd, label %exit, label %loop

exit:                                              ; preds = %loop
  ret void
}
