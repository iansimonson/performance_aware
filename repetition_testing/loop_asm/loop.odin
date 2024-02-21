package loop_asm

foreign import loop "./loop.asm"

foreign loop {

mov_all_bytes_asm :: proc "c" (length: int, data: [^]u8) ---
nop_all_bytes_asm :: proc "c" (length: int) ---
cmp_all_bytes_asm :: proc "c" (length: int) ---
dec_all_bytes_asm :: proc "c" (length: int) ---

}

write_to_all_bytes :: proc(tester: ^Rep_Tester, params: ^Read_Params) {
    for is_testing(tester) {
        dest := params.buffer

        begin_time(tester)
        for i in 0..<len(dest) {
            dest[i] = 15
        }
        end_time(tester)

        count_bytes(tester, len(dest))
    }
}

mov_all_bytes :: proc(tester: ^Rep_Tester, params: ^Read_Params) {
    for is_testing(tester) {
        dest := params.buffer

        begin_time(tester)
        mov_all_bytes_asm(len(dest), raw_data(dest))
        end_time(tester)

        count_bytes(tester, len(dest))
    }
}

nop_all_bytes :: proc(tester: ^Rep_Tester, params: ^Read_Params) {
    for is_testing(tester) {
        dest := params.buffer

        begin_time(tester)
        nop_all_bytes_asm(len(dest))
        end_time(tester)

        count_bytes(tester, len(dest))

    }
}

cmp_all_bytes :: proc(tester: ^Rep_Tester, params: ^Read_Params) {
    for is_testing(tester) {
        dest := params.buffer

        begin_time(tester)
        cmp_all_bytes_asm(len(dest))
        end_time(tester)

        count_bytes(tester, len(dest))

    }
}

dec_all_bytes :: proc(tester: ^Rep_Tester, params: ^Read_Params) {
    for is_testing(tester) {
        dest := params.buffer

        begin_time(tester)
        dec_all_bytes_asm(len(dest))
        end_time(tester)

        count_bytes(tester, len(dest))

    }
}