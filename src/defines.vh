`ifndef DEFINES_VH
`define DEFINES_VH

`define ZERO32          32'h00000000
`define PCSTEP          4'h4

//----------------- Instruction OPCODE -----------------

`define opcodeWidth     7
`define opcodeRange     6:0
`define functWidth      3
`define functRange      2:0

`define opLUI           7'b0110111
`define opAUIPC         7'b0010111
`define opJAL           7'b1101111
`define opJALR          7'b1100111
`define opBranch        7'b1100011
`define opLoad          7'b0000011
`define opStore         7'b0100011
`define opRI            7'b0010011
`define opRR            7'b0110011


//----------------- All Instructions ID ----------------

`define instIdxWidth    6
`define instIdxRange    5:0

`define idNOP           6'b000000
`define idLUI           6'b000001
`define idAUIPC         6'b000010
`define idJAL           6'b000011
`define idJALR          6'b000100
`define idBEQ           6'b000101
`define idBNE           6'b000110
`define idBLT           6'b000111
`define idBGE           6'b001000
`define idBLTU          6'b001001
`define idBGEU          6'b001010
`define idLB            6'b001011
`define idLH            6'b001100
`define idLW            6'b001101
`define idLBU           6'b001110
`define idLHU           6'b001111
`define idSB            6'b010000
`define idSH            6'b010001
`define idSW            6'b010010
`define idADDI          6'b010011
`define idSLLI          6'b011001
`define idSRLI          6'b011010
`define idSRAI          6'b011011
`define idADD           6'b011100
`define idSUB           6'b011101
`define idSLL           6'b011110
`define idSLT           6'b011111
`define idSLTU          6'b100000
`define idXOR           6'b100001
`define idSRL           6'b100010
`define idSRA           6'b100011
`define idOR            6'b100100
`define idAND           6'b100101

// ----------------- Instruction Type -----------------

`define instTypeWidth   3
`define instTypeRange   2:0

`define typeNOP         3'b000
`define typeLogic       3'b001
`define typeArith       3'b010
`define typeSLT         3'b011


// ----------------- Enable & Disable ------------------

`define rstEnable       1'b1
`define rstDisable      1'b0
`define chipEnable      1'b1
`define chipDisable     1'b0
`define readEnable      1'b1
`define readDisable     1'b0
`define writeEnable     1'b1
`define writeDisable    1'b0

`define instValid       1'b0
`define instInvalid     1'b1

//------------------ Hardware Properties ----------------

`define addrWidth       32
`define addrRange       31:0

`define instWidth       32
`define instRange       31:0

`define dataWidth       32
`define dataRange       31:0


//---------------- Registers ---------------------

`define regNumber       32
`define regNumberRange  0:31
`define regIdxWidth     5
`define regIdxRange     4:1

`define regNOP          5'b00000

`endif