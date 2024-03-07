package page_faults

import "core:fmt"
import "core:path/filepath"
import "core:os"
import "core:sys/windows"
import "core:sys/linux"
import "core:strconv"

import rep "../repetition_tester"

main :: proc() {
    if len(os.args) >= 2 {
        num_pages, ok := strconv.parse_int(os.args[1])
        if !ok {
            fmt.eprintln("Could not parse page number")
            usage()
            os.exit(1)
        }

        rep.init_harness()

        for touch_count in 0 ..< num_pages {
            total_mem := num_pages * 4096
            touch_mem := touch_count * 4096

            data_slice := rep._platform_alloc(total_mem)
            data := raw_data(data_slice)
            start_fault_count := rep.page_fault_count()
            when ODIN_OS == .Linux {
                ret := linux.madvise(raw_data(data_slice), len(data_slice), .POPULATE_WRITE)
                if ret != {} {
                    fmt.panicf("Got %v\n", ret)
                }
            }
            for i in 0 ..< touch_mem {
                data[i] = u8(i)
            }
            end_fault_count := rep.page_fault_count()
            rep._platform_free(data_slice)

            fault_count := end_fault_count - start_fault_count
            fmt.printf("%v, %v, %v, %v\n", num_pages, touch_count, fault_count, fault_count - touch_count)

        }
    } else {
        usage()
        os.exit(1)
    }
}

usage :: proc() {
    bin_name := filepath.base(os.args[0])
    fmt.eprintln("Usage:", bin_name, "<num pages>")
    fmt.eprintln("------------------------------")
    fmt.eprintln()
    fmt.eprintln("Runs page fault tests on windows only")
    fmt.eprintln("<num pages>: number of pages (4k) to allocate")
}
