#define FILE void
#include "defines.h"
struct optcode opt_table[] = {
  { "ADC #x", 0x69, 4, 0 },
  { "ADC (x,X)", 0x61, 4, 0 },
  { "ADC (x),Y", 0x71, 4, 0 },
  { "ADC x,X", 0x75, 4, 1 },
  { "ADC ?,X", 0x7d, 2, 0 },
  { "ADC ?,Y", 0x79, 2, 0 },
  { "ADC x", 0x65, 4, 1 },
  { "ADC ?", 0x6d, 2, 0 },
  { "ADC.B #x", 0x69, 4, 0 },
  { "ADC.B (x,X)", 0x61, 4, 0 },
  { "ADC.B (x),Y", 0x71, 4, 0 },
  { "ADC.B x,X", 0x75, 4, 0 },
  { "ADC.W ?,X", 0x7d, 2, 0 },
  { "ADC.W ?,Y", 0x79, 2, 0 },
  { "ADC.B x", 0x65, 4, 0 },
  { "ADC.W ?", 0x6d, 2, 0 },

  { "AHX (x),Y", 0x93, 4, 0 },
  { "AHX ?,Y", 0x9f, 2, 0 },
  { "AHX.B (x),Y", 0x93, 4, 0 },
  { "AHX.W ?,Y", 0x9f, 2, 0 },

  { "ALR #x", 0x4b, 4, 0 },
  { "ALR.B #x", 0x4b, 4, 0 },
  { "ANC #x", 0xb, 4, 0 },
  { "ANC.B #x", 0xb, 4, 0 },

  { "AND #x", 0x29, 4, 0 },
  { "AND (x,X)", 0x21, 4, 0 },
  { "AND (x),Y", 0x31, 4, 0 },
  { "AND x,X", 0x35, 4, 1 },
  { "AND ?,X", 0x3d, 2, 0 },
  { "AND ?,Y", 0x39, 2, 0 },
  { "AND x", 0x25, 4, 1 },
  { "AND ?", 0x2d, 2, 0 },
  { "AND.B #x", 0x29, 4, 0 },
  { "AND.B (x,X)", 0x21, 4, 0 },
  { "AND.B (x),Y", 0x31, 4, 0 },
  { "AND.B x,X", 0x35, 4, 0 },
  { "AND.W ?,X", 0x3d, 2, 0 },
  { "AND.W ?,Y", 0x39, 2, 0 },
  { "AND.B x", 0x25, 4, 0 },
  { "AND.W ?", 0x2d, 2, 0 },

  { "ARR #x", 0x6b, 4, 0 },
  { "ARR.B #x", 0x6b, 4, 0 },

  { "ASL A", 0xa, 0, 0 },
  { "ASL x,X", 0x16, 4, 1 },
  { "ASL ?,X", 0x1e, 2, 0 },
  { "ASL x", 0x6, 4, 1 },
  { "ASL ?", 0xe, 2, 0 },
  { "ASL.B x,X", 0x16, 4, 0 },
  { "ASL.W ?,X", 0x1e, 2, 0 },
  { "ASL.B x", 0x6, 4, 0 },
  { "ASL.W ?", 0xe, 2, 0 },
  { "ASL", 0xa, 0, 0 },

  { "AXS #x", 0xcb, 4, 0 },
  { "AXS.B #x", 0xcb, 4, 0 },

  { "BCC x", 0x90, 5, 0 },
  { "BCS x", 0xb0, 5, 0 },
  { "BEQ x", 0xf0, 5, 0 },
  { "BIT x", 0x24, 4, 1 },
  { "BIT ?", 0x2c, 2, 0 },
  { "BMI x", 0x30, 5, 0 },
  { "BNE x", 0xd0, 5, 0 },
  { "BPL x", 0x10, 5, 0 },
  { "BVC x", 0x50, 5, 0 },
  { "BVS x", 0x70, 5, 0 },
  { "BCC.B x", 0x90, 5, 0 },
  { "BCS.B x", 0xb0, 5, 0 },
  { "BEQ.B x", 0xf0, 5, 0 },
  { "BIT.B x", 0x24, 4, 0 },
  { "BIT.W ?", 0x2c, 2, 0 },
  { "BMI.B x", 0x30, 5, 0 },
  { "BNE.B x", 0xd0, 5, 0 },
  { "BPL.B x", 0x10, 5, 0 },
  { "BVC.B x", 0x50, 5, 0 },
  { "BVS.B x", 0x70, 5, 0 },

