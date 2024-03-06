global mov_all_bytes_asm
global nop_all_bytes_asm
global cmp_all_bytes_asm
global dec_all_bytes_asm

section .text


mov_all_bytes_asm:
    xor eax, eax
.loop:
    mov [rsi + rax], al
    inc rax
    cmp rax, rdi
    jb .loop
    ret

nop_all_bytes_asm:
    xor eax, eax
.loop:
    nop dword [rax]
    inc rax
    cmp rax, rdi
    jb .loop
    ret

cmp_all_bytes_asm:
    xor eax, eax
.loop:
    inc rax
    cmp rax, rdi
    jb .loop
    ret

dec_all_bytes_asm:
.loop:
    dec rdi
    jnz .loop
    ret
