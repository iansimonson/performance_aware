Performance Aware Programs
===

Implementations of the homework for the various parts of the performance aware course

Reference impls / homeworks are in the [Computer Enhance Github](https://github.com/cmuratori/computer_enhance)

Written in Odin

Each application can be built using `odin build <dir>` e.g. `odin build ./gen_haversines`

These should all work on any OS other than `query_perf_counters` which specifically uses the windows intrinsics for the purposes of stepping through asm in a debugger (one of the homeworks). But note since the course uses RDTSC I do so here

Each repetition testing binary can be built in a similar way with e.g. `odin build repetition_testing/read_ports`

NOTE: these work on MacOS Apple Sillicon but require a couple patches to the Odin core library for `munmap` and `getrusage` see [3272](https://github.com/odin-lang/Odin/pull/3272) and [3274](https://github.com/odin-lang/Odin/pull/3274) if you want to patch your odin core library yourself

1. `gen_haversines` - generates test code
1. `compute_haversines` - the main code for pt3 that we are profiling and trying to improve
1. `sim8086` - binary decoding of 8086 machine code
1. `verify_binary` - small program to verify that a particular binary is identical to another one
1. `query_perf_counters` - literally just calls `windows.QueryPerformanceCounter` and `windows.QueryPerformanceFrequency` for the purposes of stepping through the asm with a debugger
1. `repetition_testing/*` - different repetition tests all using the same harness
1. `abi_tester` - just does a couple C function calls to verify the ABI / debugging purposes

Since I was starting later and the ASM course was done already, I only went up to decoding Add/Sub, etc. I feel comfortable _enough_ with asm that I'll come back to it later if I feel like it