  { "BRK x", 0x00, 4, 0 },
  { "BRK.B x", 0x00, 4, 0 },
  { "BRK", 0x0000, 3, 0 },

  { "CLC", 0x18, 0, 0 },
  { "CLD", 0xd8, 0, 0 },
  { "CLI", 0x58, 0, 0 },
  { "CLV", 0xb8, 0, 0 },

  { "CMP #x", 0xc9, 4, 0 },
  { "CMP (x,X)", 0xc1, 4, 0 },
  { "CMP (x),Y", 0xd1, 4, 0 },
  { "CMP x,X", 0xd5, 4, 1 },
  { "CMP ?,X", 0xdd, 2, 0 },
  { "CMP ?,Y", 0xd9, 2, 0 },
  { "CMP x", 0xc5, 4, 1 },
  { "CMP ?", 0xcd, 2, 0 },
  { "CMP.B #x", 0xc9, 4, 0 },
  { "CMP.B (x,X)", 0xc1, 4, 0 },
  { "CMP.B (x),Y", 0xd1, 4, 0 },
  { "CMP.B x,X", 0xd5, 4, 0 },
  { "CMP.W ?,X", 0xdd, 2, 0 },
  { "CMP.W ?,Y", 0xd9, 2, 0 },
  { "CMP.B x", 0xc5, 4, 0 },
  { "CMP.W ?", 0xcd, 2, 0 },

  { "CPX #x", 0xe0, 4, 0 },
  { "CPX x", 0xe4, 4, 1 },
  { "CPX ?", 0xec, 2, 0 },
  { "CPX.B #x", 0xe0, 4, 0 },
  { "CPX.B x", 0xe4, 4, 0 },
  { "CPX.W ?", 0xec, 2, 0 },

  { "CPY #x", 0xc0, 4, 0 },
  { "CPY x", 0xc4, 4, 1 },
  { "CPY ?", 0xcc, 2, 0 },
  { "CPY.B #x", 0xc0, 4, 0 },
  { "CPY.B x", 0xc4, 4, 0 },
  { "CPY.W ?", 0xcc, 2, 0 },

  { "DCP (x,X)", 0xc3, 4, 0 },
  { "DCP (x),Y", 0xd3, 4, 0 },
  { "DCP x,X", 0xd7, 4, 1 },
  { "DCP ?,X", 0xdf, 2, 0 },
  { "DCP ?,Y", 0xdb, 2, 0 },
  { "DCP x", 0xc7, 4, 1 },
  { "DCP ?", 0xcf, 2, 0 },
  { "DCP.B (x,X)", 0xc3, 4, 0 },
  { "DCP.B (x),Y", 0xd3, 4, 0 },
  { "DCP.B x,X", 0xd7, 4, 0 },
  { "DCP.W ?,X", 0xdf, 2, 0 },
  { "DCP.W ?,Y", 0xdb, 2, 0 },
  { "DCP.B x", 0xc7, 4, 0 },
  { "DCP.W ?", 0xcf, 2, 0 },

  { "DEC x,X", 0xd6, 4, 1 },
  { "DEC ?,X", 0xde, 2, 0 },
  { "DEC x", 0xc6, 4, 1 },
  { "DEC ?", 0xce, 2, 0 },
  { "DEC.B x,X", 0xd6, 4, 0 },
  { "DEC.W ?,X", 0xde, 2, 0 },
  { "DEC.B x", 0xc6, 4, 0 },
  { "DEC.W ?", 0xce, 2, 0 },

  { "DEX", 0xca, 0, 0 },
  { "DEY", 0x88, 0, 0 },

