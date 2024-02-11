package sim8086

import "core:fmt"
import "core:os"

main :: proc() {
    populate_decoder()
    bin_name := os.args[0]
    args := os.args[1:]
    if (len(args) < 1) {
        fmt.eprintln("No binary file supplied")
        os.exit(1)
    }

    filename := args[0]
    if data, rok := os.read_entire_file(filename); !rok {
        fmt.eprintf("Error reading %s\n", filename)
        os.exit(1)
    } else {
        instrs, ok := parse_instructions(data)
        if !ok {
            fmt.eprintln("Error parsing file")
            os.exit(1)
        }
        print_instrs(filename, instrs)
    }
}

OPCODE_MASKS := [Opcode][2]u8 {
    .None = {},
    .Mov_RegMem_To_RegMem = {0b1000_1000, 6},
    .Mov_Im_To_RegMem = {0b1100_0110, 7},
    .Mov_Im_To_Reg = {0b1011_0000, 4},
    .Mov_Mem_To_Ax = {0b1010_0000, 7},
    .Mov_Ax_To_Mem = {0b1010_0010, 7},
    .Add_RegMem_With_Reg_To_RegMem = {0b0000_0000, 6},
    .Add_Im_To_RegMem = {0b1000_0000, 6},
    .Add_Im_To_Ax = {0b0000_0100, 7},
    .Sub_RegMem_With_Reg_To_RegMem = {0b0010_1000, 6},
    .Sub_Im_To_RegMem = {}, // because same opcode as add
    .Sub_Im_To_Ax = {0b0010_1100, 7},
    .Cmp_RegMem_With_Reg_To_RegMem = {0b0011_1000, 6},
    .Cmp_Im_To_RegMem = {}, // because same as add
    .Cmp_Im_To_Ax = {0b0011_1100, 7},
}

OPCODE_DECODER: [1024]Opcode

Opcode :: enum {
    None,
    Mov_RegMem_To_RegMem,
    Mov_Im_To_RegMem,
    Mov_Im_To_Reg,
    Mov_Mem_To_Ax,
    Mov_Ax_To_Mem,

    Add_RegMem_With_Reg_To_RegMem,
    Add_Im_To_RegMem,
    Add_Im_To_Ax,

    Sub_RegMem_With_Reg_To_RegMem,
    Sub_Im_To_RegMem,
    Sub_Im_To_Ax,

    Cmp_RegMem_With_Reg_To_RegMem,
    Cmp_Im_To_RegMem,
    Cmp_Im_To_Ax,
}

Options :: bit_set[Option]
Option :: enum {
    D,
    W,
    No_Disp,
    _8_Disp,
    _16_Disp,
    Direct,
    Reg_To_Reg,
}

Instruction :: struct {
    type: Opcode,
    reg: u8,
    rm: u8,
    options: Options,
    data, data2: u16,
}

has_at_least :: proc(data: []u8, size: int) -> bool {
    if size > len(data) {
        fmt.eprintln("Not enough data")
        return false
    }
    return true
}

