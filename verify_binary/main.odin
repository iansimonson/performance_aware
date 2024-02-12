package verify_binary

import "core:os"
import "core:fmt"
import "core:slice"

/*
This only exists because I was getting weird results when outputting
text/binary to stdout and redirecting

turned out it was because I was on an old version of powershell
which did utf16le by default. Not only that but updating it to use utf8
_still_ was broken because the redirect `>` was actually just an alias for
redirecting and expanding to utf16le (WTF). Upgrading to powershell 6 (now 7)
defaults to UTF-8 and the redirect works and all is right with the world
*/
main :: proc() {

    args := os.args[1:]
    if len(args) < 2 {
        fmt.fprintln(os.stderr, "requires two files to diff")
        os.exit(1)
    }

    f1, f1ok := os.read_entire_file(args[0])
    f2, f2ok := os.read_entire_file(args[1])

    if !f1ok || !f2ok {
        fmt.fprintln(os.stderr, "Could not open one of the files:", f1ok, f2ok)
        os.exit(1)
    }

    if slice.simple_equal(f1, f2) {
        fmt.println("YAY")
        fmt.println(f1[0], f2[0])
    } else {
        fmt.println("BOO")
        fmt.println(f1)
        fmt.println(f2)
    }

}