  { "EOR #x", 0x49, 4, 0 },
  { "EOR (x,X)", 0x41, 4, 0 },
  { "EOR (x),Y", 0x51, 4, 0 },
  { "EOR x,X", 0x55, 4, 1 },
  { "EOR ?,X", 0x5d, 2, 0 },
  { "EOR ?,Y", 0x59, 2, 0 },
  { "EOR x", 0x45, 4, 1 },
  { "EOR ?", 0x4d, 2, 0 },
  { "EOR.B #x", 0x49, 4, 0 },
  { "EOR.B (x,X)", 0x41, 4, 0 },
  { "EOR.B (x),Y", 0x51, 4, 0 },
  { "EOR.B x,X", 0x55, 4, 0 },
  { "EOR.W ?,X", 0x5d, 2, 0 },
  { "EOR.W ?,Y", 0x59, 2, 0 },
  { "EOR.B x", 0x45, 4, 0 },
  { "EOR.W ?", 0x4d, 2, 0 },

  { "HLT", 0x2, 0, 0 },

  { "INC x,X", 0xf6, 4, 1 },
  { "INC ?,X", 0xfe, 2, 0 },
  { "INC x", 0xe6, 4, 1 },
  { "INC ?", 0xee, 2, 0 },
  { "INC.B x,X", 0xf6, 4, 0 },
  { "INC.W ?,X", 0xfe, 2, 0 },
  { "INC.B x", 0xe6, 4, 0 },
  { "INC.W ?", 0xee, 2, 0 },

  { "INX", 0xe8, 0, 0 },
  { "INY", 0xc8, 0, 0 },

  { "ISC (x,X)", 0xe3, 4, 0 },
  { "ISC (x),Y", 0xf3, 4, 0 },
  { "ISC x,X", 0xf7, 4, 1 },
  { "ISC ?,X", 0xff, 2, 0 },
  { "ISC ?,Y", 0xfb, 2, 0 },
  { "ISC x", 0xe7, 4, 1 },
  { "ISC ?", 0xef, 2, 0 },
  { "ISC.B (x,X)", 0xe3, 4, 0 },
  { "ISC.B (x),Y", 0xf3, 4, 0 },
  { "ISC.B x,X", 0xf7, 4, 0 },
  { "ISC.W ?,X", 0xff, 2, 0 },
  { "ISC.W ?,Y", 0xfb, 2, 0 },
  { "ISC.B x", 0xe7, 4, 0 },
  { "ISC.W ?", 0xef, 2, 0 },

  { "JAM", 0x2, 0, 0 },

  { "JMP (?)", 0x6c, 2, 0 },
  { "JMP ?", 0x4c, 2, 0 },
  { "JMP.W (?)", 0x6c, 2, 0 },
  { "JMP.W ?", 0x4c, 2, 0 },

  { "JSR ?", 0x20, 2, 0 },
  { "JSR.W ?", 0x20, 2, 0 },

  { "KIL", 0x2, 0, 0 },

  { "LAS ?,Y", 0xbb, 2, 0 },
  { "LAS.W ?,Y", 0xbb, 2, 0 },

  { "LAX #x", 0xab, 4, 0 },
  { "LAX (x,X)", 0xa3, 4, 0 },
  { "LAX (x),Y", 0xb3, 4, 0 },
  { "LAX x,Y", 0xb7, 4, 1 },
  { "LAX ?,Y", 0xbf, 2, 0 },
  { "LAX x", 0xa7, 4, 1 },
  { "LAX ?", 0xaf, 2, 0 },
  { "LAX.B #x", 0xab, 4, 0 },
  { "LAX.B (x,X)", 0xa3, 4, 0 },
  { "LAX.B (x),Y", 0xb3, 4, 0 },
  { "LAX.B x,Y", 0xb7, 4, 0 },
  { "LAX.W ?,Y", 0xbf, 2, 0 },
  { "LAX.B x", 0xa7, 4, 0 },
  { "LAX.W ?", 0xaf, 2, 0 },

  { "LDA #x", 0xa9, 4, 0 },
  { "LDA (x),Y", 0xb1, 4, 0 },
  { "LDA (x,X)", 0xa1, 4, 0 },
  { "LDA x,X", 0xb5, 4, 1 },
  { "LDA ?,X", 0xbd, 2, 0 },
  { "LDA ?,Y", 0xb9, 2, 0 },
  { "LDA x", 0xa5, 4, 1 },
  { "LDA ?", 0xad, 2, 0 },
  { "LDA.B #x", 0xa9, 4, 0 },
  { "LDA.B (x),Y", 0xb1, 4, 0 },
  { "LDA.B (x,X)", 0xa1, 4, 0 },
  { "LDA.B x,X", 0xb5, 4, 0 },
  { "LDA.W ?,X", 0xbd, 2, 0 },
  { "LDA.W ?,Y", 0xb9, 2, 0 },
  { "LDA.B x", 0xa5, 4, 0 },
  { "LDA.W ?", 0xad, 2, 0 },

