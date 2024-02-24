package repetition_tester

/*
This is because PSAPI is not in the odin core library
sys/windows (yet?)

We don't bind everything, just enough to count
pagefaults. This is very windows specific though
*/

import "core:sys/windows"

PROCESS_QUERY_INFORMATION : windows.DWORD : 0x0400
PROCESS_VM_READ : windows.DWORD : 0x0010

foreign import psapi "system:psapi.lib"

PROCESS_MEMORY_COUNTERS :: struct {
    cb: windows.DWORD,
    PageFaultCount: windows.DWORD,
    PeakWorkingSetSize: windows.SIZE_T,
    WorkingSetSize: windows.SIZE_T,
    QuotaPeakPagedPoolUsage: windows.SIZE_T,
    QuotaPagedPoolUsage: windows.SIZE_T,
    QuotaPeakNonPagedPoolUsage: windows.SIZE_T,
    QuotaNonPagedPoolUsage: windows.SIZE_T,
    PagefileUsage: windows.SIZE_T,
    PeakPagefileUsage: windows.SIZE_T,
}

@(default_calling_convention = "system")
foreign psapi {
    GetProcessMemoryInfo :: proc(Process: windows.HANDLE, ppsmemCounters: ^PROCESS_MEMORY_COUNTERS, cb: windows.DWORD) -> windows.BOOL ---
}

@(default_calling_convention = "system")
foreign _ {
    OpenProcess :: proc(dwDesiredAccess: windows.DWORD, bInheritHandle: windows.BOOL, dwProcessId: windows.DWORD) -> windows.HANDLE ---
}

global_process_handle: windows.HANDLE