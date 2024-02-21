package repetition_tester

import "core:fmt"
import "core:time"

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
    test_count: int, 
    total_time, min_time, max_time: time.Duration,
}

Test_Proc :: #type proc(tester: ^Tester, params: ^Read_Params)

Tester :: struct {
    target_processed_byte_count: int,
    try_for_time: time.Duration,
    tests_started_at: time.Tick,
    mode: Test_Mode,
    print_new_minimums: bool,
    open_block_count, close_block_count: int,
    time_accumulated_this_test: time.Tick,
    bytes_accumulated_this_test: int,

    results: Test_Results,
}

print_time :: proc(label: string, cpu_time: time.Duration, byte_count: int) {
    seconds := time.duration_seconds(cpu_time)
    fmt.printf("%s: %.0f (%fms)", label, cpu_time, 1000 * seconds)

    if byte_count > 0 {
        gigabyte := 1024.0 * 1024.0 * 1024.0
        best_bandwidth := f64(byte_count) / (gigabyte * seconds)
        fmt.printf(" %fgb/s", best_bandwidth)
    }
}

print_results :: proc(results: Test_Results, byte_count: int) {
    
    print_time("Min", results.min_time, byte_count)
    fmt.println()
    
    print_time("Max", results.max_time, byte_count);
    fmt.println()
    
    if(results.test_count > 0)
    {
        print_time("Avg", results.total_time / time.Duration(results.test_count), byte_count);
        fmt.println()
    }
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
        tester.results.min_time = time.Duration(max(int))
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
    tester.time_accumulated_this_test._nsec -= time.tick_now()._nsec
}

end_time :: proc(tester: ^Tester) {
    tester.close_block_count += 1
    tester.time_accumulated_this_test._nsec += time.tick_now()._nsec
}

count_bytes :: proc(tester: ^Tester, byte_count: int) {
    tester.bytes_accumulated_this_test += byte_count
} 

is_testing :: proc(tester: ^Tester) -> bool {
    if tester.mode == .Testing {
        current_time := time.tick_now()
        if tester.open_block_count > 0 {
            if tester.open_block_count != tester.close_block_count {
                error(tester, "Unbalanced begintime/endtime")
            }

            if tester.bytes_accumulated_this_test != tester.target_processed_byte_count {
                error(tester, "Processed byte count mismatch")
            }

            results := &tester.results
            elapsed_time := time.Duration(tester.time_accumulated_this_test._nsec)
            results.test_count += 1
            results.total_time += elapsed_time
            results.max_time = max(results.max_time, elapsed_time)
            
            if elapsed_time < results.min_time {
                results.min_time = min(results.min_time, elapsed_time)
                tester.tests_started_at = current_time

                if tester.print_new_minimums {
                    print_time("Min", results.min_time, tester.bytes_accumulated_this_test)
                    fmt.printf("                    \r")
                }
            }

            tester.open_block_count = 0
            tester.close_block_count = 0
            tester.time_accumulated_this_test = {}
            tester.bytes_accumulated_this_test = 0
        }

        if time.tick_diff(tester.tests_started_at, current_time) > tester.try_for_time {
            tester.mode = .Completed
            fmt.printf("                                                                                          \r")
            print_results(tester.results, tester.target_processed_byte_count)
        }
    }

    return tester.mode == .Testing
}

handle_allocation :: proc(params: Read_Params, buffer: ^[]u8) {
    switch params.alloc_mode {
    case .None:
        /* nothing */
    case .Malloc:
        buffer^ = make([]u8, params.expected_bufsize)
        assert(len(buffer) != 0)
    case:
        fmt.eprintln("ERROR: unrecognized allocation type")
    }
}

handle_deallocation :: proc(params: Read_Params, buffer: ^[]u8) {
    switch params.alloc_mode {
    case .None:
        /* nothing */
    case .Malloc:
        delete(buffer^)
    case:
        fmt.eprintln("ERROR: unrecognized allocation type")
    }
}