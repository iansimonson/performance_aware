//+build windows
package odin_psapi

import "core:sys/windows"

PSAPI_VERSION :: #config(PSAPI_VERSION, 2)

when PSAPI_VERSION == 1 {
    foreign import psapi "system:psapi.lib"
} else {
    #assert(PSAPI_VERSION == 2)
    foreign import psapi "system:Kernel32.lib"
}

HANDLE :: windows.HANDLE

BOOL :: windows.BOOL
DWORD :: windows.DWORD
LPDWORD :: windows.LPDWORD
SIZE_T :: windows.SIZE_T

LPWSTR :: windows.LPWSTR
LPCWSTR :: windows.LPCWSTR
LPSTR :: windows.LPSTR
LPCSTR :: windows.LPCSTR

ULONG_PTR :: windows.ULONG_PTR
LPVOID :: windows.LPVOID
PVOID :: windows.PVOID

HMODULE :: windows.HMODULE


PROCESS_QUERY_INFORMATION : DWORD : 0x0400
PROCESS_VM_READ : DWORD : 0x0010

MODULEINFO :: struct {
    lpBaseOfDLL: LPVOID,
    SizeOfImage: DWORD,
    EntryPoint: LPVOID,
}
LPMODULEINFO :: ^MODULEINFO

PSAPI_WORKING_SET_BLOCK :: struct {
    Flags: ULONG_PTR,
}
PPSAPI_WORKING_SET_BLOCK :: ^PSAPI_WORKING_SET_BLOCK

PSAPI_WORKING_SET_INFORMATION :: struct {
    NumberOfEntries: ULONG_PTR,
    // NOTE: there are potentially MORE working set blocks
    // starting directly after this memory
    WorkingSetInfo : [1]PSAPI_WORKING_SET_BLOCK,
}
PPSAPI_WORKING_SET_INFORMATION :: ^PSAPI_WORKING_SET_INFORMATION

PSAPI_WORKING_SET_EX_BLOCK :: struct {
    Flags: ULONG_PTR,
}
PPSAPI_WORKING_SET_EX_BLOCK :: ^PSAPI_WORKING_SET_EX_BLOCK

PSAPI_WORKING_SET_EX_INFORMATION :: struct {
    VirtualAddress: PVOID,
    VirtualAttributes: PSAPI_WORKING_SET_EX_BLOCK,
}
PPSAPI_WORKING_SET_EX_INFORMATION :: ^PSAPI_WORKING_SET_EX_INFORMATION

PSAPI_WS_WATCH_INFORMATION :: struct {
    FaultingPc, FaultingVa: LPVOID,
}
PPSAPI_WS_WATCH_INFORMATION :: ^PSAPI_WS_WATCH_INFORMATION

PSAPI_WS_WATCH_INFORMATION_EX :: struct {
    BasicInfo: PSAPI_WS_WATCH_INFORMATION,
    FaultingThreadId, Flags: ULONG_PTR,
}
PPSAPI_WS_WATCH_INFORMATION_EX :: ^PSAPI_WS_WATCH_INFORMATION_EX


PROCESS_MEMORY_COUNTERS :: struct {
    cb: DWORD,
    PageFaultCount: DWORD,
    PeakWorkingSetSize: SIZE_T,
    WorkingSetSize: SIZE_T,
    QuotaPeakPagedPoolUsage: SIZE_T,
    QuotaPagedPoolUsage: SIZE_T,
    QuotaPeakNonPagedPoolUsage: SIZE_T,
    QuotaNonPagedPoolUsage: SIZE_T,
    PagefileUsage: SIZE_T,
    PeakPagefileUsage: SIZE_T,
}
PPROCESS_MEMORY_COUNTERS :: ^PROCESS_MEMORY_COUNTERS

// For some reason there's (probably legacy)
// mistyped PERFORMACE_INFORMATION that's defined
// in PSAPI.h but I'm not including it here
PERFORMANCE_INFORMATION :: struct {
    cb: DWORD,
    CommitTotal: SIZE_T,
    CommitLimit: SIZE_T,
    CommitPeak: SIZE_T,
    PhysicalTotal: SIZE_T,
    PhysicalAvailable: SIZE_T,
    SystemCache: SIZE_T,
    KernelTotal: SIZE_T,
    KernelPaged: SIZE_T,
    KernelNonpaged: SIZE_T,
    PageSize: SIZE_T,
    HandleCount: DWORD,
    ProcessCount: DWORD,
    ThreadCount: DWORD,
}
PPERFORMANCE_INFORMATION :: ^PERFORMANCE_INFORMATION

ENUM_PAGE_FILE_INFORMATION :: struct {
    cb: DWORD,
    Reserved: DWORD,
    TotalSize: SIZE_T,
    TotalInUse: SIZE_T,
    PeakUsage: SIZE_T,
}
PENUM_PAGE_FILE_INFORMATION :: ^ENUM_PAGE_FILE_INFORMATION

