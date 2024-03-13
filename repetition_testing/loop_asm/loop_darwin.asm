.global _mov_all_bytes_asm
.global _nop_all_bytes_asm
.global _cmp_all_bytes_asm
.global _dec_all_bytes_asm

.p2align 4

; x0 - length
; x1 - data
_mov_all_bytes_asm:
    eor x3, x3, x3
loopMov:
    strb w3, [x1, x3]
    add x3, x3, #1
    cmp x3, x0
    b.lt loopMov
    ret


_nop_all_bytes_asm:
    eor x3, x3, x3
loopNop:
    nop
    nop
    add x3, x3, #1
    cmp x3, x0
    b.lt loopNop
    ret

_cmp_all_bytes_asm:
    eor x3, x3, x3
loopCmp:
    add x3, x3, #1
    cmp x3, x0
    b.lt loopCmp
    ret

_dec_all_bytes_asm:
loopDec:
    subs x0, x0, #1
    b.gt loopDec
    ret
