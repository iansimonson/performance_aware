package loop_asm

import rep "../repetition_tester"

when ODIN_OS == .Windows {
foreign import loop "./loop.asm"
} else when ODIN_OS == .Linux {
foreign import loop "./loop_linux.asm"
} else when ODIN_OS == .Darwin {
foreign import loop "./loop_darwin.asm"
}

foreign loop {

mov_all_bytes_asm :: proc "c" (length: int, data: [^]u8) ---
nop_all_bytes_asm :: proc "c" (length: int) ---
cmp_all_bytes_asm :: proc "c" (length: int) ---
dec_all_bytes_asm :: proc "c" (length: int) ---

}

write_to_all_bytes :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer
        rep.handle_allocation(params^, &dest)

        rep.begin_time(tester)
        for i in 0..<len(dest) {
            dest[i] = 15
        }
        rep.end_time(tester)

        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

write_to_all_bytes_backwards :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer
        rep.handle_allocation(params^, &dest)

        rep.begin_time(tester)
        for i := len(dest) - 1; i >= 0; i -= 1 {
            dest[i] = 15
        }
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

mov_all_bytes :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        mov_all_bytes_asm(len(dest), raw_data(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))
    }
}

nop_all_bytes :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        nop_all_bytes_asm(len(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))

    }
}

cmp_all_bytes :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        cmp_all_bytes_asm(len(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))

    }
}

dec_all_bytes :: proc(tester: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(tester) {
        dest := params.buffer

        rep.handle_allocation(params^, &dest)
        rep.begin_time(tester)
        dec_all_bytes_asm(len(dest))
        rep.end_time(tester)
        rep.handle_deallocation(params^, &dest)

        rep.count_bytes(tester, len(dest))

    }
}
