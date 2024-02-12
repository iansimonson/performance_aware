package compute_haversines

import "base:runtime"
import "core:time"
import "core:simd/x86"
import "core:fmt"

rdtsc :: x86._rdtsc

BEGIN_PROFILE :: proc(loc := #caller_location) {
    profiles = make(map[runtime.Source_Code_Location]TimedBlock)
    profile_begin_loc = loc
    profile_begin_time = time.now()
    profiles[loc] = {name= "TOTAL", start = rdtsc()}
}

END_PROFILE_AND_PRINT :: proc() {
    total_profile := profiles[profile_begin_loc]
    total_profile.end = rdtsc()
    total_time := time.since(profile_begin_time)
    total_secs := time.duration_seconds(total_time)
    // this is just so we can put totals at the end
    delete_key(&profiles, profile_begin_loc)

    total_ticks := total_profile.end - total_profile.start
    tps_ghz := (f64(total_ticks) / total_secs) / 1_000_000_000

    fmt.println()
    fmt.println("Performance info:")
    fmt.printf("Ticks / second (GHz): %.3v\n", tps_ghz)
    for _, tb in profiles {
        fmt.printf("%s: %v (%.3v%%)\n", tb.name, tb.end - tb.start, 100 * f64(tb.end - tb.start) / f64(total_ticks))
    }
    fmt.printf("Total Ticks: %v\n", total_ticks)
    fmt.printf("Total Time: %v\n", total_time)
}

TimedBlock :: struct {
    name: string,
    start, end: u64,
    loc: runtime.Source_Code_Location
}

@(deferred_out = END_TIME_SECTION)
TIME_FUNCTION :: proc(loc := #caller_location) -> TimedBlock {
    return TIME_SECTION(loc.procedure, loc)
}

@(deferred_out = END_TIME_SECTION)
TIME_SECTION :: proc(name: string, loc := #caller_location) -> TimedBlock {
    return {name = name, start = rdtsc(), loc = loc}
}

BEGIN_TIME_SECTION :: proc(name: string, loc := #caller_location) -> TimedBlock {
    return {name = name, start = rdtsc(), loc = loc}
}

END_TIME_SECTION :: proc(tb: TimedBlock) {
    tb := tb
    tb.end = rdtsc()
    profiles[tb.loc] = tb
}

profiles: map[runtime.Source_Code_Location]TimedBlock
profile_begin_loc: runtime.Source_Code_Location
profile_begin_time: time.Time