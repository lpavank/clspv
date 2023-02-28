; RUN: clspv-opt %s -o %t.ll -global-offset-push-constant --passes=define-opencl-workitem-builtins,early-cse,instcombine
; RUN: FileCheck %s < %t.ll

; CHECK: [[type:%[0-9]+]] = type { <3 x i32> }
; CHECK: @__push_constants = addrspace(9) global [[type]]

; CHECK: call spir_func i32 @_Z17get_global_offsetj(i32

; CHECK: define spir_func i32 @_Z17get_global_offsetj(i32 [[p:%[0-9]+]])
; CHECK: [[cmp:%[0-9]+]] = icmp ult i32 [[p]], 3
; CHECK: [[sel:%[0-9]+]] = select i1 [[cmp]], i32 [[p]], i32 0
; CHECK: [[gep:%[0-9]+]] = getelementptr inbounds [[type]], ptr addrspace(9) @__push_constants, i32 0, i32 0, i32 [[sel]]
; CHECK: [[ld:%[0-9]+]] = load i32, ptr addrspace(9) [[gep]]
; CHECK: [[sel:%[0-9]+]] = select i1 [[cmp]], i32 [[ld]], i32 0
; CHECK: ret i32 [[sel]]

target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir-unknown-unknown"

%0 = type { <3 x i32> }

@__push_constants = addrspace(9) global %0 zeroinitializer, !push_constants !0

define dso_local spir_kernel void @test(ptr addrspace(1) align 4 %out) #0 !reqd_work_group_size !8 !clspv.pod_args_impl !9 {
entry:
  %out.addr = alloca ptr, align 4, addrspace(1)
  store ptr addrspace(1) null, ptr addrspace(1) %out.addr, align 4
  store ptr addrspace(1) %out, ptr addrspace(1) %out.addr, align 4
  %0 = load ptr addrspace(1), ptr addrspace(1) %out.addr, align 4
  %arrayidx = getelementptr inbounds i32, ptr addrspace(1) %0, i32 1
  %1 = load i32, ptr addrspace(1) %arrayidx, align 4
  %call = call spir_func i32 @_Z17get_global_offsetj(i32 %1) #2
  %2 = load ptr addrspace(1), ptr addrspace(1) %out.addr, align 4
  %arrayidx1 = getelementptr inbounds i32, ptr addrspace(1) %2, i32 0
  store i32 %call, ptr addrspace(1) %arrayidx1, align 4
  ret void
}

declare spir_func i32 @_Z17get_global_offsetj(i32) #1

attributes #0 = { convergent norecurse nounwind "frame-pointer"="none" "min-legal-vector-width"="0" "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="0" "stackrealign" "uniform-work-group-size"="true" }
attributes #1 = { convergent nounwind readnone willreturn "frame-pointer"="none" "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="0" "stackrealign" }
attributes #2 = { convergent nobuiltin nounwind readnone willreturn "no-builtins" }

!0 = !{i32 1}
!8 = !{i32 1, i32 1, i32 1}
!9 = !{i32 3}

