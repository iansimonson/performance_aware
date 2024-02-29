global mov_x1
global mov_x2
global mov_x3
global mov_x4
global mov_x5

section .text

mov_x1:
    xor eax, eax
.loop:
    mov [rdx + rax], al
    inc rax
    cmp rax, rcx
    jb .loop
    ret

mov_x2:
    xor eax, eax
.loop:
    mov [rdx + rax], al
    mov [rdx + rax + 1], al
    add rax, 2
    cmp rax, rcx
    jb .loop
    ret

mov_x3:
    xor eax, eax
.loop:
    mov [rdx + rax], al
    mov [rdx + rax + 1], al
    mov [rdx + rax + 2], al
    add rax, 3
    cmp rax, rcx
    jb .loop
    ret

mov_x4:
    xor eax, eax
.loop:
    mov [rdx + rax], al
    mov [rdx + rax + 1], al
    mov [rdx + rax + 2], al
    mov [rdx + rax + 3], al
    add rax, 4
    cmp rax, rcx
    jb .loop
    ret

mov_x5:
    xor eax, eax
.loop:
    mov [rdx + rax], al
    mov [rdx + rax + 1], al
    mov [rdx + rax + 2], al
    mov [rdx + rax + 3], al
    mov [rdx + rax + 4], al
    add rax, 5
    cmp rax, rcx
    jb .loop
    ret