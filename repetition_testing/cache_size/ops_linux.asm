global read_all_128

section .text

; rdi - first argument (length)
; rsi - second argument (data)
; rdx - third argument (mask)
; rcx - just a register
read_all_128:
    align 64
    xor rax, rax
    xor rcx, rcx
.loop:
    vmovdqu ymm0, [rsi + rcx]
    vmovdqu ymm1, [rsi + rcx + 32]
    vmovdqu ymm2, [rsi + rcx + 64]
    vmovdqu ymm3, [rsi + rcx + 96]
    add rax, 128
    add rdx, 128
    and rdx, rdx
    cmp rax, rdi
    jb .loop
    ret
