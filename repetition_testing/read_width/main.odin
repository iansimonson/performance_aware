package read_width

import "core:os"
import "core:path/filepath"
import "core:fmt"
import "core:strconv"
import "core:slice"

import rep "../repetition_tester"

/*
I am running on a ryzen 7 5800x
so instead of 4 like Casey I am doing
4 since I have 3 read ports but also
only AV not AVX512
*/

when ODIN_OS == .Windows {
tests := [?]Test_Function{
    {"read_4", read_bytes_4},
    {"read_8", read_bytes_8},
    {"read_16", read_bytes_16},
    {"read_32", read_bytes_32},
    {"read_all_bytes_32x6", read_all_bytes_32x6},
}
} else when ODIN_OS == .Linux {
tests := [?]Test_Function{
    //{"read_4", read_bytes_4},
    //{"read_8", read_bytes_8},
    {"read_16", read_bytes_16},
    {"read_32", read_bytes_32},
    //{"read_64", read_bytes_64},
}
} else when ODIN_OS == .Darwin {
tests := [?]Test_Function{
    {"read_4", read_bytes_4},
    {"read_8", read_bytes_8},
    {"read_16", read_bytes_16},
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
    for &v, i in params.buffer {
        v = u8(i)
    }
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
