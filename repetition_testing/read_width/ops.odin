package read_width

import rep "../repetition_tester"

foreign import ops "./ops.asm"

foreign ops {

read_4x3 :: proc "c" (length: int, data: [^]u8) ---
read_8x3 :: proc "c" (length: int, data: [^]u8) ---
read_16x3 :: proc "c" (length: int, data: [^]u8) ---
read_32x3 :: proc "c" (length: int, data: [^]u8) ---
read_all_32x6 :: proc "c" (length: int, data: [^]u8) ---

}

/*
It's ok to overflow here because we're only reading the first
N bytes anyway. If we were actually reading all the bytes
we would want to not read past the end of the buffer
*/

read_bytes_4x3 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_4x3(len(dest), raw_data(dest))
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
        read_8x3(len(dest), raw_data(dest))
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
        read_16x3(len(dest), raw_data(dest))
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
        read_32x3(len(dest), raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

// NOTE: these two are not the same as above as it
// adds a dependency on rax and (potentially) cache
// issues (it probably won't here b/c I haven't written
// to the buffer previously so it's just reading the
// zero page). I was just curious
read_all_bytes_32x6 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_all_32x6(len(dest) - 192, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}