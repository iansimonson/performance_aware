package repetition_tester

import "core:mem"
import "core:sys/linux"

_platform_init :: proc() {
}

_platform_uninit :: proc() {
}

_platform_alloc :: proc(size: int) -> []byte {
    ptr, err := linux.mmap({}, uint(size), {.READ, .WRITE}, {.PRIVATE, .ANONYMOUS})
    assert(err == nil && ptr != nil)
    return (cast([^]byte)ptr)[:size]
}

_platform_free :: proc(buf: []byte) {
    err := linux.munmap(raw_data(buf), len(buf))
    assert(err == nil)
}

/*
**NOTE**: We are using getrusage here not
reading perf_events becuase for some reason
they did not include any kernel events at all
even without exclude_kernel set

that resulted in extra page counts being negative
which was clearly incorrect
*/
_page_fault_count :: proc() -> int {
    usage: linux.RUsage
    err := linux.getrusage({}, &usage)
    assert(err == {})
    return usage.minflt_word + usage.majflt_word
}
