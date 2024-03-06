package repetition_tester

import "core:mem"
import "core:sys/linux"

global_process_handle: linux.Fd

_platform_init :: proc() {
    attr := linux.Perf_Event_Attr {
        type = .SOFTWARE,
        size = size_of(linux.Perf_Event_Attr),
        config = {sw = linux.Perf_Software_Id.PAGE_FAULTS},
    }
    fd, err := linux.perf_event_open(&attr, 0, -1, -1, {})
    assert(err == linux.Errno{})
    assert(fd != linux.Fd(-1))
    global_process_handle = fd
}

_platform_uninit :: proc() {
    linux.close(global_process_handle)
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

_page_fault_count :: proc() -> int {
    count: int
    read, err := linux.read(global_process_handle, mem.ptr_to_bytes(&count))
    assert(read == size_of(count))
    assert(err == nil)
    return count
}
