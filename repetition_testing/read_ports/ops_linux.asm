global read_x1
global read_x2
global read_x3
global read_x4
global read_x5

section .text

read_x1:
    align 64
.loop:
    mov rax, [rsi]
    sub rdi, 1
    jnle .loop
    ret

read_x2:
    align 64
.loop:
    mov rax, [rsi]
    mov rax, [rsi]
    sub rdi, 2
    jnle .loop
    ret

read_x3:
    align 64
.loop:
    mov rax, [rsi]
    mov rax, [rsi]
    mov rax, [rsi]
    sub rdi, 3
    jnle .loop
    ret

read_x4:
    align 64
.loop:
    mov rax, [rsi]
    mov rax, [rsi]
    mov rax, [rsi]
    mov rax, [rsi]
    sub rdi, 4
    jnle .loop
    ret

read_x5:
    align 64
.loop:
    mov rax, [rsi]
    mov rax, [rsi]
    mov rax, [rsi]
    mov rax, [rsi]
    mov rax, [rsi]
    sub rdi, 5
    jnle .loop
    ret