  { "LDX #x", 0xa2, 4, 0 },
  { "LDX x,Y", 0xb6, 4, 1 },
  { "LDX ?,Y", 0xbe, 2, 0 },
  { "LDX x", 0xa6, 4, 1 },
  { "LDX ?", 0xae, 2, 0 },
  { "LDX.B #x", 0xa2, 4, 0 },
  { "LDX.B x,Y", 0xb6, 4, 0 },
  { "LDX.W ?,Y", 0xbe, 2, 0 },
  { "LDX.B x", 0xa6, 4, 0 },
  { "LDX.W ?", 0xae, 2, 0 },

  { "LDY #x", 0xa0, 4, 0 },
  { "LDY x", 0xa4, 4, 1 },
  { "LDY ?", 0xac, 2, 0 },
  { "LDY x,X", 0xb4, 4, 1 },
  { "LDY ?,X", 0xbc, 2, 0 },
  { "LDY.B #x", 0xa0, 4, 0 },
  { "LDY.B x", 0xa4, 4, 0 },
  { "LDY.W ?", 0xac, 2, 0 },
  { "LDY.B x,X", 0xb4, 4, 0 },
  { "LDY.W ?,X", 0xbc, 2, 0 },

  { "LSR A", 0x4a, 0, 0 },
  { "LSR x", 0x46, 4, 1 },
  { "LSR ?", 0x4e, 2, 0 },
  { "LSR x,X", 0x56, 4, 1 },
  { "LSR ?,X", 0x5e, 2, 0 },
  { "LSR.B x", 0x46, 4, 0 },
  { "LSR.W ?", 0x4e, 2, 0 },
  { "LSR.B x,X", 0x56, 4, 0 },
  { "LSR.W ?,X", 0x5e, 2, 0 },
  { "LSR", 0x4a, 0, 0 },

  { "NOP #x", 0x80, 4, 0 },
  { "NOP x,X", 0x14, 4, 1 },
  { "NOP ?,X", 0x1c, 2, 0 },
  { "NOP x", 0x4, 4, 1 },
  { "NOP ?", 0xc, 2, 0 },
  { "NOP", 0x1a, 0, 0 },
  { "NOP.B #x", 0x80, 4, 0 },
  { "NOP.B x,X", 0x14, 4, 0 },
  { "NOP.W ?,X", 0x1c, 2, 0 },
  { "NOP.B x", 0x4, 4, 0 },
  { "NOP.W ?", 0xc, 2, 0 },

  { "ORA #x", 0x9, 4, 0 },
  { "ORA (x,X)", 0x1, 4, 0 },
  { "ORA (x),Y", 0x11, 4, 0 },
  { "ORA x,X", 0x15, 4, 1 },
  { "ORA ?,X", 0x1d, 2, 0 },
  { "ORA ?,Y", 0x19, 2, 0 },
  { "ORA x", 0x5, 4, 1 },
  { "ORA ?", 0xd, 2, 0 },
  { "ORA.B #x", 0x9, 4, 0 },
  { "ORA.B (x,X)", 0x1, 4, 0 },
  { "ORA.B (x),Y", 0x11, 4, 0 },
  { "ORA.B x,X", 0x15, 4, 0 },
  { "ORA.W ?,X", 0x1d, 2, 0 },
  { "ORA.W ?,Y", 0x19, 2, 0 },
  { "ORA.B x", 0x5, 4, 0 },
  { "ORA.W ?", 0xd, 2, 0 },

  { "PHA", 0x48, 0, 0 },
  { "PHP", 0x8, 0, 0 },
  { "PLA", 0x68, 0, 0 },
  { "PLP", 0x28, 0, 0 },

