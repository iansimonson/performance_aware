.global _write_x1
.global _write_x2
.global _write_x3
.global _write_x4
.global _write_x5

.p2align 4

_write_x1:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopX1:
    str x0, [x1]
    subs x2, x2, 1
    b.gt loopX1
    ret

_write_x2:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopX2:
    str x0, [x1]
    str x0, [x1]
    subs x2, x2, 2
    b.gt loopX2
    ret
_write_x3:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopX3:
    str x0, [x1]
    str x0, [x1]
    str x0, [x1]
    subs x2, x2, 3
    b.gt loopX3
    ret
_write_x4:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopX4:
    str x0, [x1]
    str x0, [x1]
    str x0, [x1]
    str x0, [x1]
    subs x2, x2, 4
    b.gt loopX4
    ret
_write_x5:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopX5:
    str x0, [x1]
    str x0, [x1]
    str x0, [x1]
    str x0, [x1]
    str x0, [x1]
    subs x2, x2, 5
    b.gt loopX5
    ret
