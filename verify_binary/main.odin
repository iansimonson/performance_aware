package verify_binary

import "core:os"
import "core:fmt"
import "core:slice"

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