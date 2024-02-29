global read_all_128

section .text

; rcx - first argument
; rdx - second argument
; r8 - third argument
read_all_128:
    align 64
    xor rax, rax
    xor r9, r9
.loop:
    vmovdqu ymm0, [rdx + r9]
    vmovdqu ymm1, [rdx + r9 + 32]
    vmovdqu ymm2, [rdx + r9 + 64]
    vmovdqu ymm3, [rdx + r9 + 96]
    add rax, 128
    add r9, 128
    and r9, r8
    cmp rax, rcx
    jb .loop
    ret
