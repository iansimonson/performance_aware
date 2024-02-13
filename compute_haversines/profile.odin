package compute_haversines

import "base:runtime"
import "core:time"
import "core:simd/x86"
import "core:fmt"

rdtsc :: x86._rdtsc

BEGIN_PROFILE :: proc(loc := #caller_location) {
    profiles = make(map[runtime.Source_Code_Location]Profile_Anchor)
    profile_begin_loc = loc
    profile_begin_time = time.now()
    profile_begin_ticks = rdtsc()
    current_parent = loc
    profiles[loc] = {name= "TOTAL"}
}

END_PROFILE_AND_PRINT :: proc() {
    end_tick := rdtsc()
    total_ticks := end_tick - profile_begin_ticks
    total_time := time.since(profile_begin_time)
    total_secs := time.duration_seconds(total_time)
    // this is just so we can put totals at the end
    delete_key(&profiles, profile_begin_loc)

    tps_ghz := (f64(total_ticks) / total_secs) / 1_000_000_000

    fmt.println()
    fmt.println("Performance info:")
    fmt.printf("Ticks / second (GHz): %.3v\n", tps_ghz)
    for _, tb in profiles {
        exclusive_ticks := tb.elapsed - tb.elapsed_children
        if exclusive_ticks == tb.elapsed {
            fmt.printf("%s[%d] (Time): %v (%.3v%%)\n", tb.name, tb.hit_count, exclusive_ticks, 100 * f64(exclusive_ticks) / f64(total_ticks))
        } else {
            fmt.printf("%s[%d]: %v (%.3v%%, %.3v%% w/ Children)\n", tb.name, tb.hit_count, exclusive_ticks, 100 * f64(exclusive_ticks) / f64(total_ticks), 100 * f64(tb.elapsed) / f64(total_ticks))
        }
        if tb.processed_byte_count > 0 {
            fmt.printf("%s[%d] (Data): %.3v gb/s\n", tb.name, tb.hit_count, f64(tb.processed_byte_count) / (f64(tb.elapsed) / tps_ghz))
        }

    }
    fmt.printf("Total Ticks: %v\n", total_ticks)
    fmt.printf("Total Time: %v\n", total_time)
}

TimedBlock :: struct {
    start, end: u64,
    byte_count: int,
    loc: runtime.Source_Code_Location,
    prev_parent: runtime.Source_Code_Location,
}

Profile_Anchor :: struct {
    name: string,
    elapsed, elapsed_children: u64,
    hit_count: int,
    processed_byte_count: int,
}

@(deferred_out = END_TIME_SECTION)
TIME_FUNCTION :: proc(byte_count := 0, loc := #caller_location) -> TimedBlock {
    return BEGIN_TIME_SECTION(loc.procedure, byte_count, loc)
}

@(deferred_out = END_TIME_SECTION)
TIME_SECTION :: proc(name: string, byte_count := 0, loc := #caller_location) -> TimedBlock {
    return BEGIN_TIME_SECTION(name, byte_count, loc)
}

BEGIN_TIME_SECTION :: proc(name: string, byte_count := 0, loc := #caller_location) -> TimedBlock {
    prev_parent := current_parent
    current_parent = loc
    if loc not_in profiles do profiles[loc] = {name = name}
    return {start = rdtsc(), byte_count = byte_count, loc = loc, prev_parent = prev_parent}
}

END_TIME_SECTION :: proc(tb: TimedBlock) {
    tb := tb
    tb.end = rdtsc()
    record := &profiles[tb.loc]
    record.elapsed += tb.end - tb.start
    record.hit_count += 1
    record.processed_byte_count += tb.byte_count

    if current_parent != tb.prev_parent {
        parent_record := &profiles[tb.prev_parent]
        parent_record.elapsed_children += tb.end - tb.start
    }

    current_parent = tb.prev_parent
}

profiles: map[runtime.Source_Code_Location]Profile_Anchor
profile_begin_loc: runtime.Source_Code_Location
profile_begin_time: time.Time
profile_begin_ticks: u64
current_parent: runtime.Source_Code_Location