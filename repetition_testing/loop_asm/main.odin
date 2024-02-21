package loop_asm

import "core:os"
import "core:path/filepath"
import "core:fmt"

import rep "../repetition_tester"


tests := [?]Test_Function{
    {"WriteToAllBytes", write_to_all_bytes},
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

    finfo := os.stat(args[0])

    params: rep.Read_Params
    params.buffer = make([]u8, finfo.size)
    defer delete(params.buffer)
    params.filename = args[0]

    testers: [len(tests)]rep.Rep_Tester

    for {
        for test, i in tests {
            tester := &testers[i]
            fmt.printf("\n--- %s ---\n", test.name)
            rep.new_test_wave(tester, len(params.buffer), rep.get_cpu_timer_freq())
            test.function(tester, &params)
        }
    }
}

Test_Function :: struct {
    name: string,
    function: rep.Test_Proc,
}

usage :: proc() {
    fmt.eprintln("Usage:")
    fmt.eprintln(filepath.base(os.args[0]), "<filename>")
    fmt.eprintln("Repeatedly tests something on test data provided via <filename>")
}