package repetition_tester

import "core:fmt"
import "core:time"
import "core:sys/windows"

Read_Params :: struct {
    buffer: []u8,
    expected_bufsize: int,
    filename: string,
    alloc_mode: Alloc_Mode,
}

Test_Mode :: enum u32 {
    Uninitialized,
    Testing,
    Completed,
    Error,
}

Rep_Value :: enum {
    Test_Count,
    CPU_Timer,
    Mem_Page_Faults,
    Byte_Count,
}

Alloc_Mode :: enum {
    None,
    Malloc,
}

Repetition_Value :: [Rep_Value]int

Test_Results :: struct {
    total, min_r, max_r: Repetition_Value,
}

Test_Proc :: #type proc(tester: ^Tester, params: ^Read_Params)

Tester :: struct {
    target_processed_byte_count: int,
    try_for_time: time.Duration,
    tests_started_at: time.Tick,
    mode: Test_Mode,
    print_new_minimums: bool,
    open_block_count, close_block_count: int,
    accumulated_this_test: Repetition_Value,

    results: Test_Results,
}

init_harness :: proc() {
    global_process_handle = OpenProcess(PROCESS_VM_READ | PROCESS_QUERY_INFORMATION, false, windows.GetCurrentProcessId())
}

error :: proc(tester: ^Tester, message: string) {
    tester.mode = .Error
    fmt.eprintln("ERROR:", message)
}

new_test_wave :: proc(tester: ^Tester, target_processed_byte_count: int, seconds_to_try := 10 * time.Second) {
    if tester.mode == .Uninitialized {
        tester.mode = .Testing
        tester.target_processed_byte_count = target_processed_byte_count
        tester.print_new_minimums = true
        tester.results = {}
        tester.results.min_r[.CPU_Timer] = max(int)
    } else if tester.mode == .Completed {
        tester.mode = .Testing
        if tester.target_processed_byte_count != target_processed_byte_count {
            error(tester, "target_processed_byte_count changed")
        }
    }

    tester.try_for_time = time.Duration(seconds_to_try)
    tester.tests_started_at = time.tick_now()
}

begin_time :: proc(tester: ^Tester) {
    tester.open_block_count += 1
    tester.accumulated_this_test[.CPU_Timer] -= cpu_tick_nsec()
    tester.accumulated_this_test[.Mem_Page_Faults] -= page_fault_count()
}

end_time :: proc(tester: ^Tester) {
    tester.close_block_count += 1
    tester.accumulated_this_test[.CPU_Timer] += cpu_tick_nsec()
    tester.accumulated_this_test[.Mem_Page_Faults] += page_fault_count()
}

count_bytes :: proc(tester: ^Tester, byte_count: int) {
    tester.accumulated_this_test[.Byte_Count] += byte_count
} 

is_testing :: proc(tester: ^Tester) -> bool {
    if tester.mode == .Testing {
        current_time := time.tick_now()
        if tester.open_block_count > 0 {
            if tester.open_block_count != tester.close_block_count {
                error(tester, "Unbalanced begintime/endtime")
            }

            if tester.accumulated_this_test[.Byte_Count] != tester.target_processed_byte_count {
                error(tester, "Processed byte count mismatch")
            }

            results := &tester.results
            elapsed_time := tester.accumulated_this_test[.CPU_Timer]
            results.total[.Test_Count] += 1
            results.total[.CPU_Timer] += elapsed_time
            results.total[.Byte_Count] += tester.accumulated_this_test[.Byte_Count]
            results.total[.Mem_Page_Faults] += tester.accumulated_this_test[.Mem_Page_Faults]
            
            if elapsed_time > results.max_r[.CPU_Timer] {
                results.max_r = tester.accumulated_this_test
            }

            if elapsed_time < results.min_r[.CPU_Timer] {
                results.min_r = tester.accumulated_this_test
                tester.tests_started_at = current_time

                if tester.print_new_minimums {
                    print_value("Min", results.min_r)
                    fmt.printf("                                        \r")
                }
            }

            tester.open_block_count = 0
            tester.close_block_count = 0
            tester.accumulated_this_test = {}
        }

        if time.tick_diff(tester.tests_started_at, current_time) > tester.try_for_time {
            tester.mode = .Completed
            fmt.printf("                                                                                          \r")
            print_results(tester.results)
        }
    }

    return tester.mode == .Testing
}

handle_allocation :: proc(params: Read_Params, buffer: ^[]u8) {
    switch params.alloc_mode {
    case .None:
        /* nothing */
    case .Malloc:
        /*ptr := windows.VirtualAlloc(nil, windows.SIZE_T(params.expected_bufsize), windows.MEM_RESERVE | windows.MEM_COMMIT, windows.PAGE_READWRITE)
        assert(ptr != nil)
        buffer^ = (cast([^]u8) ptr)[:params.expected_bufsize]
        assert(len(buffer) != 0)*/
        buffer^ = make([]u8, params.expected_bufsize)
    case:
        fmt.eprintln("ERROR: unrecognized allocation type")
    }
}

handle_deallocation :: proc(params: Read_Params, buffer: ^[]u8) {
    switch params.alloc_mode {
    case .None:
        /* nothing */
    case .Malloc:
        /*ok := windows.VirtualFree(raw_data(buffer^), 0, windows.MEM_RELEASE)
        assert(ok == true)*/
        delete(buffer^)
    case:
        fmt.eprintln("ERROR: unrecognized allocation type")
    }
}

cpu_tick_nsec :: proc() -> int {
    return int(time.tick_now()._nsec)
}

page_fault_count :: proc() -> int {
    counters: PROCESS_MEMORY_COUNTERS
    GetProcessMemoryInfo(global_process_handle, &counters, size_of(counters))
    return int(counters.PageFaultCount)
}

print_value :: proc(label: string, values: Repetition_Value) {
    test_count := values[.Test_Count]
    divisor: f64 = 1 if test_count == 0 else f64(test_count)

    per_rep: [Rep_Value]f64
    for v, i in values {
        per_rep[i] = f64(v) / divisor
    }
    cpu_time := per_rep[.CPU_Timer]
    seconds := time.duration_seconds(time.Duration(cpu_time))
    fmt.printf("%s: %.0f (%fms)", label, cpu_time, 1000 * seconds)

    byte_count := per_rep[.Byte_Count]
    if byte_count > 0 {
        gigabyte := 1024.0 * 1024.0 * 1024.0
        best_bandwidth := f64(byte_count) / (gigabyte * seconds)
        fmt.printf(" %fgb/s", best_bandwidth)
    }

    page_faults := per_rep[.Mem_Page_Faults]
    if page_faults > 0 {
        fmt.printf(" PF: %0.4f (%0.4fk/fault)", page_faults, (f64(byte_count) / (f64(page_faults) * 1024.0)))
    }
}

print_results :: proc(results: Test_Results) {
    
    print_value("Min", results.min_r)
    fmt.println()
    
    print_value("Max", results.max_r);
    fmt.println()
    
    if(results.total[.Test_Count] > 0)
    {
        print_value("Avg", results.total);
        fmt.println()
    }
}