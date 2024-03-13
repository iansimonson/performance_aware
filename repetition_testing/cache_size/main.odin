package cache_size

import "core:os"
import "core:path/filepath"
import "core:fmt"
import "core:strconv"
import "core:slice"

import rep "../repetition_tester"

when ODIN_OS == .Windows {
foreign import ops "./ops.asm"
} else when ODIN_OS == .Linux {
foreign import ops "./ops_linux.asm"
} else when ODIN_OS == .Darwin {
foreign import ops "./ops_darwin.asm"
}

foreign ops {

read_all_128 :: proc "c" (length: int, data: [^]u8, mask: uint) ---

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
    for &b, i in params.buffer {
        b = u8(i)
    }
    params.expected_bufsize = size
    defer delete(params.buffer)

    testers: [64]rep.Tester
    for {
        count: int
        mask: uint = 2048 - 1
        for {
            tester := &testers[count]
            mask <<= 1
            mask |= 1
            fmt.printf("\n--- %f kb ---\n", f64(mask + 1) / 1024.0)
            rep.new_test_wave(tester, params.expected_bufsize, 3)

            for rep.is_testing(tester) {
                dest := params.buffer
        
                rep.begin_time(tester)
                read_all_128(len(dest), raw_data(dest), mask)
                rep.end_time(tester)
        
                rep.count_bytes(tester, len(dest))
            }

            if mask == max(uint) do break
            count += 1
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
