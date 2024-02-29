package page_faults

import "core:fmt"
import "core:path/filepath"
import "core:os"
import "core:sys/windows"
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

            ptr := windows.VirtualAlloc(
                nil,
                uint(total_mem),
                windows.MEM_RESERVE | windows.MEM_COMMIT,
                windows.PAGE_READWRITE,
            )
            if ptr == nil {
                fmt.eprintln("Error allocating memory")
                break
            }
            start_fault_count := rep.page_fault_count()
            data := cast([^]u8)ptr
            for i in 0 ..< touch_mem {
                data[touch_mem - 1 - i] = u8(i)
            }
            end_fault_count := rep.page_fault_count()
            windows.VirtualFree(ptr, 0, windows.MEM_RELEASE)

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