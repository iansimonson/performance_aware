package sim8086

import "core:fmt"
import "core:os"

main :: proc() {
    bin_name := os.args[0]
    args := os.args[1:]
    if (len(args) < 1) {
        fmt.fprintln(os.stderr, "No binary file supplied")
        os.exit(1)
    }

    filename := args[0]
    if data, rok := os.read_entire_file(filename); !rok {
        fmt.fprintf(os.stderr, "Error reading %s\n", filename)
        os.exit(1)
    } else {
        instrs, ok := parse_instructions(data)
        if !ok {
            fmt.fprintln(os.stderr, "Error parsing file")
            os.exit(1)
        }
        print_instrs(filename, instrs)
    }
}

Instruction_Type :: enum {
    Mov,
}

Options :: bit_set[Option]
Option :: enum {
    D,
    W,
}

Instruction :: struct {
    type: Instruction_Type,
    from, to: u8,
    options: Options,
}

parse_instructions :: proc(data: []u8) -> (instr_slice: []Instruction, ok := true) {
    instrs: [dynamic]Instruction
    defer if !ok {
        delete(instrs)
    }

    for i := 0; i < len(data); {
        if (data[i] >> 2) == 0b100010 {
            instr := Instruction{type = .Mov}

            if i + 1 >= len(data) {
                fmt.fprintln(os.stderr, "not enough data")
                return {}, false
            }
            dst_byte := data[i + 1]

            if (dst_byte >> 6) & 0x03 != 0x03 {
                fmt.fprintln(os.stderr, "mod should specify both are registers!")
                return {}, false
            }  

            if data[i] & 0x01 != 0 {
                instr.options += {.W}
            }
            if data[i] & 0x02 != 0 {
                instr.options += {.D}
            }

            if .D in instr.options {
                instr.to = (dst_byte >> 3) & 0x07
                instr.from = (dst_byte & 0x07)
            } else {
                instr.from = (dst_byte >> 3) & 0x07
                instr.to = (dst_byte & 0x07)
            }

            append(&instrs, instr)
            i += 2
        } else {
            fmt.fprintf(os.stderr, "unknow instruction\n")
            fmt.fprintf(os.stderr, "%#b\n", data[i])
            return {}, false
        }
    }

    instr_slice = instrs[:]
    return
}

print_instrs :: proc(fname: string, instrs: []Instruction) {
    fmt.println("; ========================================================================")
    fmt.println("; LISTING", fname)
    fmt.println("; ========================================================================")
    fmt.println()
    fmt.println("bits 16")
    fmt.println()

    for instr in instrs {
        switch instr.type {
        case .Mov:
            w := int(.W in instr.options)
            fmt.printf("mov %s, %s\n", register_file[instr.to][w], register_file[instr.from][w])
        case:
            fmt.panicf("Unknown instruction: %v", instr)
        }
    }
}

register_file := [?][2]string {
    {"al", "ax"},
    {"cl", "cx"},
    {"dl", "dx"},
    {"bl", "bx"},
    {"ah", "sp"},
    {"ch", "bp"},
    {"dh", "si"},
    {"bh", "di"},
}