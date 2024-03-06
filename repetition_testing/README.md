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
