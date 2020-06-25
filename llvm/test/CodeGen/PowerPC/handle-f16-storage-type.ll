; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=pwr8 -mtriple=powerpc64le-unknown-unknown \
; RUN:   -verify-machineinstrs -ppc-asm-full-reg-names < %s | FileCheck %s \
; RUN:   --check-prefix=P8
; RUN: llc -mcpu=pwr9 -mtriple=powerpc64le-unknown-unknown \
; RUN:   -verify-machineinstrs -ppc-asm-full-reg-names < %s | FileCheck %s
; RUN: llc -mcpu=pwr9 -mtriple=powerpc64le-unknown-unknown -mattr=-hard-float \
; RUN:   -verify-machineinstrs -ppc-asm-full-reg-names < %s | FileCheck %s \
; RUN:   --check-prefix=SOFT

; Tests for various operations on half precison float. Much of the test is
; copied from test/CodeGen/X86/half.ll.
define dso_local double @loadd(i16* nocapture readonly %a) local_unnamed_addr #0 {
; P8-LABEL: loadd:
; P8:       # %bb.0: # %entry
; P8-NEXT:    mflr r0
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -32(r1)
; P8-NEXT:    lhz r3, 2(r3)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    addi r1, r1, 32
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: loadd:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addi r3, r3, 2
; CHECK-NEXT:    lxsihzx f0, 0, r3
; CHECK-NEXT:    xscvhpdp f1, f0
; CHECK-NEXT:    blr
;
; SOFT-LABEL: loadd:
; SOFT:       # %bb.0: # %entry
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -32(r1)
; SOFT-NEXT:    lhz r3, 2(r3)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __extendsfdf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    addi r1, r1, 32
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds i16, i16* %a, i64 1
  %0 = load i16, i16* %arrayidx, align 2
  %1 = tail call double @llvm.convert.from.fp16.f64(i16 %0)
  ret double %1
}

declare double @llvm.convert.from.fp16.f64(i16)

define dso_local float @loadf(i16* nocapture readonly %a) local_unnamed_addr #0 {
; P8-LABEL: loadf:
; P8:       # %bb.0: # %entry
; P8-NEXT:    mflr r0
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -32(r1)
; P8-NEXT:    lhz r3, 2(r3)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    addi r1, r1, 32
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: loadf:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addi r3, r3, 2
; CHECK-NEXT:    lxsihzx f0, 0, r3
; CHECK-NEXT:    xscvhpdp f1, f0
; CHECK-NEXT:    blr
;
; SOFT-LABEL: loadf:
; SOFT:       # %bb.0: # %entry
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -32(r1)
; SOFT-NEXT:    lhz r3, 2(r3)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    addi r1, r1, 32
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds i16, i16* %a, i64 1
  %0 = load i16, i16* %arrayidx, align 2
  %1 = tail call float @llvm.convert.from.fp16.f32(i16 %0)
  ret float %1
}

declare float @llvm.convert.from.fp16.f32(i16)

define dso_local void @stored(i16* nocapture %a, double %b) local_unnamed_addr #0 {
; P8-LABEL: stored:
; P8:       # %bb.0: # %entry
; P8-NEXT:    mflr r0
; P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -48(r1)
; P8-NEXT:    mr r30, r3
; P8-NEXT:    bl __truncdfhf2
; P8-NEXT:    nop
; P8-NEXT:    sth r3, 0(r30)
; P8-NEXT:    addi r1, r1, 48
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: stored:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xscvdphp f0, f1
; CHECK-NEXT:    stxsihx f0, 0, r3
; CHECK-NEXT:    blr
;
; SOFT-LABEL: stored:
; SOFT:       # %bb.0: # %entry
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -48(r1)
; SOFT-NEXT:    mr r30, r3
; SOFT-NEXT:    mr r3, r4
; SOFT-NEXT:    bl __truncdfhf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    clrldi r3, r3, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 0(r30)
; SOFT-NEXT:    addi r1, r1, 48
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
entry:
  %0 = tail call i16 @llvm.convert.to.fp16.f64(double %b)
  store i16 %0, i16* %a, align 2
  ret void
}

declare i16 @llvm.convert.to.fp16.f64(double)

define dso_local void @storef(i16* nocapture %a, float %b) local_unnamed_addr #0 {
; P8-LABEL: storef:
; P8:       # %bb.0: # %entry
; P8-NEXT:    mflr r0
; P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -48(r1)
; P8-NEXT:    mr r30, r3
; P8-NEXT:    bl __gnu_f2h_ieee
; P8-NEXT:    nop
; P8-NEXT:    sth r3, 0(r30)
; P8-NEXT:    addi r1, r1, 48
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: storef:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xscvdphp f0, f1
; CHECK-NEXT:    stxsihx f0, 0, r3
; CHECK-NEXT:    blr
;
; SOFT-LABEL: storef:
; SOFT:       # %bb.0: # %entry
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -48(r1)
; SOFT-NEXT:    mr r30, r3
; SOFT-NEXT:    clrldi r3, r4, 32
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    clrldi r3, r3, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 0(r30)
; SOFT-NEXT:    addi r1, r1, 48
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
entry:
  %0 = tail call i16 @llvm.convert.to.fp16.f32(float %b)
  store i16 %0, i16* %a, align 2
  ret void
}

