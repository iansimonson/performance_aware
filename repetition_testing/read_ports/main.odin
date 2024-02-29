package read_ports

import "core:os"
import "core:path/filepath"
import "core:fmt"
import "core:strconv"

import rep "../repetition_tester"


tests := [?]Test_Function{
    {"Mov", mov_all_bytes},
    {"Mov_x2", mov_all_bytes_x2},
    {"Mov_x3", mov_all_bytes_x3},
    {"Mov_x4", mov_all_bytes_x4},
    {"Mov_x5", mov_all_bytes_x5},
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

    size := pages * 4096

    params: rep.Read_Params
    params.buffer = make([]u8, size)
    params.expected_bufsize = size
    defer delete(params.buffer)

    testers: [len(tests)]rep.Tester
    for {
        for test_func, i in tests {
            tester := &testers[i]
            fmt.printf("\n--- %s ---\n", test_func.name)
            rep.new_test_wave(tester, len(params.buffer))
            test_func.function(tester, &params)
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