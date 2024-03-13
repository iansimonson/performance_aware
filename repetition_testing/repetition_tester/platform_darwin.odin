package repetition_tester

import "core:sys/darwin"

_platform_init :: proc() {
}

_platform_uninit :: proc() {
}

_platform_alloc :: proc(size: int) -> []byte {
    ptr := darwin.syscall_mmap(nil, u64(size), darwin.PROT_READ | darwin.PROT_WRITE, darwin.MAP_ANONYMOUS | darwin.MAP_PRIVATE, -1, 0)
    assert(ptr != nil, "Error mmaping memory")
    return (cast([^]byte) ptr)[:size]
}

_platform_free :: proc(buf: []byte) {
    err_int := darwin.syscall_munmap(raw_data(buf), u64(len(buf)))
    assert(err_int == 0)
}

_page_fault_count :: proc() -> int {
    usage: darwin.RUsage
    err_int := darwin.syscall_getrusage(0, &usage)
    assert(err_int == 0)
    return usage.minflt_word + usage.majflt_word
}
