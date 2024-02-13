Performance Aware Programs
===

Implementations of the homework for the various parts of the performance aware course

Written in Odin

Each application can be built using `odin build <dir>` e.g. `odin build ./gen_haversines`

These should all work on any OS other than `query_perf_counters` which specifically uses the windows intrinsics for the purposes of stepping through asm in a debugger (one of the homeworks). But note since the course uses RDTSC I do so here also so it will only work as-is on x86 systems

1. `gen_haversines` - generates test code
1. `compute_haversines` - the main code for pt3 that we are profiling and trying to improve
1. `sim8086` - binary decoding of 8086 machine code
1. `verify_binary` - small program to verify that a particular binary is identical to another one

Since I was starting later and the ASM course was done already, I only went up to decoding Add/Sub, etc. I feel comfortable _enough_ with asm that I'll come back to it later if I feel like it