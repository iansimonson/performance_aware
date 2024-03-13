.global _read_4
.global _read_8
.global _read_16

.p2align 4

_read_4:
    .balign 64
loop0:
    ldr w2, [x1]
    ldr w2, [x1, #4]
    subs x0, x0, #8
    b.gt loop0
    ret

_read_8:
    .balign 64
loop1:
    ldr x2, [x1]
    ldr x2, [x1, #8]
    subs x0, x0, #16
    b.gt loop1
    ret

_read_16:
    .balign 64
    add x2, x1, #16
loop2:
    ld1 {v0.16b}, [x1]
    ld1 {v1.16b}, [x2]
    subs x0, x0, #32
    b.gt loop2
    ret