PENUM_PAGE_FILE_CALLBACKW :: #type proc "system" (pContext: LPVOID, pPageFileInfo: PENUM_PAGE_FILE_INFORMATION, lpFilename: LPCWSTR) -> BOOL
PENUM_PAGE_FILE_CALLBACKA :: #type proc "system" (pContext: LPVOID, pPageFileInfo: PENUM_PAGE_FILE_INFORMATION, lpFilename: LPCSTR) -> BOOL

when PSAPI_VERSION > 1 {
@(default_calling_convention = "system", link_prefix="K32")
foreign psapi {
    EnumProcesses :: proc(lpidProcess: ^DWORD, cb: DWORD, cbNeeded: LPDWORD) -> BOOL ---
    EnumProcessModules :: proc(hProcess: HANDLE, lphModule: ^HMODULE, cb: DWORD, lpcbNeeded: LPDWORD) -> BOOL ---
    EnumProcessModulesEx :: proc(hProcess: HANDLE, lphModule: ^HMODULE, cb: DWORD, lpcbNeeded: LPDWORD, dwFilterFlag: DWORD) -> BOOL ---

    GetModuleBaseNameA :: proc(hProcess: HANDLE, hModule: HMODULE, lpBaseName: LPSTR, nSize: DWORD) -> DWORD ---
    GetModuleBaseNameW :: proc(hProcess: HANDLE, hModule: HMODULE, lpBaseName: LPWSTR, nSize: DWORD) -> DWORD ---
    GetModuleFileNameExA :: proc(hProcess: HANDLE, hModule: HMODULE, lpFilename: LPSTR, nSize: DWORD) -> DWORD ---
    GetModuleFileNameExW :: proc(hProcess: HANDLE, hModule: HMODULE, lpFilename: LPWSTR, nSize: DWORD) -> DWORD ---

    GetModuleInformation :: proc(hProcess: HANDLE, hModule: HMODULE, lpmodinfo: LPMODULEINFO, cb: DWORD) -> BOOL ---
    
    EmptyWorkingSet :: proc(hProcess: HANDLE) -> BOOL ---
    QueryWorkingSet :: proc(hProcess: HANDLE, pv: PVOID, cb: DWORD) -> BOOL ---
    QueryWorkingSetEx :: proc(hProcess: HANDLE, pv: PVOID, cb: DWORD) -> BOOL ---
    InitializeProcessForWsWatch :: proc(hProcess: HANDLE) -> BOOL ---

    GetWsChanges :: proc(hProcess: HANDLE, lpWatchInfo: PPSAPI_WS_WATCH_INFORMATION, cb: DWORD) -> BOOL ---
    GetWsChangesEx :: proc(hProcess: HANDLE, lpWatchInfoEx: PPSAPI_WS_WATCH_INFORMATION_EX, cb: DWORD) -> BOOL ---

    GetMappedFileNameW :: proc(hProcess: HANDLE, lpv: LPVOID, lpFilename: LPWSTR, nSize: DWORD) -> DWORD ---
    GetMappedFileNameA :: proc(hProcess: HANDLE, lpv: LPVOID, lpFilename: LPSTR, nSize: DWORD) -> DWORD ---

    EnumDeviceDrivers :: proc(lpImageBase: ^LPVOID, cb: DWORD, lpcbNeeded: LPDWORD) -> BOOL ---
    GetDeviceDriverBaseNameA :: proc(lpImageBase: LPVOID, lpFilename: LPSTR, nSize: DWORD) -> DWORD ---
    GetDeviceDriverBaseNameW :: proc(lpImageBase: LPVOID, lpBaseName: LPWSTR, nSize: DWORD) -> DWORD ---
    GetDeviceDriverFileNameA :: proc(lpImageBase: LPVOID, lpFilename: LPSTR, nSize: DWORD) -> DWORD ---
    GetDeviceDriverFileNameW :: proc(lpImageBase: LPVOID, lpFilename: LPWSTR, nSize: DWORD) -> DWORD ---
      
    GetProcessMemoryInfo :: proc(Process: HANDLE, ppsmemCounters: ^PROCESS_MEMORY_COUNTERS, cb: DWORD) -> BOOL ---

    GetPerformanceInfo :: proc(pPerformanceInformation: PPERFORMANCE_INFORMATION, cb: DWORD) -> BOOL ---

    EnumPageFilesW :: proc(pCallbackRoutine: PENUM_PAGE_FILE_CALLBACKW, pContext: LPVOID) -> BOOL ---
    EnumPageFilesA :: proc(pCallbackRoutine: PENUM_PAGE_FILE_CALLBACKA, pContext: LPVOID) -> BOOL ---

    GetProcessImageFileNameA :: proc(hProcess: HANDLE, lpImageFileName: LPSTR, nSize: DWORD) -> DWORD ---
    GetProcessImageFileNameW :: proc(hProcess: HANDLE, lpImageFileName: LPWSTR, nSize: DWORD) -> DWORD ---
}

} else when PSAPI_VERSION == 1 {

@(default_calling_convention = "system")
foreign psapi {
    EnumProcesses :: proc(lpidProcess: ^DWORD, cb: DWORD, cbNeeded: LPDWORD) -> BOOL ---
    EnumProcessModules :: proc(hProcess: HANDLE, lphModule: ^HMODULE, cb: DWORD, lpcbNeeded: LPDWORD) -> BOOL ---
    EnumProcessModulesEx :: proc(hProcess: HANDLE, lphModule: ^HMODULE, cb: DWORD, lpcbNeeded: LPDWORD, dwFilterFlag: DWORD) -> BOOL ---

    GetModuleBaseNameA :: proc(hProcess: HANDLE, hModule: HMODULE, lpBaseName: LPSTR, nSize: DWORD) -> DWORD ---
    GetModuleBaseNameW :: proc(hProcess: HANDLE, hModule: HMODULE, lpBaseName: LPWSTR, nSize: DWORD) -> DWORD ---
    GetModuleFileNameExA :: proc(hProcess: HANDLE, hModule: HMODULE, lpFilename: LPSTR, nSize: DWORD) -> DWORD ---
    GetModuleFileNameExW :: proc(hProcess: HANDLE, hModule: HMODULE, lpFilename: LPWSTR, nSize: DWORD) -> DWORD ---

    @(link_prefix = "K32")
    GetModuleInformation :: proc(hProcess: HANDLE, hModule: HMODULE, lpmodinfo: LPMODULEINFO, cb: DWORD) -> BOOL ---

    @(link_prefix = "K32")
    EmptyWorkingSet :: proc(hProcess: HANDLE) -> BOOL ---

    QueryWorkingSet :: proc(hProcess: HANDLE, pv: PVOID, cb: DWORD) -> BOOL ---
    QueryWorkingSetEx :: proc(hProcess: HANDLE, pv: PVOID, cb: DWORD) -> BOOL ---

    InitializeProcessForWsWatch :: proc(hProcess: HANDLE) -> BOOL ---

    GetWsChanges :: proc(hProcess: HANDLE, lpWatchInfo: PPSAPI_WS_WATCH_INFORMATION, cb: DWORD) -> BOOL ---
    GetWsChangesEx :: proc(hProcess: HANDLE, lpWatchInfoEx: PPSAPI_WS_WATCH_INFORMATION_EX, cb: DWORD) -> BOOL ---

    GetMappedFileNameW :: proc(hProcess: HANDLE, lpv: LPVOID, lpFilename: LPWSTR, nSize: DWORD) -> DWORD ---
    GetMappedFileNameA :: proc(hProcess: HANDLE, lpv: LPVOID, lpFilename: LPSTR, nSize: DWORD) -> DWORD ---

    EnumDeviceDrivers :: proc(lpImageBase: ^LPVOID, cb: DWORD, lpcbNeeded: LPDWORD) -> BOOL ---
    GetDeviceDriverBaseNameA :: proc(lpImageBase: LPVOID, lpFilename: LPSTR, nSize: DWORD) -> DWORD ---
    GetDeviceDriverBaseNameW :: proc(lpImageBase: LPVOID, lpBaseName: LPWSTR, nSize: DWORD) -> DWORD ---
    GetDeviceDriverFileNameA :: proc(lpImageBase: LPVOID, lpFilename: LPSTR, nSize: DWORD) -> DWORD ---
    GetDeviceDriverFileNameW :: proc(lpImageBase: LPVOID, lpFilename: LPWSTR, nSize: DWORD) -> DWORD ---

    GetProcessMemoryInfo :: proc(Process: HANDLE, ppsmemCounters: ^PROCESS_MEMORY_COUNTERS, cb: DWORD) -> BOOL ---

    GetPerformanceInfo :: proc(pPerformanceInformation: PPERFORMANCE_INFORMATION, cb: DWORD) -> BOOL ---

    EnumPageFilesW :: proc(pCallbackRoutine: PENUM_PAGE_FILE_CALLBACKW, pContext: LPVOID) -> BOOL ---
    EnumPageFilesA :: proc(pCallbackRoutine: PENUM_PAGE_FILE_CALLBACKA, pContext: LPVOID) -> BOOL ---

    GetProcessImageFileNameA :: proc(hProcess: HANDLE, lpImageFileName: LPSTR, nSize: DWORD) -> DWORD ---
    GetProcessImageFileNameW :: proc(hProcess: HANDLE, lpImageFileName: LPWSTR, nSize: DWORD) -> DWORD ---
}

}