declare i16 @llvm.convert.to.fp16.f32(float)
define void @test_load_store(half* %in, half* %out) #0 {
; P8-LABEL: test_load_store:
; P8:       # %bb.0:
; P8-NEXT:    lhz r3, 0(r3)
; P8-NEXT:    sth r3, 0(r4)
; P8-NEXT:    blr
;
; CHECK-LABEL: test_load_store:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lhz r3, 0(r3)
; CHECK-NEXT:    sth r3, 0(r4)
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_load_store:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -48(r1)
; SOFT-NEXT:    lhz r3, 0(r3)
; SOFT-NEXT:    mr r30, r4
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 0(r30)
; SOFT-NEXT:    addi r1, r1, 48
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
  %val = load half, half* %in
  store half %val, half* %out
  ret void
}
define i16 @test_bitcast_from_half(half* %addr) #0 {
; P8-LABEL: test_bitcast_from_half:
; P8:       # %bb.0:
; P8-NEXT:    lhz r3, 0(r3)
; P8-NEXT:    blr
;
; CHECK-LABEL: test_bitcast_from_half:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lhz r3, 0(r3)
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_bitcast_from_half:
; SOFT:       # %bb.0:
; SOFT-NEXT:    lhz r3, 0(r3)
; SOFT-NEXT:    blr
  %val = load half, half* %addr
  %val_int = bitcast half %val to i16
  ret i16 %val_int
}
define void @test_bitcast_to_half(half* %addr, i16 %in) #0 {
; P8-LABEL: test_bitcast_to_half:
; P8:       # %bb.0:
; P8-NEXT:    sth r4, 0(r3)
; P8-NEXT:    blr
;
; CHECK-LABEL: test_bitcast_to_half:
; CHECK:       # %bb.0:
; CHECK-NEXT:    sth r4, 0(r3)
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_bitcast_to_half:
; SOFT:       # %bb.0:
; SOFT-NEXT:    sth r4, 0(r3)
; SOFT-NEXT:    blr
  %val_fp = bitcast i16 %in to half
  store half %val_fp, half* %addr
  ret void
}
define float @test_extend32(half* %addr) #0 {
; P8-LABEL: test_extend32:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -32(r1)
; P8-NEXT:    lhz r3, 0(r3)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    addi r1, r1, 32
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_extend32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lxsihzx f0, 0, r3
; CHECK-NEXT:    xscvhpdp f1, f0
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_extend32:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -32(r1)
; SOFT-NEXT:    lhz r3, 0(r3)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    addi r1, r1, 32
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
  %val16 = load half, half* %addr
  %val32 = fpext half %val16 to float
  ret float %val32
}
define double @test_extend64(half* %addr) #0 {
; P8-LABEL: test_extend64:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -32(r1)
; P8-NEXT:    lhz r3, 0(r3)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    addi r1, r1, 32
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_extend64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lxsihzx f0, 0, r3
; CHECK-NEXT:    xscvhpdp f1, f0
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_extend64:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -32(r1)
; SOFT-NEXT:    lhz r3, 0(r3)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __extendsfdf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    addi r1, r1, 32
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
  %val16 = load half, half* %addr
  %val32 = fpext half %val16 to double
  ret double %val32
}
define void @test_trunc32(float %in, half* %addr) #0 {
; P8-LABEL: test_trunc32:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -48(r1)
; P8-NEXT:    mr r30, r4
; P8-NEXT:    bl __gnu_f2h_ieee
; P8-NEXT:    nop
; P8-NEXT:    sth r3, 0(r30)
; P8-NEXT:    addi r1, r1, 48
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_trunc32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xscvdphp f0, f1
; CHECK-NEXT:    stxsihx f0, 0, r4
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_trunc32:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -48(r1)
; SOFT-NEXT:    clrldi r3, r3, 32
; SOFT-NEXT:    mr r30, r4
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    clrldi r3, r3, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 0(r30)
; SOFT-NEXT:    addi r1, r1, 48
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
  %val16 = fptrunc float %in to half
  store half %val16, half* %addr
  ret void
}
define void @test_trunc64(double %in, half* %addr) #0 {
; P8-LABEL: test_trunc64:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -48(r1)
; P8-NEXT:    mr r30, r4
; P8-NEXT:    bl __truncdfhf2
; P8-NEXT:    nop
; P8-NEXT:    sth r3, 0(r30)
; P8-NEXT:    addi r1, r1, 48
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_trunc64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xscvdphp f0, f1
; CHECK-NEXT:    stxsihx f0, 0, r4
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_trunc64:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -48(r1)
; SOFT-NEXT:    mr r30, r4
; SOFT-NEXT:    bl __truncdfhf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    clrldi r3, r3, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 0(r30)
; SOFT-NEXT:    addi r1, r1, 48
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
  %val16 = fptrunc double %in to half
  store half %val16, half* %addr
  ret void
}
define i64 @test_fptosi_i64(half* %p) #0 {
; P8-LABEL: test_fptosi_i64:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -32(r1)
; P8-NEXT:    lhz r3, 0(r3)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    xscvdpsxds f0, f1
; P8-NEXT:    mffprd r3, f0
; P8-NEXT:    addi r1, r1, 32
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_fptosi_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lhz r3, 0(r3)
; CHECK-NEXT:    mtfprwz f0, r3
; CHECK-NEXT:    xscvhpdp f0, f0
; CHECK-NEXT:    xscvdpsxds f0, f0
; CHECK-NEXT:    mffprd r3, f0
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_fptosi_i64:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -32(r1)
; SOFT-NEXT:    lhz r3, 0(r3)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __fixsfdi
; SOFT-NEXT:    nop
; SOFT-NEXT:    addi r1, r1, 32
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
  %a = load half, half* %p, align 2
  %r = fptosi half %a to i64
  ret i64 %r
}
define void @test_sitofp_i64(i64 %a, half* %p) #0 {
; P8-LABEL: test_sitofp_i64:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -48(r1)
; P8-NEXT:    mtfprd f0, r3
; P8-NEXT:    mr r30, r4
; P8-NEXT:    xscvsxdsp f1, f0
; P8-NEXT:    bl __gnu_f2h_ieee
; P8-NEXT:    nop
; P8-NEXT:    sth r3, 0(r30)
; P8-NEXT:    addi r1, r1, 48
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_sitofp_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    mtfprd f0, r3
; CHECK-NEXT:    xscvsxdsp f0, f0
; CHECK-NEXT:    xscvdphp f0, f0
; CHECK-NEXT:    mffprwz r3, f0
; CHECK-NEXT:    sth r3, 0(r4)
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_sitofp_i64:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -48(r1)
; SOFT-NEXT:    mr r30, r4
; SOFT-NEXT:    bl __floatdisf
; SOFT-NEXT:    nop
; SOFT-NEXT:    clrldi r3, r3, 32
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    clrldi r3, r3, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 0(r30)
; SOFT-NEXT:    addi r1, r1, 48
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
  %r = sitofp i64 %a to half
  store half %r, half* %p
  ret void
}
define i64 @test_fptoui_i64(half* %p) #0 {
; P8-LABEL: test_fptoui_i64:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -32(r1)
; P8-NEXT:    lhz r3, 0(r3)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    xscvdpuxds f0, f1
; P8-NEXT:    mffprd r3, f0
; P8-NEXT:    addi r1, r1, 32
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_fptoui_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lhz r3, 0(r3)
; CHECK-NEXT:    mtfprwz f0, r3
; CHECK-NEXT:    xscvhpdp f0, f0
; CHECK-NEXT:    xscvdpuxds f0, f0
; CHECK-NEXT:    mffprd r3, f0
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_fptoui_i64:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -32(r1)
; SOFT-NEXT:    lhz r3, 0(r3)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __fixunssfdi
; SOFT-NEXT:    nop
; SOFT-NEXT:    addi r1, r1, 32
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
  %a = load half, half* %p, align 2
  %r = fptoui half %a to i64
  ret i64 %r
}
define void @test_uitofp_i64(i64 %a, half* %p) #0 {
; P8-LABEL: test_uitofp_i64:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -48(r1)
; P8-NEXT:    mtfprd f0, r3
; P8-NEXT:    mr r30, r4
; P8-NEXT:    xscvuxdsp f1, f0
; P8-NEXT:    bl __gnu_f2h_ieee
; P8-NEXT:    nop
; P8-NEXT:    sth r3, 0(r30)
; P8-NEXT:    addi r1, r1, 48
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_uitofp_i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    mtfprd f0, r3
; CHECK-NEXT:    xscvuxdsp f0, f0
; CHECK-NEXT:    xscvdphp f0, f0
; CHECK-NEXT:    mffprwz r3, f0
; CHECK-NEXT:    sth r3, 0(r4)
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_uitofp_i64:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -48(r1)
; SOFT-NEXT:    mr r30, r4
; SOFT-NEXT:    bl __floatundisf
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    clrldi r3, r3, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 0(r30)
; SOFT-NEXT:    addi r1, r1, 48
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
  %r = uitofp i64 %a to half
  store half %r, half* %p
  ret void
}
define <4 x float> @test_extend32_vec4(<4 x half>* %p) #0 {
; P8-LABEL: test_extend32_vec4:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -112(r1)
; P8-NEXT:    mr r30, r3
; P8-NEXT:    lhz r3, 6(r3)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    li r3, 80
; P8-NEXT:    # kill: def $f1 killed $f1 def $vsl1
; P8-NEXT:    stxvd2x vs1, r1, r3 # 16-byte Folded Spill
; P8-NEXT:    lhz r3, 2(r30)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    li r3, 64
; P8-NEXT:    # kill: def $f1 killed $f1 def $vsl1
; P8-NEXT:    stxvd2x vs1, r1, r3 # 16-byte Folded Spill
; P8-NEXT:    lhz r3, 4(r30)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    li r3, 48
; P8-NEXT:    # kill: def $f1 killed $f1 def $vsl1
; P8-NEXT:    stxvd2x vs1, r1, r3 # 16-byte Folded Spill
; P8-NEXT:    lhz r3, 0(r30)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    li r3, 80
; P8-NEXT:    # kill: def $f1 killed $f1 def $vsl1
; P8-NEXT:    lxvd2x vs0, r1, r3 # 16-byte Folded Reload
; P8-NEXT:    li r3, 64
; P8-NEXT:    lxvd2x vs2, r1, r3 # 16-byte Folded Reload
; P8-NEXT:    li r3, 48
; P8-NEXT:    xxmrghd vs0, vs0, vs2
; P8-NEXT:    lxvd2x vs2, r1, r3 # 16-byte Folded Reload
; P8-NEXT:    xxmrghd vs1, vs2, vs1
; P8-NEXT:    xvcvdpsp vs34, vs0
; P8-NEXT:    xvcvdpsp vs35, vs1
; P8-NEXT:    vmrgew v2, v2, v3
; P8-NEXT:    addi r1, r1, 112
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_extend32_vec4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lhz r4, 6(r3)
; CHECK-NEXT:    mtfprwz f0, r4
; CHECK-NEXT:    xscvhpdp f0, f0
; CHECK-NEXT:    lhz r4, 2(r3)
; CHECK-NEXT:    mtfprwz f1, r4
; CHECK-NEXT:    xscvhpdp f1, f1
; CHECK-NEXT:    lhz r4, 4(r3)
; CHECK-NEXT:    mtfprwz f2, r4
; CHECK-NEXT:    xscvhpdp f2, f2
; CHECK-NEXT:    lhz r3, 0(r3)
; CHECK-NEXT:    xxmrghd vs0, vs0, vs1
; CHECK-NEXT:    mtfprwz f3, r3
; CHECK-NEXT:    xscvhpdp f3, f3
; CHECK-NEXT:    xxmrghd vs2, vs2, vs3
; CHECK-NEXT:    xvcvdpsp vs34, vs2
; CHECK-NEXT:    xvcvdpsp vs35, vs0
; CHECK-NEXT:    vmrgew v2, v3, v2
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_extend32_vec4:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r27, -40(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r28, -32(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r29, -24(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -80(r1)
; SOFT-NEXT:    mr r30, r3
; SOFT-NEXT:    lhz r3, 0(r3)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r29, r3
; SOFT-NEXT:    lhz r3, 2(r30)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r28, r3
; SOFT-NEXT:    lhz r3, 4(r30)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r27, r3
; SOFT-NEXT:    lhz r3, 6(r30)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r6, r3
; SOFT-NEXT:    mr r3, r29
; SOFT-NEXT:    mr r4, r28
; SOFT-NEXT:    mr r5, r27
; SOFT-NEXT:    addi r1, r1, 80
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; SOFT-NEXT:    ld r29, -24(r1) # 8-byte Folded Reload
; SOFT-NEXT:    ld r28, -32(r1) # 8-byte Folded Reload
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    ld r27, -40(r1) # 8-byte Folded Reload
; SOFT-NEXT:    blr
  %a = load <4 x half>, <4 x half>* %p, align 8
  %b = fpext <4 x half> %a to <4 x float>
  ret <4 x float> %b
}
define <4 x double> @test_extend64_vec4(<4 x half>* %p) #0 {
; P8-LABEL: test_extend64_vec4:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -112(r1)
; P8-NEXT:    mr r30, r3
; P8-NEXT:    lhz r3, 6(r3)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    li r3, 80
; P8-NEXT:    # kill: def $f1 killed $f1 def $vsl1
; P8-NEXT:    stxvd2x vs1, r1, r3 # 16-byte Folded Spill
; P8-NEXT:    lhz r3, 4(r30)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    li r3, 64
; P8-NEXT:    # kill: def $f1 killed $f1 def $vsl1
; P8-NEXT:    stxvd2x vs1, r1, r3 # 16-byte Folded Spill
; P8-NEXT:    lhz r3, 2(r30)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    li r3, 48
; P8-NEXT:    # kill: def $f1 killed $f1 def $vsl1
; P8-NEXT:    stxvd2x vs1, r1, r3 # 16-byte Folded Spill
; P8-NEXT:    lhz r3, 0(r30)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    li r3, 80
; P8-NEXT:    # kill: def $f1 killed $f1 def $vsl1
; P8-NEXT:    lxvd2x vs0, r1, r3 # 16-byte Folded Reload
; P8-NEXT:    li r3, 64
; P8-NEXT:    lxvd2x vs2, r1, r3 # 16-byte Folded Reload
; P8-NEXT:    li r3, 48
; P8-NEXT:    xxmrghd vs35, vs0, vs2
; P8-NEXT:    lxvd2x vs0, r1, r3 # 16-byte Folded Reload
; P8-NEXT:    xxmrghd vs34, vs0, vs1
; P8-NEXT:    addi r1, r1, 112
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_extend64_vec4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lhz r4, 6(r3)
; CHECK-NEXT:    lhz r5, 4(r3)
; CHECK-NEXT:    lhz r6, 2(r3)
; CHECK-NEXT:    lhz r3, 0(r3)
; CHECK-NEXT:    mtfprwz f0, r3
; CHECK-NEXT:    mtfprwz f1, r6
; CHECK-NEXT:    xscvhpdp f0, f0
; CHECK-NEXT:    xscvhpdp f1, f1
; CHECK-NEXT:    xxmrghd vs34, vs1, vs0
; CHECK-NEXT:    mtfprwz f0, r5
; CHECK-NEXT:    mtfprwz f1, r4
; CHECK-NEXT:    xscvhpdp f0, f0
; CHECK-NEXT:    xscvhpdp f1, f1
; CHECK-NEXT:    xxmrghd vs35, vs1, vs0
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_extend64_vec4:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r27, -40(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r28, -32(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r29, -24(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -80(r1)
; SOFT-NEXT:    mr r30, r3
; SOFT-NEXT:    lhz r3, 0(r3)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __extendsfdf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r29, r3
; SOFT-NEXT:    lhz r3, 2(r30)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __extendsfdf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r28, r3
; SOFT-NEXT:    lhz r3, 4(r30)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __extendsfdf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r27, r3
; SOFT-NEXT:    lhz r3, 6(r30)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __extendsfdf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r6, r3
; SOFT-NEXT:    mr r3, r29
; SOFT-NEXT:    mr r4, r28
; SOFT-NEXT:    mr r5, r27
; SOFT-NEXT:    addi r1, r1, 80
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; SOFT-NEXT:    ld r29, -24(r1) # 8-byte Folded Reload
; SOFT-NEXT:    ld r28, -32(r1) # 8-byte Folded Reload
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    ld r27, -40(r1) # 8-byte Folded Reload
; SOFT-NEXT:    blr
  %a = load <4 x half>, <4 x half>* %p, align 8
  %b = fpext <4 x half> %a to <4 x double>
  ret <4 x double> %b
}
define void @test_trunc32_vec4(<4 x float> %a, <4 x half>* %p) #0 {
; P8-LABEL: test_trunc32_vec4:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -112(r1)
; P8-NEXT:    xxsldwi vs0, vs34, vs34, 3
; P8-NEXT:    li r3, 48
; P8-NEXT:    std r27, 72(r1) # 8-byte Folded Spill
; P8-NEXT:    std r28, 80(r1) # 8-byte Folded Spill
; P8-NEXT:    std r29, 88(r1) # 8-byte Folded Spill
; P8-NEXT:    std r30, 96(r1) # 8-byte Folded Spill
; P8-NEXT:    mr r30, r5
; P8-NEXT:    xscvspdpn f1, vs0
; P8-NEXT:    stxvd2x vs63, r1, r3 # 16-byte Folded Spill
; P8-NEXT:    vmr v31, v2
; P8-NEXT:    bl __gnu_f2h_ieee
; P8-NEXT:    nop
; P8-NEXT:    xxswapd vs0, vs63
; P8-NEXT:    mr r29, r3
; P8-NEXT:    xscvspdpn f1, vs0
; P8-NEXT:    bl __gnu_f2h_ieee
; P8-NEXT:    nop
; P8-NEXT:    xxsldwi vs0, vs63, vs63, 1
; P8-NEXT:    mr r28, r3
; P8-NEXT:    xscvspdpn f1, vs0
; P8-NEXT:    bl __gnu_f2h_ieee
; P8-NEXT:    nop
; P8-NEXT:    xscvspdpn f1, vs63
; P8-NEXT:    mr r27, r3
; P8-NEXT:    bl __gnu_f2h_ieee
; P8-NEXT:    nop
; P8-NEXT:    sth r3, 6(r30)
; P8-NEXT:    li r3, 48
; P8-NEXT:    sth r27, 4(r30)
; P8-NEXT:    ld r27, 72(r1) # 8-byte Folded Reload
; P8-NEXT:    sth r28, 2(r30)
; P8-NEXT:    sth r29, 0(r30)
; P8-NEXT:    ld r30, 96(r1) # 8-byte Folded Reload
; P8-NEXT:    ld r29, 88(r1) # 8-byte Folded Reload
; P8-NEXT:    lxvd2x vs63, r1, r3 # 16-byte Folded Reload
; P8-NEXT:    ld r28, 80(r1) # 8-byte Folded Reload
; P8-NEXT:    addi r1, r1, 112
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_trunc32_vec4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxsldwi vs0, vs34, vs34, 3
; CHECK-NEXT:    xscvspdpn f0, vs0
; CHECK-NEXT:    xscvdphp f0, f0
; CHECK-NEXT:    mffprwz r3, f0
; CHECK-NEXT:    xxswapd vs0, vs34
; CHECK-NEXT:    xxsldwi vs1, vs34, vs34, 1
; CHECK-NEXT:    xscvspdpn f1, vs1
; CHECK-NEXT:    xscvspdpn f0, vs0
; CHECK-NEXT:    xscvdphp f0, f0
; CHECK-NEXT:    xscvdphp f1, f1
; CHECK-NEXT:    mffprwz r4, f1
; CHECK-NEXT:    xscvspdpn f1, vs34
; CHECK-NEXT:    xscvdphp f1, f1
; CHECK-NEXT:    sth r4, 4(r5)
; CHECK-NEXT:    mffprwz r4, f0
; CHECK-NEXT:    sth r4, 2(r5)
; CHECK-NEXT:    sth r3, 0(r5)
; CHECK-NEXT:    mffprwz r6, f1
; CHECK-NEXT:    sth r6, 6(r5)
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_trunc32_vec4:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r26, -48(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r27, -40(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r28, -32(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r29, -24(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -80(r1)
; SOFT-NEXT:    mr r27, r3
; SOFT-NEXT:    clrldi r3, r6, 32
; SOFT-NEXT:    mr r30, r7
; SOFT-NEXT:    mr r29, r5
; SOFT-NEXT:    mr r28, r4
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r26, r3
; SOFT-NEXT:    clrldi r3, r29, 32
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r29, r3
; SOFT-NEXT:    clrldi r3, r28, 32
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r28, r3
; SOFT-NEXT:    clrldi r3, r27, 32
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    clrldi r3, r3, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r27, r3
; SOFT-NEXT:    clrldi r3, r28, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r28, r3
; SOFT-NEXT:    clrldi r3, r29, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r29, r3
; SOFT-NEXT:    clrldi r3, r26, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 6(r30)
; SOFT-NEXT:    mr r3, r29
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 4(r30)
; SOFT-NEXT:    mr r3, r28
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 2(r30)
; SOFT-NEXT:    mr r3, r27
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 0(r30)
; SOFT-NEXT:    addi r1, r1, 80
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; SOFT-NEXT:    ld r29, -24(r1) # 8-byte Folded Reload
; SOFT-NEXT:    ld r28, -32(r1) # 8-byte Folded Reload
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    ld r27, -40(r1) # 8-byte Folded Reload
; SOFT-NEXT:    ld r26, -48(r1) # 8-byte Folded Reload
; SOFT-NEXT:    blr
  %v = fptrunc <4 x float> %a to <4 x half>
  store <4 x half> %v, <4 x half>* %p
  ret void
}
define void @test_trunc64_vec4(<4 x double> %a, <4 x half>* %p) #0 {
; P8-LABEL: test_trunc64_vec4:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -128(r1)
; P8-NEXT:    li r3, 48
; P8-NEXT:    xxswapd vs1, vs34
; P8-NEXT:    std r27, 88(r1) # 8-byte Folded Spill
; P8-NEXT:    std r28, 96(r1) # 8-byte Folded Spill
; P8-NEXT:    std r29, 104(r1) # 8-byte Folded Spill
; P8-NEXT:    std r30, 112(r1) # 8-byte Folded Spill
; P8-NEXT:    mr r30, r7
; P8-NEXT:    # kill: def $f1 killed $f1 killed $vsl1
; P8-NEXT:    stxvd2x vs62, r1, r3 # 16-byte Folded Spill
; P8-NEXT:    li r3, 64
; P8-NEXT:    vmr v30, v2
; P8-NEXT:    stxvd2x vs63, r1, r3 # 16-byte Folded Spill
; P8-NEXT:    vmr v31, v3
; P8-NEXT:    bl __truncdfhf2
; P8-NEXT:    nop
; P8-NEXT:    xxswapd vs1, vs63
; P8-NEXT:    mr r29, r3
; P8-NEXT:    # kill: def $f1 killed $f1 killed $vsl1
; P8-NEXT:    bl __truncdfhf2
; P8-NEXT:    nop
; P8-NEXT:    xxlor f1, vs62, vs62
; P8-NEXT:    mr r28, r3
; P8-NEXT:    bl __truncdfhf2
; P8-NEXT:    nop
; P8-NEXT:    xxlor f1, vs63, vs63
; P8-NEXT:    mr r27, r3
; P8-NEXT:    bl __truncdfhf2
; P8-NEXT:    nop
; P8-NEXT:    sth r3, 6(r30)
; P8-NEXT:    li r3, 64
; P8-NEXT:    sth r27, 2(r30)
; P8-NEXT:    ld r27, 88(r1) # 8-byte Folded Reload
; P8-NEXT:    sth r28, 4(r30)
; P8-NEXT:    sth r29, 0(r30)
; P8-NEXT:    ld r30, 112(r1) # 8-byte Folded Reload
; P8-NEXT:    ld r29, 104(r1) # 8-byte Folded Reload
; P8-NEXT:    lxvd2x vs63, r1, r3 # 16-byte Folded Reload
; P8-NEXT:    li r3, 48
; P8-NEXT:    ld r28, 96(r1) # 8-byte Folded Reload
; P8-NEXT:    lxvd2x vs62, r1, r3 # 16-byte Folded Reload
; P8-NEXT:    addi r1, r1, 128
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_trunc64_vec4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xxswapd vs0, vs34
; CHECK-NEXT:    xscvdphp f0, f0
; CHECK-NEXT:    mffprwz r3, f0
; CHECK-NEXT:    xxswapd vs0, vs35
; CHECK-NEXT:    xscvdphp f0, f0
; CHECK-NEXT:    xscvdphp f1, vs34
; CHECK-NEXT:    mffprwz r4, f1
; CHECK-NEXT:    xscvdphp f1, vs35
; CHECK-NEXT:    sth r4, 2(r7)
; CHECK-NEXT:    mffprwz r4, f0
; CHECK-NEXT:    sth r4, 4(r7)
; CHECK-NEXT:    sth r3, 0(r7)
; CHECK-NEXT:    mffprwz r5, f1
; CHECK-NEXT:    sth r5, 6(r7)
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_trunc64_vec4:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r26, -48(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r27, -40(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r28, -32(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r29, -24(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -80(r1)
; SOFT-NEXT:    mr r27, r3
; SOFT-NEXT:    mr r3, r6
; SOFT-NEXT:    mr r30, r7
; SOFT-NEXT:    mr r29, r5
; SOFT-NEXT:    mr r28, r4
; SOFT-NEXT:    bl __truncdfhf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r26, r3
; SOFT-NEXT:    mr r3, r29
; SOFT-NEXT:    bl __truncdfhf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r29, r3
; SOFT-NEXT:    mr r3, r28
; SOFT-NEXT:    bl __truncdfhf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r28, r3
; SOFT-NEXT:    mr r3, r27
; SOFT-NEXT:    bl __truncdfhf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    clrldi r3, r3, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r27, r3
; SOFT-NEXT:    clrldi r3, r28, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r28, r3
; SOFT-NEXT:    clrldi r3, r29, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r29, r3
; SOFT-NEXT:    clrldi r3, r26, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 6(r30)
; SOFT-NEXT:    mr r3, r29
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 4(r30)
; SOFT-NEXT:    mr r3, r28
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 2(r30)
; SOFT-NEXT:    mr r3, r27
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    sth r3, 0(r30)
; SOFT-NEXT:    addi r1, r1, 80
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; SOFT-NEXT:    ld r29, -24(r1) # 8-byte Folded Reload
; SOFT-NEXT:    ld r28, -32(r1) # 8-byte Folded Reload
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    ld r27, -40(r1) # 8-byte Folded Reload
; SOFT-NEXT:    ld r26, -48(r1) # 8-byte Folded Reload
; SOFT-NEXT:    blr
  %v = fptrunc <4 x double> %a to <4 x half>
  store <4 x half> %v, <4 x half>* %p
  ret void
}
define float @test_sitofp_fadd_i32(i32 %a, half* %b) #0 {
; P8-LABEL: test_sitofp_fadd_i32:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r30, -24(r1) # 8-byte Folded Spill
; P8-NEXT:    stfd f31, -8(r1) # 8-byte Folded Spill
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -64(r1)
; P8-NEXT:    mr r30, r3
; P8-NEXT:    lhz r3, 0(r4)
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    mtfprwa f0, r30
; P8-NEXT:    fmr f31, f1
; P8-NEXT:    xscvsxdsp f1, f0
; P8-NEXT:    bl __gnu_f2h_ieee
; P8-NEXT:    nop
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    xsaddsp f1, f31, f1
; P8-NEXT:    addi r1, r1, 64
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    lfd f31, -8(r1) # 8-byte Folded Reload
; P8-NEXT:    ld r30, -24(r1) # 8-byte Folded Reload
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: test_sitofp_fadd_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    mtfprwa f1, r3
; CHECK-NEXT:    xscvsxdsp f1, f1
; CHECK-NEXT:    lhz r4, 0(r4)
; CHECK-NEXT:    mtfprwz f0, r4
; CHECK-NEXT:    xscvhpdp f0, f0
; CHECK-NEXT:    xscvdphp f1, f1
; CHECK-NEXT:    mffprwz r3, f1
; CHECK-NEXT:    mtfprwz f1, r3
; CHECK-NEXT:    xscvhpdp f1, f1
; CHECK-NEXT:    xsaddsp f1, f0, f1
; CHECK-NEXT:    blr
;
; SOFT-LABEL: test_sitofp_fadd_i32:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r29, -24(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -64(r1)
; SOFT-NEXT:    mr r30, r3
; SOFT-NEXT:    lhz r3, 0(r4)
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r29, r3
; SOFT-NEXT:    extsw r3, r30
; SOFT-NEXT:    bl __floatsisf
; SOFT-NEXT:    nop
; SOFT-NEXT:    clrldi r3, r3, 32
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    clrldi r3, r3, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    mr r4, r3
; SOFT-NEXT:    mr r3, r29
; SOFT-NEXT:    bl __addsf3
; SOFT-NEXT:    nop
; SOFT-NEXT:    addi r1, r1, 64
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; SOFT-NEXT:    ld r29, -24(r1) # 8-byte Folded Reload
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
  %tmp0 = load half, half* %b
  %tmp1 = sitofp i32 %a to half
  %tmp2 = fadd half %tmp0, %tmp1
  %tmp3 = fpext half %tmp2 to float
  ret float %tmp3
}
define half @PR40273(half) #0 {
; P8-LABEL: PR40273:
; P8:       # %bb.0:
; P8-NEXT:    mflr r0
; P8-NEXT:    std r0, 16(r1)
; P8-NEXT:    stdu r1, -32(r1)
; P8-NEXT:    bl __gnu_f2h_ieee
; P8-NEXT:    nop
; P8-NEXT:    bl __gnu_h2f_ieee
; P8-NEXT:    nop
; P8-NEXT:    xxlxor f0, f0, f0
; P8-NEXT:    fcmpu cr0, f1, f0
; P8-NEXT:    beq cr0, .LBB20_2
; P8-NEXT:  # %bb.1:
; P8-NEXT:    addis r3, r2, .LCPI20_0@toc@ha
; P8-NEXT:    lfs f0, .LCPI20_0@toc@l(r3)
; P8-NEXT:  .LBB20_2:
; P8-NEXT:    fmr f1, f0
; P8-NEXT:    addi r1, r1, 32
; P8-NEXT:    ld r0, 16(r1)
; P8-NEXT:    mtlr r0
; P8-NEXT:    blr
;
; CHECK-LABEL: PR40273:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xscvdphp f0, f1
; CHECK-NEXT:    xxlxor f1, f1, f1
; CHECK-NEXT:    mffprwz r3, f0
; CHECK-NEXT:    mtfprwz f0, r3
; CHECK-NEXT:    xscvhpdp f0, f0
; CHECK-NEXT:    fcmpu cr0, f0, f1
; CHECK-NEXT:    beqlr cr0
; CHECK-NEXT:  # %bb.1:
; CHECK-NEXT:    addis r3, r2, .LCPI20_0@toc@ha
; CHECK-NEXT:    lfs f1, .LCPI20_0@toc@l(r3)
; CHECK-NEXT:    blr
;
; SOFT-LABEL: PR40273:
; SOFT:       # %bb.0:
; SOFT-NEXT:    mflr r0
; SOFT-NEXT:    std r0, 16(r1)
; SOFT-NEXT:    stdu r1, -32(r1)
; SOFT-NEXT:    clrldi r3, r3, 48
; SOFT-NEXT:    bl __gnu_h2f_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    li r4, 0
; SOFT-NEXT:    bl __nesf2
; SOFT-NEXT:    nop
; SOFT-NEXT:    cmplwi r3, 0
; SOFT-NEXT:    lis r3, 16256
; SOFT-NEXT:    iseleq r3, 0, r3
; SOFT-NEXT:    bl __gnu_f2h_ieee
; SOFT-NEXT:    nop
; SOFT-NEXT:    addi r1, r1, 32
; SOFT-NEXT:    ld r0, 16(r1)
; SOFT-NEXT:    mtlr r0
; SOFT-NEXT:    blr
  %2 = fcmp une half %0, 0xH0000
  %3 = uitofp i1 %2 to half
  ret half %3
}
attributes #0 = { nounwind }