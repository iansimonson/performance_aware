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
PROCESS_QUERY_INFORMATION : windows.DWORD : 0x0400
PROCESS_VM_READ : windows.DWORD : 0x0010

@(default_calling_convention = "system")
foreign _ {
    OpenProcess :: proc(dwDesiredAccess: windows.DWORD, bInheritHandle: windows.BOOL, dwProcessId: windows.DWORD) -> windows.HANDLE ---
}

global_process_handle: windows.HANDLE