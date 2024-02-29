package read_width

import "core:os"
import "core:path/filepath"
import "core:fmt"
import "core:strconv"

import rep "../repetition_tester"

/*
I am running on a ryzen 7 5800x
so instead of 4x2 like Casey I am doing
4x3 since I have 3 read ports but also
only AVX2 not AVX512
*/

tests := [?]Test_Function{
    {"read_4x3", read_bytes_4x3},
    {"read_8x3", read_bytes_8x3},
    {"read_16x3", read_bytes_16x3},
    {"read_32x3", read_bytes_32x3},
    {"read_all_bytes_32x3", read_all_bytes_32x3},
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
    fmt.eprintln("Repeatedly tests number of write ports")
    fmt.eprintln("<pages>: number of pages to alloc")
}