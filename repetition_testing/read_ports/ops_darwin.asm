.global _read_x1
.global _read_x2
.global _read_x3
.global _read_x4
.global _read_x5

.global _read_v1
.global _read_v2
.global _read_v3
.global _read_v4

.p2align 4

_read_x1:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopX1:
    ldr x0, [x1]
    subs x2, x2, 1
    b.gt loopX1
    ret

_read_x2:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopX2:
    ldr x0, [x1]
    ldr x0, [x1]
    subs x2, x2, 2
    b.gt loopX2
    ret

_read_x3:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopX3:
    ldr x0, [x1]
    ldr x0, [x1]
    ldr x0, [x1]
    subs x2, x2, 3
    b.gt loopX3
    ret

_read_x4:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopX4:
    ldr x0, [x1]
    ldr x0, [x1]
    ldr x0, [x1]
    ldr x0, [x1]
    subs x2, x2, 4
    b.gt loopX4
    ret

_read_x5:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopX5:
    ldr x0, [x1]
    ldr x0, [x1]
    ldr x0, [x1]
    ldr x0, [x1]
    ldr x0, [x1]
    subs x2, x2, 5
    b.gt loopX5
    ret

_read_v1:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopV1:
    ld1 {v0.16B}, [x1]
    subs x2, x2, 1
    b.gt loopV1
    ret

_read_v2:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopV2:
    ld1 {v0.16b, v1.16b}, [x1]
    subs x2, x2, 2
    b.gt loopV2
    ret

_read_v3:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopV3:
    ld1 {v0.16b, v1.16b, v2.16b}, [x1]
    subs x2, x2, 3
    b.gt loopV3
    ret

_read_v4:
    .balign 64
    mov x2, x0
    eor x0, x0, x0
loopV4:
    ld1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x1]
    subs x2, x2, 4
    b.gt loopV4
    ret
