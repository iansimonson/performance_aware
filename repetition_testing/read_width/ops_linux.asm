global read_4x3
global read_8x3
global read_16x3
global read_32x3
global read_64x2
global read_all_32x6

; Heyyy on my linux laptop even though it's
; an older 11th gen intel we apparently have
; avx-512
; but we only have 2 read ports so
; we'll just do 2 here (even though it might be faster
; to do 4 given the dependency chain)
; so ignore the x3 it's actually x2

section .text

read_4x3:
    align 64
    xor rax, rax
.loop:
    mov r8d, [rsi]
    mov r8d, [rsi + 4]
    sub rdi, 8
    jnle .loop
    ret

read_8x3:
    align 64
    xor rax, rax
.loop:
    mov r8, [rsi]
    mov r8, [rsi + 8]
    sub rdi, 16
    jnle .loop
    ret

read_16x3:
    ;align 64
    xor rax, rax
.loop:
    movdqu xmm0, [rsi]
    movdqu xmm1, [rsi + 16]
    sub rdi, 32
    jnle .loop
    ret

read_32x3:
    ;align 64
    xor rax, rax
.loop:
    vmovdqu8 ymm0, [rsi]
    ;vmovdqu8 ymm1, [rsi + 32]
    sub rdi, 32
    jnle .loop
    ret

read_64x2:
    align 64
    xor rax, rax
.loop:
    vmovdqu8 zmm0, [rsi]
    vmovdqu8 zmm1, [rsi + 64]
    sub rdi, 128
    jnle .loop
    ret

read_all_32x6:
    align 64
    xor rax, rax
.loop:
    vmovdqu ymm0, [rsi + rax]
    vmovdqu ymm1, [rsi + rax + 32]
    vmovdqu ymm2, [rsi + rax + 64]
    vmovdqu ymm3, [rsi + rax + 96]
    ; vmovdqu ymm4, [rsi + rax + 128]
    ; vmovdqu ymm5, [rsi + rax + 160]
    add rax, 128
    cmp rax, rdi
    jb .loop
    ret