parse_instructions :: proc(data: []u8) -> (instr_slice: []Instruction, ok := false) {
    instrs: [dynamic]Instruction
    defer if !ok {
        delete(instrs)
    }

    for i := 0; i < len(data); {
        op := decode_opcode(data[i])
        next_instruction := Instruction{type = op}
        consumed := 0
        #partial switch op {
        case .Mov_RegMem_To_RegMem, .Add_RegMem_With_Reg_To_RegMem, .Sub_RegMem_With_Reg_To_RegMem, .Cmp_RegMem_With_Reg_To_RegMem:
            consumed = 2
            has_at_least(data, i + consumed) or_return

            w := data[i] & 0b1
            d := data[i] & 0b10
            if w != 0 {
                next_instruction.options += {.W}
            }
            if d != 0 {
                next_instruction.options += {.D}
            }

            dst_byte := data[i + 1]
            mod := (dst_byte >> 6) & 0x03
            reg := (dst_byte >> 3) & 0b111
            rm := dst_byte & 0b111

            next_instruction.reg = reg
            next_instruction.rm = rm

            switch mod {
            case 0b00: // 0 displacement with exception
                if rm == 0b110 {
                    consumed = 4
                    has_at_least(data, i + consumed) or_return

                    disp := (cast(^u16) &data[i + 2])^
                    next_instruction.data = disp
                    next_instruction.options += {.Direct}
                } else {
                    next_instruction.options += {.No_Disp}
                }
            case 0b01: // 8 bit displacement
                consumed = 3
                has_at_least(data, i + consumed) or_return

                disp := data[i + 2]
                next_instruction.data = u16(disp)
                next_instruction.options += {._8_Disp}
            case 0b10: // 16 bit displacement
                consumed = 4
                has_at_least(data, i + consumed) or_return

                disp := (cast(^u16) &data[i + 2])^
                next_instruction.data = disp
                next_instruction.options += {._16_Disp}
            case 0b11: // reg to reg
                next_instruction.options += {.Reg_To_Reg}
            }

        case .Mov_Im_To_RegMem, .Add_Im_To_RegMem, .Sub_Im_To_RegMem, .Cmp_Im_To_RegMem:
            wide := data[i] & 0b1 != 0
            consumed = 2
            has_at_least(data, i + consumed) or_return

            dst_byte := data[i + 1]
            mod := dst_byte >> 6 & 0b11
            reg := dst_byte >> 3 & 0b11
            rm := dst_byte &0b11
            next_instruction.reg = reg
            next_instruction.rm = rm

            if op != .Mov_Im_To_RegMem {
                if reg == 0 {
                    op = .Add_Im_To_RegMem
                } else if reg == 0b101 {
                    op = .Sub_Im_To_RegMem
                } else if reg == 0b111 {
                    op = .Cmp_Im_To_RegMem
                }

            }

            switch mod {
            case 0b00:
                if rm == 0b110 {
                    consumed = 6 if wide else 5
                    has_at_least(data, i + consumed) or_return
                    disp := (cast(^u16) &data[i + 2])^
                    immed: u16
                    if wide {
                        immed = (cast(^u16) &data[i + 4])^
                    } else {
                        immed = u16(data[i + 4])
                    }
                    next_instruction.options += {._16_Disp}
                    next_instruction.data = disp
                    next_instruction.data2 = immed
                } else {
                    consumed = 4 if wide else 3
                    has_at_least(data, i + consumed) or_return
                    immed: u16
                    if wide {
                        immed = (cast(^u16) &data[i + 2])^
                    } else {
                        immed = u16(data[i + 2])
                    }
                    next_instruction.data2 = immed
                    next_instruction.options += {.No_Disp}
                }
            case 0b01:
                consumed = 5 if wide else 4
                has_at_least(data, i + consumed) or_return

                disp := data[i + 2]
                next_instruction.data = u16(disp)
                next_instruction.options += {._8_Disp}
                if wide {
                    next_instruction.data2 = (cast(^u16) &data[i + 3])^
                } else {
                    next_instruction.data2 = u16(data[i + 3])
                }
            case 0b10:
                consumed = 6 if wide else 5
                has_at_least(data, i + consumed) or_return

                disp := (cast(^u16) &data[i + 2])^
                next_instruction.data = disp
                next_instruction.options += {._16_Disp}
                if wide {
                    next_instruction.data2 = (cast(^u16) &data[i + 4])^
                } else {
                    next_instruction.data2 = u16(data[i + 4])
                }
            case 0b11:
                consumed = 4 if wide else 3
                has_at_least(data, i + consumed) or_return

                next_instruction.options += {.Reg_To_Reg}
                if wide {
                    next_instruction.data2 = (cast(^u16) &data[i + 2])^
                } else {
                    next_instruction.data2 = u16(data[i + 2])
                }
            }
        case .Mov_Mem_To_Ax:
            wide := data[i] & 0b1 != 0
            consumed = 3
            has_at_least(data, i + consumed) or_return
            if wide {
                next_instruction.options += {.W}
            }
            next_instruction.data = (cast(^u16) &data[i + 1])^
        case .Mov_Ax_To_Mem:
            wide := data[i] & 0b1 != 0
            consumed = 3
            has_at_least(data, i + consumed) or_return
            if wide {
                next_instruction.options += {.W}
            }

            next_instruction.data = (cast(^u16) &data[i + 1])^
        case .Mov_Im_To_Reg:
            wide := data[i] & 0b00001000 != 0
            consumed = 1
            if wide {
                next_instruction.options += {.W}
                consumed = 3
            } else {
                consumed = 2
            }
            has_at_least(data, i + consumed) or_return

            next_instruction.reg = data[i] & 0b111
            if wide {
                next_instruction.data = (cast(^u16) &data[i + 1])^
            } else {
                next_instruction.data = u16(data[i + 1])
            }
        case .Add_Im_To_Ax, .Sub_Im_To_Ax, .Cmp_Im_To_Ax:
            wide := data[i] &0b1 != 0
            consumed = 3 if wide else 2
            has_at_least(data, i + consumed) or_return

            if wide {
                next_instruction.data = (cast(^u16) &data[i + 1])^
            } else {
                next_instruction.data = u16(data[i + 1])
            }
        case .None:
            fallthrough
        case:
            fmt.eprintln("unknown opcode\n")
            fmt.eprintf("%#b\n", data[i])
            return {}, false
        }


        append(&instrs, next_instruction)
        i += consumed
    }

    instr_slice = instrs[:]
    ok = true
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
        case .Mov_RegMem_To_RegMem, .Add_RegMem_With_Reg_To_RegMem, .Sub_RegMem_With_Reg_To_RegMem, .Cmp_RegMem_With_Reg_To_RegMem:
            w := int(.W in instr.options)
            op := opstr_from_opcode(instr.type)
            reg_str := fmt.tprintf("%s", register_file[instr.reg][w])
            rm_str: string
            if .Direct in instr.options {
                rm_str = fmt.tprintf("[%d]", instr.data)
            } else if .No_Disp in instr.options {
                rm_str = fmt.tprintf("[%s]", rm_file[instr.rm])
            } else if ._8_Disp in instr.options || ._16_Disp in instr.options {
                rm_str = fmt.tprintf("[%s + %d]", rm_file[instr.rm], instr.data)
            } else if .Reg_To_Reg in instr.options {
                rm_str = fmt.tprintf("%s", register_file[instr.rm][w])
            }
            
            if .D in instr.options {
                fmt.printf("%s %s, %s\n", op, reg_str, rm_str)
            } else {
                fmt.printf("%s %s, %s\n", op, rm_str, reg_str)
            }
        case .Mov_Im_To_RegMem, .Add_Im_To_RegMem, .Sub_Im_To_RegMem, .Cmp_Im_To_RegMem:
            w := int(.W in instr.options)
            rm_str: string
            word_str := ""
            if .Direct in instr.options {
                rm_str = fmt.tprintf("[%d]", instr.data)
            } else if .No_Disp in instr.options {
                rm_str = fmt.tprintf("[%s]", rm_file[instr.rm])
            } else if ._8_Disp in instr.options || ._16_Disp in instr.options {
                rm_str = fmt.tprintf("[%s + %d]", rm_file[instr.rm], instr.data)
            } else if .Reg_To_Reg in instr.options {
                rm_str = fmt.tprintf("%s", register_file[instr.rm][w])
            }
            if .Reg_To_Reg not_in instr.options {
                word_str = "word " if w == 1 else "byte "
            }
            fmt.printf("mov %s, %s%d\n", rm_str, word_str, instr.data2)
        case .Mov_Im_To_Reg:
            w := int(.W in instr.options)
            fmt.printf("mov %s, %d\n", register_file[instr.reg][w], instr.data)
        case .Mov_Ax_To_Mem:
            w := int(.W in instr.options)
            fmt.printf("mov [%d], %s\n", instr.data, register_file[0][w])
        case .Mov_Mem_To_Ax:
            w := int(.W in instr.options)
            fmt.printf("mov %s, [%d]\n", register_file[0][w], instr.data)
        case .Add_Im_To_Ax, .Cmp_Im_To_Ax, .Sub_Im_To_Ax:
            w := int(.W in instr.options)
            op := opstr_from_opcode(instr.type)
            fmt.printf("%s %s, %d\n", op, register_file[0][w], instr.data)
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
        // fmt.printf("Encoding instr %v with opcode {{%b, %d}}\n", inst, mask, inst_len)
        pos := 1
        for i in 0..<inst_len {
            bit := int((mask & (1 << u8(7 - i))) != 0)
            // fmt.println(i, "bit:", bit)
            pos = pos * 2 + bit
        }
        if pos == 1 do continue
        // fmt.printf("Encoding %v at %d\n", inst, pos)
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
        pos = pos * 2 + bit
        result = OPCODE_DECODER[pos]
        if result != .None do break
    }
    return
}

opstr_from_opcode :: proc(opcode: Opcode) -> string {
    switch opcode {
    case .Mov_Ax_To_Mem, .Mov_Im_To_Reg, .Mov_Im_To_RegMem, .Mov_Mem_To_Ax, .Mov_RegMem_To_RegMem:
        return "mov"
    case .Add_Im_To_Ax, .Add_Im_To_RegMem, .Add_RegMem_With_Reg_To_RegMem:
        return "add"
    case .Sub_Im_To_Ax, .Sub_Im_To_RegMem, .Sub_RegMem_With_Reg_To_RegMem:
        return "sub"
    case .Cmp_Im_To_Ax, .Cmp_Im_To_RegMem, .Cmp_RegMem_With_Reg_To_RegMem:
        return "cmp"
    case .None:
        fallthrough
    case:
        return "WTFOHNO"
    }
}