  { "RLA (x,X)", 0x23, 4, 0 },
  { "RLA (x),Y", 0x33, 4, 0 },
  { "RLA x,X", 0x37, 4, 1 },
  { "RLA ?,X", 0x3f, 2, 0 },
  { "RLA ?,Y", 0x3b, 2, 0 },
  { "RLA x", 0x27, 4, 1 },
  { "RLA ?", 0x2f, 2, 0 },
  { "RLA.B (x,X)", 0x23, 4, 0 },
  { "RLA.B (x),Y", 0x33, 4, 0 },
  { "RLA.B x,X", 0x37, 4, 0 },
  { "RLA.W ?,X", 0x3f, 2, 0 },
  { "RLA.W ?,Y", 0x3b, 2, 0 },
  { "RLA.B x", 0x27, 4, 0 },
  { "RLA.W ?", 0x2f, 2, 0 },

  { "ROL A", 0x2a, 0, 0 },
  { "ROL x,X", 0x36, 4, 1 },
  { "ROL ?,X", 0x3e, 2, 0 },
  { "ROL x", 0x26, 4, 1 },
  { "ROL ?", 0x2e, 2, 0 },
  { "ROL.B x,X", 0x36, 4, 0 },
  { "ROL.W ?,X", 0x3e, 2, 0 },
  { "ROL.B x", 0x26, 4, 0 },
  { "ROL.W ?", 0x2e, 2, 0 },
  { "ROL", 0x2a, 0, 0 },

  { "ROR A", 0x6a, 0, 0 },
  { "ROR x", 0x66, 4, 1 },
  { "ROR ?", 0x6e, 2, 0 },
  { "ROR x,X", 0x76, 4, 1 },
  { "ROR ?,X", 0x7e, 2, 0 },
  { "ROR.B x", 0x66, 4, 0 },
  { "ROR.W ?", 0x6e, 2, 0 },
  { "ROR.B x,X", 0x76, 4, 0 },
  { "ROR.W ?,X", 0x7e, 2, 0 },
  { "ROR", 0x6a, 0, 0 },

  { "RRA (x,X)", 0x63, 4, 0 },
  { "RRA (x),Y", 0x73, 4, 0 },
  { "RRA x,X", 0x77, 4, 1 },
  { "RRA ?,X", 0x7f, 2, 0 },
  { "RRA ?,Y", 0x7b, 2, 0 },
  { "RRA x", 0x67, 4, 1 },
  { "RRA ?", 0x6f, 2, 0 },
  { "RRA.B (x,X)", 0x63, 4, 0 },
  { "RRA.B (x),Y", 0x73, 4, 0 },
  { "RRA.B x,X", 0x77, 4, 0 },
  { "RRA.W ?,X", 0x7f, 2, 0 },
  { "RRA.W ?,Y", 0x7b, 2, 0 },
  { "RRA.B x", 0x67, 4, 0 },
  { "RRA.W ?", 0x6f, 2, 0 },

  { "RTI", 0x40, 0, 0 },
  { "RTS", 0x60, 0, 0 },

  { "SAX (x,X)", 0x83, 4, 0 },
  { "SAX x,Y", 0x97, 4, 0 },
  { "SAX x", 0x87, 4, 1 },
  { "SAX ?", 0x8f, 2, 0 },
  { "SAX.B (x,X)", 0x83, 4, 0 },
  { "SAX.B x,Y", 0x97, 4, 0 },
  { "SAX.B x", 0x87, 4, 0 },
  { "SAX.W ?", 0x8f, 2, 0 },

  { "SBC #x", 0xe9, 4, 0 },
  { "SBC (x,X)", 0xe1, 4, 0 },
  { "SBC (x),Y", 0xf1, 4, 0 },
  { "SBC x,X", 0xf5, 4, 1 },
  { "SBC ?,X", 0xfd, 2, 0 },
  { "SBC ?,Y", 0xf9, 2, 0 },
  { "SBC x", 0xe5, 4, 1 },
  { "SBC ?", 0xed, 2, 0 },
  { "SBC.B #x", 0xe9, 4, 0 },
  { "SBC.B (x,X)", 0xe1, 4, 0 },
  { "SBC.B (x),Y", 0xf1, 4, 0 },
  { "SBC.B x,X", 0xf5, 4, 0 },
  { "SBC.W ?,X", 0xfd, 2, 0 },
  { "SBC.W ?,Y", 0xf9, 2, 0 },
  { "SBC.B x", 0xe5, 4, 0 },
  { "SBC.W ?", 0xed, 2, 0 },

