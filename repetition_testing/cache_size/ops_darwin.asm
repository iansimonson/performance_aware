.global _read_all_128

.p2align 4

; x0 - length
; x1 - data ([^]u8)
; x2 - mask
_read_all_128:
    .balign 64
    eor x3, x3, x3
loop0:
    mov x4, x1
    add x4, x4, x3
    ld1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x4], #64
    ld1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x4], #64
    add x3, x3, #128
    and x3, x3, x2
    subs x0, x0, #128
    b.gt loop0
    ret

