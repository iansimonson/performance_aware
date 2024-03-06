global write_x1
global write_x2
global write_x3
global write_x4
global write_x5

section .text

write_x1:
    align 64
    xor eax, eax
.loop:
    mov [rsi + rax], al
    inc rax
    cmp rax, rdi
    jb .loop
    ret

write_x2:
    align 64
    xor eax, eax
.loop:
    mov [rsi + rax], al
    mov [rsi + rax + 1], al
    add rax, 2
    cmp rax, rdi
    jb .loop
    ret

write_x3:
    align 64
    xor eax, eax
.loop:
    mov [rsi + rax], al
    mov [rsi + rax + 1], al
    mov [rsi + rax + 2], al
    add rax, 3
    cmp rax, rdi
    jb .loop
    ret

write_x4:
    align 64
    xor eax, eax
.loop:
    mov [rsi + rax], al
    mov [rsi + rax + 1], al
    mov [rsi + rax + 2], al
    mov [rsi + rax + 3], al
    add rax, 4
    cmp rax, rdi
    jb .loop
    ret

write_x5:
    align 64
    xor eax, eax
.loop:
    mov [rsi + rax], al
    mov [rsi + rax + 1], al
    mov [rsi + rax + 2], al
    mov [rsi + rax + 3], al
    mov [rsi + rax + 4], al
    add rax, 5
    cmp rax, rdi
    jb .loop
    ret
