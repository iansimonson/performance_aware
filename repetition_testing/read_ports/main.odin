package read_ports

import "core:os"
import "core:path/filepath"
import "core:fmt"
import "core:strconv"

import rep "../repetition_tester"


when ODIN_OS != .Darwin {
tests := [?]Test_Function{
    {"read_x1", read_bytes_x1},
    {"read_x2", read_bytes_x2},
    {"read_x3", read_bytes_x3},
    {"read_x4", read_bytes_x4},
    {"read_x5", read_bytes_x5},
}
} else {
tests := [?]Test_Function{
    {"read_x1", read_bytes_x1},
    {"read_x2", read_bytes_x2},
    {"read_x3", read_bytes_x3},
    {"read_x4", read_bytes_x4},
    {"read_x5", read_bytes_x5},
    // these are ARM specific tests
    {"read_v1", read_bytes_x1},
    {"read_v2", read_bytes_x2},
    {"read_v3", read_bytes_x3},
    {"read_v4", read_bytes_x4},
}
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
    fmt.eprintln("Repeatedly tests number of write ports")
    fmt.eprintln("<pages>: number of pages to alloc")
}
