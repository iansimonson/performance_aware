package repetition_tester

import "core:sys/darwin"

_platform_init :: proc() {
}

_platform_uninit :: proc() {
}

_platform_alloc :: proc(size: int) -> []byte {
    ptr := darwin.syscall_mmap(nil, u64(size), darwin.PROT_READ | darwin.PROT_WRITE, darwin.MAP_ANONYMOUS | darwin.MAP_PRIVATE, -1, 0)
    ptr_no := int(uintptr(ptr))
    assert(ptr_no != -1, "Error mmaping memory")
    return (cast([^]byte) ptr)[:size]
}

_platform_free :: proc(buf: []byte) {
    ptr := raw_data(buf)
    l := u64(len(buf))
    err_int := darwin.syscall_munmap(ptr, l)
    assert(err_int == 0)
}

_page_fault_count :: proc() -> int {
    usage: darwin.RUsage
    err_int := darwin.syscall_getrusage(0, &usage)
    assert(err_int == 0)
    return int(usage.ru_minflt + usage.ru_majflt)
}
