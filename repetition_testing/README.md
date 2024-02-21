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