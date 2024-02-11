package gen_haversines

import "core:fmt"
import "core:os"
import "core:math/rand"
import "core:path/filepath"
import "core:strconv"
import "core:strings"
import "core:math"
import "core:encoding/json"
import "core:slice"

main :: proc() {

    args := os.args[1:]
    if len(args) != 2 {
        usage()
        os.exit(1)
    }

    seed, seed_ok := strconv.parse_u64(args[0])
    num, num_ok := strconv.parse_int(args[1])
    if !seed_ok || !num_ok {
        usage()
        os.exit(1)
    }


    rng: rand.Rand
    rand.init(&rng, seed)
    pairs, distances, expected_sum := generate_pairs(&rng, num)

    Encode :: struct {
        pairs: []Pair,
    }
    encoded, e_err := json.marshal(Encode{pairs = pairs}, {pretty = true, use_spaces = true, spaces = 4})
    if e_err == nil {
        outname := fmt.tprintf("data_%d.json", num)
        bin_outname := fmt.tprintf("diffs_%d.f64", num)
        success := os.write_entire_file(outname, encoded, false)
        success_2 := os.write_entire_file(bin_outname, slice.reinterpret([]u8, distances), false)
        if success && success_2 {
            fmt.println("Generated haversines to", outname, "and", bin_outname)
            fmt.println("Random Seed:", seed)
            fmt.println("Number of Pairs:", num)
            fmt.println("Expected Sum:", expected_sum / f64(num))
        } else {
            fmt.eprintln("Error writing to files")
        }
    } else {
        fmt.eprintln("Error encoding json", e_err)
    }

}

Pair :: struct {
    x0, y0, x1, y1: f64,
}

generate_pairs :: proc(rng: ^rand.Rand, num: int) -> (pairs: []Pair, distances: []f64, expected_sum: f64) {
    pairs = make([]Pair, num)
    distances = make([]f64, num)
    expected_sum = 0
    for i in 0..<num {
        pair: Pair
        pair.x0 = rand.float64_uniform(-180, 180, rng)
        pair.y0 = rand.float64_uniform(-90, 90, rng)
        pair.x1 = rand.float64_uniform(-180, 180, rng)
        pair.y1 = rand.float64_uniform(-90, 90, rng)

        distance := reference_haversine({pair.x0, pair.y0}, {pair.x1, pair.y1}, 6372.8)

        pairs[i] = pair
        distances[i] = distance
        expected_sum += distance
    }
    return
}

reference_haversine :: proc(p1, p2: [2]f64, radius: f64) -> f64 {
    p1_r := [2]f64{math.to_radians(p1.x), math.to_radians(p1.y)}
    p2_r := [2]f64{math.to_radians(p2.x), math.to_radians(p2.y)}
    diff_pts := (p2_r - p1_r) / 2

    ys_sin := math.sin_f64(diff_pts.y)
    xs_sin := math.sin_f64(diff_pts.x)
    a := ys_sin * ys_sin + math.cos(p1_r.y) * math.cos(p2_r.y) * xs_sin * xs_sin
    a_sqrt := math.sqrt(a)
    c := 2 * math.asin(a_sqrt)

    return radius * c
}


usage :: proc() {
    bin_name := filepath.base(os.args[0])
    fmt.eprintln("Usage:", bin_name, "<seed> <number>")
    fmt.eprintln("------------------------------")
    fmt.eprintln()
    fmt.eprintln("Generates haversines test data")
    fmt.eprintln("Seed is used for the random number generator so values can be regenerated")
    fmt.println("Number is the number of pairs to generate")
}
