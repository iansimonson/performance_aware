package abi_tester

import "core:fmt"

t :: proc "c" (a, b, c, d, e, f, g, h, i: i64) -> i64 {
    return a + b + c + d + e + f + g + h + i
}

t2 :: proc "c" (a, b, c, d, e, f, g, h, i: i64) {
}

write :: proc(b: []u8) {
    b[0] = 10
    b[10] = 20
    b[1] = 11
    b[30] = 40
    b[50] = 60
}

main :: proc() {
    t(0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09)
    t2(0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09)
    fmt.println(ODIN_OS)

    b := make([]u8, 100)
    write(b)
}
