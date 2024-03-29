package read_width

import rep "../repetition_tester"

when ODIN_OS == .Windows {
foreign import ops "./ops.asm"
} else when ODIN_OS == .Linux {
foreign import ops "./ops_linux.asm"
} else when ODIN_OS == .Darwin {
foreign import ops "./ops_darwin.asm"
}

foreign ops {

read_4 :: proc "c" (length: int, data: [^]u8) ---
read_8 :: proc "c" (length: int, data: [^]u8) ---
read_16 :: proc "c" (length: int, data: [^]u8) ---

when ODIN_OS == .Windows {
read_32 :: proc "c" (length: int, data: [^]u8) ---
read_all_32x6 :: proc "c" (length: int, data: [^]u8) ---
}

when ODIN_OS == .Linux {
read_32 :: proc "c" (length: int, data: [^]u8) ---
read_64 :: proc "c" (length: int, data: [^]u8) ---
}

}

/*
It's ok to overflow here because we're only reading the first
N bytes anyway. If we were actually reading all the bytes
we would want to not read past the end of the buffer
*/

read_bytes_4 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_4(len(dest), raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

read_bytes_8 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_8(len(dest), raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

read_bytes_16 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_16(len(dest), raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

when ODIN_OS == .Windows || ODIN_OS == .Linux {
read_bytes_32 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_32(len(dest), raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}
}

when ODIN_OS == .Windows {

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
}

when ODIN_OS == .Linux {
    read_bytes_64 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
        for rep.is_testing(tester) {
            dest := params.buffer

            rep.handle_allocation(params^, &dest)
            rep.begin_time(tester)
            read_64(len(dest), raw_data(dest))
            rep.end_time(tester)
            rep.handle_deallocation(params^, &dest)

            rep.count_bytes(tester, len(dest))
        }
    }
}
