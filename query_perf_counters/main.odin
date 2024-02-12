package query_perf_counters

import "core:sys/windows"

import "core:fmt"

main :: proc() {

    perf: windows.LARGE_INTEGER
    success := windows.QueryPerformanceCounter(&perf)

    freq: windows.LARGE_INTEGER
    freq_suc := windows.QueryPerformanceFrequency(&freq)

    assert(success == windows.TRUE && freq_suc == windows.TRUE)

    fmt.println(perf, freq)
}