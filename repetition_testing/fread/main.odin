package fread

import "core:fmt"
import "core:os"
import "core:c/libc"

import rep "../repetition_tester"

main :: proc() {

    if len(os.args) >= 2 {
        fname := os.args[1]
        finfo, finfo_err := os.stat(fname)
        
        if finfo_err != 0 {
            fmt.eprintln("Error stating file")
            os.exit(1)
        }

        params: rep.Read_Params
        params.buffer = make([]u8, finfo.size)
        params.filename = fname

        if len(params.buffer) == 0 {
            fmt.eprintln("Could not allocate buffer. exiting")
            os.exit(1)
        } else {
            fmt.println("Testing with file", fname, "of size", finfo.size)
        }

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
}

tests := [?]Test_Function{
    {"ReadViaReadFile", read_via_readfile},
    {"ReadViaFRead", read_via_fread},
}

Test_Function :: struct {
    name: string,
    function: rep.Test_Proc,
}

read_via_fread : rep.Test_Proc : proc(t: ^rep.Tester, params: ^rep.Read_Params) {
    fname := fmt.ctprintf(params.filename)
    for rep.is_testing(t) {
        f := libc.fopen(fname, "rb")
        if f == nil {
            rep.error(t, "via_fread: fopen failed")
        } else {
            defer libc.fclose(f)
            rep.begin_time(t)
            result := libc.fread(raw_data(params.buffer), len(params.buffer), 1, f)
            rep.end_time(t)

            if result != 1 {
                rep.error(t, "via_fread: fread failed")
            } else {
                rep.count_bytes(t, len(params.buffer))
            }
        }
    }
}

read_via_readfile : rep.Test_Proc : proc(t: ^rep.Tester, params: ^rep.Read_Params) {
    for rep.is_testing(t) {
        f, f_err := os.open(params.filename)
        if f_err != 0 {
            rep.error(t, "via_readfile: open failed")
        } else {
            defer os.close(f)

            size_remaining := len(params.buffer)
            buf_start := 0
            for size_remaining > 0 {
                rep.begin_time(t)
                // uses ReadFile on Windows
                read_bytes, err := os.read(f, params.buffer[buf_start:])
                rep.end_time(t)

                if err == 0 && read_bytes > 0 {
                    rep.count_bytes(t, read_bytes)
                } else {
                    rep.error(t, "via_readfile: os.read failed")
                    break
                }

                size_remaining -= read_bytes
                buf_start += read_bytes
            }
        }
    }
}

// Not doing _read b/c it's basically just what is in ReadFile
// and is windows specific. Whereas the above _should_ work
// on both windows and linux