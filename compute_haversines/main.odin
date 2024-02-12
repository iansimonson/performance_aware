package compute_haversines

import "core:os"
import "core:path/filepath"
import "core:strings"
import "core:strconv"
import "core:fmt"
import "core:math"
import "core:slice"

main :: proc() {
    args := os.args[1:]
    if len(args) < 1 {
        usage()
        os.exit(1)
    }

    data_fname := args[0]
    json_data, jd_ok := os.read_entire_file(data_fname)

    if !jd_ok {
        fmt.eprintln("Error reading json file")
        os.exit(1)
    }

    check_data: []f64
    if len(args) == 2 {
        check_fname := args[1]
        check_raw_data, check_ok := os.read_entire_file(check_fname)
        if !check_ok {
            fmt.eprintln("Error reading check file")
            os.exit(1)
        }
        check_data = slice.reinterpret([]f64, check_raw_data)
    }

    pairs, p_ok := parse_pairs(string(json_data))
    if !p_ok {
        fmt.eprintln("Could not parse json data")
        os.exit(1)
    }

    do_check: bool
    if len(check_data) > 0 {
        assert(len(pairs) == len(check_data), "Was passed a check file that has a different number of pairs than the json data")
        do_check = true
    }

    distance_sum: f64
    expected_sum: f64
    num_differences: int

    for i in 0..<len(pairs) {
        p := pairs[i]
        distance := reference_haversine({p.x0, p.y0}, {p.x1, p.y1}, 6372.8)
        distance_sum += distance
        if do_check {
            if check_data[i] == distance {
                num_differences += 1
            }
            expected_sum += distance
        }
    }

    fmt.println("Computed haversines:")
    fmt.println("Input Size:", len(json_data))
    fmt.println("Num Pairs:", len(pairs))
    fmt.println("Avg haversine distance:", distance_sum / f64(len(pairs)))
    fmt.println()
    fmt.println("Validation")
    fmt.println("Reference sum:", expected_sum / f64(len(check_data)))
    fmt.println("Difference:", (distance_sum - expected_sum) / f64(len(check_data)))


}

usage :: proc() {
    bin_name := filepath.base(os.args[0])
    fmt.eprintln("Usage:", bin_name, "<data file> [check file]")
    fmt.eprintln("------------------------------")
    fmt.eprintln()
    fmt.eprintln("Computes haversine distances of point pairs and avg of distances")
    fmt.eprintln("Data File: json file containing all the pairs of points")
    fmt.println("Check File: file containing the per-pair haversine distance to validate")
}

Pair :: struct {
    x0, y0, x1, y1: f64,
}

parse_pairs :: proc(data: string) -> (result: []Pair, ok := true) {
    pairs: [dynamic]Pair
    data := match(data, "{") or_return
    data = match(data, `"pairs":`) or_return
    data = match(data, "[") or_return
    for {
        p: Pair
        if data, arr_end := match(data, "]"); arr_end {
            result = pairs[:]
            ok = true
            return
        }
        data = match(data, "{") or_return
        data = match(data, `"x0":`) or_return
        data = skip_whitespace(data)
        {
            end_of_val := strings.index_rune(data, ',')
            if end_of_val == -1 do return {}, false
            x0_v := strconv.parse_f64(data[:end_of_val]) or_return
            p.x0 = x0_v
            data = data[end_of_val:]
        }
        data = match(data, ",") or_return
        data = match(data, `"y0":`) or_return
        data = skip_whitespace(data)
        {
            end_of_val := strings.index_rune(data, ',')
            if end_of_val == -1 do return {}, false
            y0_v := strconv.parse_f64(data[:end_of_val]) or_return
            p.y0 = y0_v
            data = data[end_of_val:]
        }
        data = match(data, ",") or_return
        data = match(data, `"x1":`) or_return
        data = skip_whitespace(data)
        {
            end_of_val := strings.index_rune(data, ',')
            if end_of_val == -1 do return {}, false
            x1_v := strconv.parse_f64(data[:end_of_val]) or_return
            p.x1 = x1_v
            data = data[end_of_val:]
        }
        data = match(data, ",") or_return
        data = match(data, `"y1":`) or_return
        data = skip_whitespace(data)
        {
            end_of_val := strings.index_rune(data, '\n')
            if end_of_val == -1 do return {}, false
            y1_v := strconv.parse_f64(data[:end_of_val]) or_return
            p.y1 = y1_v
            data = data[end_of_val:]
        }
        data = match(data, "}") or_return
        data, _ = match(data, ",") // json doesn't do trailing commas
        append(&pairs, p)
    }
    data = match(data, "}") or_return
    result = pairs[:]
    ok = true
    return
}

skip_whitespace :: proc(data: string) -> string {
    for ch, i in data {
        if strings.is_space(ch) do continue
        else do return data[i:]
    }
    return data[len(data):]
}

match :: proc(data: string, value: string) -> (string, bool) {
    data := skip_whitespace(data)
    if len(data) <= len(value) || data[:len(value)] != value do return data, false
    else do return data[len(value):], true
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