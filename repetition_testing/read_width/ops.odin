package read_width

import rep "../repetition_tester"

foreign import ops "./ops.asm"

foreign ops {

read_4x3 :: proc "c" (length: int, data: [^]u8) ---
read_8x3 :: proc "c" (length: int, data: [^]u8) ---
read_16x3 :: proc "c" (length: int, data: [^]u8) ---
read_32x3 :: proc "c" (length: int, data: [^]u8) ---

}

/*
Note I'm not doing the full bytes just in case of overflow
when increasing e.g. 96 bytes at a time

But should be fine since we're reading like 1gb the
small amount of byte offset is inconsequential
*/

read_bytes_4x3 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_4x3(len(dest) - 12, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

read_bytes_8x3 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_8x3(len(dest) - 24, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

read_bytes_16x3 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_16x3(len(dest) - 48, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

read_bytes_32x3 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_32x3(len(dest) - 96, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}