  { "SEC", 0x38, 0, 0 },
  { "SED", 0xf8, 0, 0 },
  { "SEI", 0x78, 0, 0 },
  { "SHX ?,Y", 0x9e, 2, 0 },
  { "SHX.W ?,Y", 0x9e, 2, 0 },
  { "SHY ?,X", 0x9c, 2, 0 },
  { "SHY.W ?,X", 0x9c, 2, 0 },

  { "SLO (x,X)", 0x3, 4, 0 },
  { "SLO (x),Y", 0x13, 4, 0 },
  { "SLO x,X", 0x17, 4, 1 },
  { "SLO ?,X", 0x1f, 2, 0 },
  { "SLO ?,Y", 0x1b, 2, 0 },
  { "SLO x", 0x7, 4, 1 },
  { "SLO ?", 0xf, 2, 0 },
  { "SLO.B (x,X)", 0x3, 4, 0 },
  { "SLO.B (x),Y", 0x13, 4, 0 },
  { "SLO.B x,X", 0x17, 4, 0 },
  { "SLO.W ?,X", 0x1f, 2, 0 },
  { "SLO.W ?,Y", 0x1b, 2, 0 },
  { "SLO.B x", 0x7, 4, 0 },
  { "SLO.W ?", 0xf, 2, 0 },

  { "SRE (x,X)", 0x43, 4, 0 },
  { "SRE (x),Y", 0x53, 4, 0 },
  { "SRE x,X", 0x57, 4, 1 },
  { "SRE ?,X", 0x5f, 2, 0 },
  { "SRE ?,Y", 0x5b, 2, 0 },
  { "SRE x", 0x47, 4, 1 },
  { "SRE ?", 0x4f, 2, 0 },
  { "SRE.B (x,X)", 0x43, 4, 0 },
  { "SRE.B (x),Y", 0x53, 4, 0 },
  { "SRE.B x,X", 0x57, 4, 0 },
  { "SRE.W ?,X", 0x5f, 2, 0 },
  { "SRE.W ?,Y", 0x5b, 2, 0 },
  { "SRE.B x", 0x47, 4, 0 },
  { "SRE.W ?", 0x4f, 2, 0 },

  { "STA (x,X)", 0x81, 4, 0 },
  { "STA (x),Y", 0x91, 4, 0 },
  { "STA x,X", 0x95, 4, 1 },
  { "STA ?,X", 0x9d, 2, 0 },
  { "STA ?,Y", 0x99, 2, 0 },
  { "STA x", 0x85, 4, 1 },
  { "STA ?", 0x8d, 2, 0 },
  { "STA.B (x,X)", 0x81, 4, 0 },
  { "STA.B (x),Y", 0x91, 4, 0 },
  { "STA.B x,X", 0x95, 4, 0 },
  { "STA.W ?,X", 0x9d, 2, 0 },
  { "STA.W ?,Y", 0x99, 2, 0 },
  { "STA.B x", 0x85, 4, 0 },
  { "STA.W ?", 0x8d, 2, 0 },

  { "STX x,Y", 0x96, 4, 0 },
  { "STX x", 0x86, 4, 1 },
  { "STX ?", 0x8e, 2, 0 },
  { "STX.B x,Y", 0x96, 4, 0 },
  { "STX.B x", 0x86, 4, 0 },
  { "STX.W ?", 0x8e, 2, 0 },

  { "STY x,X", 0x94, 4, 0 },
  { "STY x", 0x84, 4, 1 },
  { "STY ?", 0x8c, 2, 0 },
  { "STY.B x,X", 0x94, 4, 0 },
  { "STY.B x", 0x84, 4, 0 },
  { "STY.W ?", 0x8c, 2, 0 },

  { "TAS ?,Y", 0x9b, 2, 0 },
  { "TAS.W ?,Y", 0x9b, 2, 0 },
  { "TAX", 0xaa, 0, 0 },
  { "TAY", 0xa8, 0, 0 },
  { "TSX", 0xba, 0, 0 },
  { "TXA", 0x8a, 0, 0 },
  { "TXS", 0x9a, 0, 0 },
  { "TYA", 0x98, 0, 0 },

  { "XAA #x", 0x8b, 4, 0 },
  { "XAA.B #x", 0x8b, 4, 0 },

  { "E", 0x100, 0xFF, 0 }
};