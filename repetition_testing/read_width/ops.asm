global read_4x3
global read_8x3
global read_16x3
global read_32x3
global read_all_32x6

section .text

read_4x3:
    align 64
    xor rax, rax
.loop:
    mov r8d, [rdx]
    mov r8d, [rdx + 4]
    mov r8d, [rdx + 8]
    add rax, 12
    cmp rax, rcx
    jb .loop
    ret

read_8x3:
    align 64
    xor rax, rax
.loop:
    mov r8, [rdx]
    mov r8, [rdx + 8]
    mov r8, [rdx + 16]
    add rax, 24
    cmp rax, rcx
    jb .loop
    ret

read_16x3:
    align 64
    xor rax, rax
.loop:
    movdqu xmm0, [rdx]
    movdqu xmm1, [rdx + 16]
    movdqu xmm2, [rdx + 32]
    add rax, 48
    cmp rax, rcx
    jb .loop
    ret

read_32x3:
    align 64
    xor rax, rax
.loop:
    vmovdqu ymm0, [rdx]
    vmovdqu ymm1, [rdx + 32]
    vmovdqu ymm2, [rdx + 64]
    add rax, 96
    cmp rax, rcx
    jb .loop
    ret

read_all_32x6:
    align 64
    xor rax, rax
.loop:
    vmovdqu ymm0, [rdx + rax]
    vmovdqu ymm1, [rdx + rax + 32]
    vmovdqu ymm2, [rdx + rax + 64]
    vmovdqu ymm3, [rdx + rax + 96]
    ; vmovdqu ymm4, [rdx + rax + 128]
    ; vmovdqu ymm5, [rdx + rax + 160]
    add rax, 128
    cmp rax, rcx
    jb .loop
    ret
