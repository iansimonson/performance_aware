package sim8086

import "core:fmt"
import "core:os"

main :: proc() {
    populate_decoder()
    fmt.println("Decoded:", decode_opcode(0b10110001))
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

OPCODE_MASKS := [Opcode][2]u8 {
    .None = 0,
    .Mov_RegMem_To_Reg = {0b1001000, 6},
    .Mov_Im_To_RegMem = {0b11000110, 7},
    .Mov_Im_To_Reg = {0b10110000, 4},
    .Mov_Mem_To_Ax = {0b10100000, 7},
    .Mov_Ax_To_Mem = {0b10100010, 7},
}

OPCODE_DECODER: [1024]Opcode

Opcode :: enum {
    None,
    Mov_RegMem_To_Reg,
    Mov_Im_To_RegMem,
    Mov_Im_To_Reg,
    Mov_Mem_To_Ax,
    Mov_Ax_To_Mem,
}

// combination of rem/mod etc.
Instruction_Type :: enum {
    None,
    Mov_RegMem_RegMem_No_Disp,
    Mov_RegMem_RegMem_8_Disp,
    Mov_RegMem_RegMem_16_Disp,
    Mov_RegMem_RegMem_Direct,
    Mov_Reg_Reg,
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
    data: u16,
}

parse_instructions :: proc(data: []u8) -> (instr_slice: []Instruction, ok := true) {
    instrs: [dynamic]Instruction
    defer if !ok {
        delete(instrs)
    }

    for i := 0; i < len(data); {
        op := decode_opcode(data[i])
        next_instruction := Instruction{}
        #partial switch op {
        case .Mov_RegMem_To_Reg:
            consumed := 2
            if i + 1 >= len(data) {
                fmt.fprintln(os.stderr, "not enough data")
                return {}, false
            }
            dst_byte := data[i + 1]

            mod := (dst_byte >> 6) & 0x03
            if data[i] & 0x01 != 0 {
                next_instruction.options += {.W}
            }
            if data[i] & 0x02 != 0 {
                next_instruction.options += {.D}
            }
            rm := dst_byte & 0b111
            reg := (dst_byte >> 3) & 0b111

            switch mod {
            case 0b00: // 0 displacement with exception
                if rm == 0b110 {
                    if i + 3 >= len(data) {
                        fmt.fprintln(os.stderr, "not enough data")
                        return {}, false
                    }
                    disp := (cast(^u16) &data[i + 2])^
                    next_instruction.data = disp
                    consumed = 4
                    next_instruction.type = .Mov_RegMem_RegMem_Direct
                } else {
                    next_instruction.type = .Mov_RegMem_RegMem_No_Disp
                }
            case 0b01: // 8 bit displacement
                if i + 2 >= len(data) {
                    fmt.fprintln(os.stderr, "not enough data")
                    return {}, false
                }
                disp := data[i + 2]
                next_instruction.data = u16(disp)
                consumed = 3
                next_instruction.type = .Mov_RegMem_RegMem_8_Disp
            case 0b10: // 16 bit displacement
                if i + 3 >= len(data) {
                    fmt.fprintln(os.stderr, "not enough data")
                    return {}, false
                }
                disp := (cast(^u16) &data[i + 2])^
                next_instruction.data = disp
                consumed = 4
                next_instruction.type = .Mov_RegMem_RegMem_16_Disp
            case 0b11: // reg to reg
                next_instruction.type = .Mov_Reg_Reg
            }

            if .D in next_instruction.options {
                next_instruction.to = (dst_byte >> 3) & 0x07
                next_instruction.from = (dst_byte & 0x07)
            } else {
                next_instruction.from = (dst_byte >> 3) & 0x07
                next_instruction.to = (dst_byte & 0x07)
            }

            append(&instrs, next_instruction)
            i += consumed
        case:
            fmt.fprintf(os.stderr, "unknown instruction\n")
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
        case .Mov_Reg_Reg:
            w := int(.W in instr.options)
            fmt.printf("mov %s, %s\n", register_file[instr.to][w], register_file[instr.from][w])
        case .Mov_RegMem_RegMem_No_Disp:
            w := int(.W in instr.options)
            if .D in instr.options {
                fmt.printf("mov %s, [%s]\n", register_file[instr.to][w], rm_file[instr.from])
            } else {
                fmt.printf("mov [%s], %s\n", rm_file[instr.to], register_file[instr.from][w])
            }
        case .Mov_RegMem_RegMem_8_Disp, .Mov_RegMem_RegMem_16_Disp:
            w := int(.W in instr.options)
            if .D in instr.options {
                fmt.printf("mov %s, [%s + %d]\n", register_file[instr.to][w], rm_file[instr.from], instr.data)
            } else {
                fmt.printf("mov [%s + %d], %s\n", rm_file[instr.to], instr.data, register_file[instr.from][w])
            }
        case .Mov_RegMem_RegMem_Direct:
            w := int(.W in instr.options)
            if .D in instr.options {
                fmt.printf("mov %s, [%d]\n", register_file[instr.to][w], instr.data)
            } else {
                fmt.printf("mov [%d], %s\n", instr.data, register_file[instr.from][w])
            }
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

rm_file := [?]string {
    "bx + si",
    "bx + di",
    "bp + si",
    "bp + di",
    "si",
    "di",
    "bp",
    "bx",
}

populate_decoder :: proc() {
    for op, inst in OPCODE_MASKS {
        inst_len := op[1]
        mask := op[0]
        pos := 1
        for i in 0..<inst_len {
            bit := int((mask & (1 << u8(7 - i))) != 0)
            pos *= 2 + bit
        }
        if OPCODE_DECODER[pos] != .None {
            fmt.panicf("Expected empty instruction for %v got: %v", inst, OPCODE_DECODER[pos])
        }
        assert(OPCODE_DECODER[pos] == .None)
        OPCODE_DECODER[pos] = inst
    }
}

decode_opcode :: proc(opcode: byte) -> (result: Opcode) {
    pos := 1
    for i in 0..<8 {
        bit := int((opcode & (1 << u8(7 - i))) != 0)
        pos *= 2 + bit
        result = OPCODE_DECODER[pos]
        if result != .None do break
    }
    return
}