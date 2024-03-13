package read_ports

import rep "../repetition_tester"

when ODIN_OS == .Windows {
    foreign import ops "./ops.asm"
} else when ODIN_OS == .Linux {
    foreign import ops "./ops_linux.asm"
} else when ODIN_OS == .Darwin {
    foreign import ops "./ops_darwin.asm"
}

foreign ops {

read_x1 :: proc "c" (length: int, data: [^]u8) ---
read_x2 :: proc "c" (length: int, data: [^]u8) ---
read_x3 :: proc "c" (length: int, data: [^]u8) ---
read_x4 :: proc "c" (length: int, data: [^]u8) ---
read_x5 :: proc "c" (length: int, data: [^]u8) ---

when ODIN_OS == .Darwin {
read_v1 :: proc "c" (length: int, data: [^]u8) ---
read_v2 :: proc "c" (length: int, data: [^]u8) ---
read_v3 :: proc "c" (length: int, data: [^]u8) ---
read_v4 :: proc "c" (length: int, data: [^]u8) ---
}

}

read_bytes_x1 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_x1(len(dest) - 1, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

read_bytes_x2 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_x2(len(dest) - 2, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

read_bytes_x3 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_x3(len(dest) - 3, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

read_bytes_x4 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_x4(len(dest) - 4, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

read_bytes_x5 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_x5(len(dest) - 5, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

when ODIN_OS == .Darwin {
read_bytes_v1 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_v1(len(dest) - 1, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

read_bytes_v2 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_v2(len(dest) - 2, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

read_bytes_v3 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_v3(len(dest) - 3, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

read_bytes_v4 :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        read_v4(len(dest) - 4, raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}
}
