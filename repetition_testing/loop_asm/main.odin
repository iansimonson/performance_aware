package loop_asm

import "core:os"
import "core:path/filepath"
import "core:fmt"
import "core:strconv"

import rep "../repetition_tester"


tests := [?]Test_Function{
    {"WriteToAllBytes", write_to_all_bytes},
    {"WriteToAllBytesBackwards", write_to_all_bytes_backwards},
    {"MOVAllBytes", mov_all_bytes},
    {"NOPAllBytes", nop_all_bytes},
    {"CMPAllBytes", cmp_all_bytes},
    {"DECAllBytes", dec_all_bytes},
}

main :: proc() {

    args := os.args[1:]
    if len(args) < 1 {
        usage()
        os.exit(1)
    }

    pages, ok := strconv.parse_int(args[0])
    if !ok {
        fmt.eprintln("Could not parse pages")
        usage()
        os.exit(1)
    }
    rep.init_harness()

    size := pages * 4096

    params: rep.Read_Params
    params.buffer = make([]u8, size)
    params.expected_bufsize = size
    defer delete(params.buffer)

    testers: [len(tests)][rep.Alloc_Mode]rep.Tester
    for {
        for test_func, i in tests {
            for alloc_mode in rep.Alloc_Mode {
                tester := &testers[i][alloc_mode]
                params.alloc_mode = alloc_mode
                fmt.printf("\n--- %v + %s ---\n", alloc_mode, test_func.name)
                rep.new_test_wave(tester, len(params.buffer))
                test_func.function(tester, &params)
            }
        }
        free_all(context.temp_allocator)
    }
}

Test_Function :: struct {
    name: string,
    function: rep.Test_Proc,
}

usage :: proc() {
    fmt.eprintln("Usage:")
    fmt.eprintln(filepath.base(os.args[0]), "<pages>")
    fmt.eprintln("Repeatedly tests operations on some range of bytes")
    fmt.eprintln("<pages>: number of pages to alloc")
}
