package sim8086

import "core:fmt"
import "core:os"

main :: proc() {
    populate_decoder()
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

INSTRUCTION_MASKS := [Instruction_Type][2]u8 {
    .None = 0,
    .Mov_RegMem_To_Reg = {0b1001000, 6},
    .Mov_Im_To_RegMem = {0b11000110, 7},
    .Mov_Im_To_Reg = {0b10110000, 4},
    .Mov_Mem_To_Ax = {0b10100000, 7},
    .Mov_Ax_To_Mem = {0b10100010, 7},
}

INSTRUCTION_DECODER: [1024]Instruction_Type

Instruction_Type :: enum {
    None,
    Mov_RegMem_To_Reg,
    Mov_Im_To_RegMem,
    Mov_Im_To_Reg,
    Mov_Mem_To_Ax,
    Mov_Ax_To_Mem,
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
        instr := decode_instruction(data[i])
        next_instruction := Instruction{type = instr}
        #partial switch instr {
        case .Mov_RegMem_To_Reg:
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
                next_instruction.options += {.W}
            }
            if data[i] & 0x02 != 0 {
                next_instruction.options += {.D}
            }

            if .D in next_instruction.options {
                next_instruction.to = (dst_byte >> 3) & 0x07
                next_instruction.from = (dst_byte & 0x07)
            } else {
                next_instruction.from = (dst_byte >> 3) & 0x07
                next_instruction.to = (dst_byte & 0x07)
            }

            append(&instrs, next_instruction)
            i += 2
        case:
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
        #partial switch instr.type {
        case .Mov_RegMem_To_Reg:
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

populate_decoder :: proc() {
    for op, inst in INSTRUCTION_MASKS {
        inst_len := op[1]
        mask := op[0]
        pos := 1
        for i in 0..<inst_len {
            bit := int((mask & (1 << u8(7 - i))) != 0)
            pos *= 2 + bit
        }
        if INSTRUCTION_DECODER[pos] != .None {
            fmt.panicf("Expected empty instruction for %v got: %v", inst, INSTRUCTION_DECODER[pos])
        }
        assert(INSTRUCTION_DECODER[pos] == .None)
        INSTRUCTION_DECODER[pos] = inst
    }
}

decode_instruction :: proc(opcode: byte) -> (result: Instruction_Type) {
    pos := 1
    for i in 0..<8 {
        bit := int((opcode & (1 << u8(7 - i))) != 0)
        pos *= 2 + bit
        result = INSTRUCTION_DECODER[pos]
        if result != .None do break
    }
    return
}