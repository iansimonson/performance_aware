package repetition_tester

/*
This is because PSAPI is not in the odin core library
sys/windows (yet?)

We don't bind everything, just enough to count
pagefaults. This is very windows specific though
*/

import "core:sys/windows"
import psapi "odin-psapi"

PROCESS_MEMORY_COUNTERS :: psapi.PROCESS_MEMORY_COUNTERS
GetProcessMemoryInfo :: psapi.GetProcessMemoryInfo

// need to add these flags to current
// process with OpenProcess
PROCESS_QUERY_INFORMATION: windows.DWORD : 0x0400
PROCESS_VM_READ: windows.DWORD : 0x0010

@(default_calling_convention = "system")
foreign _ {
    OpenProcess :: proc(dwDesiredAccess: windows.DWORD, bInheritHandle: windows.BOOL, dwProcessId: windows.DWORD) -> windows.HANDLE ---
}

_platform_init :: proc() {
    global_process_handle = OpenProcess(
        PROCESS_VM_READ | PROCESS_QUERY_INFORMATION,
        false,
        windows.GetCurrentProcessId(),
    )
}

_platform_uninit :: proc() {
}

_platform_alloc :: proc(size: int) -> []byte {
    ptr := windows.VirtualAlloc(
        nil,
        windows.SIZE_T(size),
        windows.MEM_RESERVE | windows.MEM_COMMIT,
        windows.PAGE_READWRITE,
    )
    assert(ptr != nil)
    return (cast([^]u8)ptr)[:size]
}

_platform_free :: proc(buf: []byte) {
    ok := windows.VirtualFree(raw_data(buf), 0, windows.MEM_RELEASE)
    assert(ok == true)
}

_page_fault_count :: proc() -> int {
    counters: PROCESS_MEMORY_COUNTERS
    GetProcessMemoryInfo(global_process_handle, &counters, size_of(counters))
    return int(counters.PageFaultCount)
}

global_process_handle: windows.HANDLE
