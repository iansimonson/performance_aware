Repetition Testing
===

Tests from part 3 of the Performance Aware homeworks

Note: we're going to use Odin's `time.tick_now()` which
effectively does `QueryPerformanceCounter` and then multiplies
by the frequency etc.

I would rather do `rdtsc` but since Casey does
`QueryPerformanceCounter` _and_ keeps the frequency
around for final divisions, might as well just do
so here (even though it would be better/faster
to just grab the counters/ticks _first_ and
do the division at the end).

This is just so it's easier to set up the harness
rather than having to keep a bunch of metadata
around. So values might not be perfectly in-line with
what is seen from Casey's version

NOTE: I don't call anything _test because that's a special
file suffix in odin (though it doesn't apply to directories)

## Linux

These tests now work with linux and windows, however linux
by default will return EACCESS

You can either run under sudo OR tell the kernel to allow
querying the perf counters e.g. 

```bash
# default value seems to be 2
sudo sh -c 'echo 1 > /proc/sys/kernel/perf_event_paranoid'
```

It ALSO required doing totally different asm because linux
has a completely different x64 calling convention (I guess
libc knows how to differentiate this)

I found this helpful even if not official: [Red Team Notes](https://www.ired.team/miscellaneous-reversing-forensics/windows-kernel-internals/linux-x64-calling-convention-stack-frame)

## Results

### Page Faults

On windows page faulting was the same as in Casey's examples, no
read-ahead for 16 then read ahead 16 every 16 until you page-fault
the next level up

On linux, there seems to be no page read-ahead by default
but there is the madvise function.

With `.SEQUENTIAL` and `.WILLNEED` I could not get linux to pagefault-ahead
on my system. However with `.POPULATE_WRITE` we faulted all 4096 pages
immediately so there were no page faults while writing later


### Read/Write Ports

Processor | Read Ports | Write Ports
ryzen 5800x | 3 | 2
i7-1185G7 | 2 | 2
