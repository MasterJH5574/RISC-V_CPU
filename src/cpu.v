// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
    input  wire					rdy_in,		    // ready signal, pause cpu when low // Todo: usage

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)(and 0 for read?)

	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

    // link the PC to IF
    wire[`addrRange] PC_pc_out;

    // stall controller
    wire ifStall, idStall, memStall; // send request
    wire stall_out;
    stallCtrl stallCtrl0(
        .rst_in(rst_in),
        .ifStall_in(ifStall),
        .idStall_in(idStall),
        .memStall_in(memStall),
        .stall_out(stall_out)
    );

    // link EX to PC, IF_ID and ID_EX for Jump and Branch
    wire                pcJump;
    wire[`addrRange]    pcTarget;

    PC PC0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .rdy_in(rdy_in), // Todo
        .stall_in(stall_out),
        .pcJump_in(pcJump),
        .pcTarget_in(pcTarget),
        .pc_out(PC_pc_out)
    );

    // count clock for IF
    wire[`stallCntRange] IF_cnt_in;
    wire[`stallCntRange] IF_cnt_out;

    // link IF to IF_ID
    wire[`addrRange] IF_pc_out;
    wire[`instRange] IF_inst_out;

    IF IF0(
        .rst_in(rst_in),
        .pc_in(PC_pc_out),
        .cnt_in(IF_cnt_in),
        .cnt_out(IF_cnt_out),
        .pc_out(IF_pc_out),
        .inst_out(IF_inst_out),
        .ifStall_out(ifStall)
    );

    // link IF_ID to ID
    wire[`addrRange] IF_ID_pc_out;
    wire[`instRange] IF_ID_inst_out;

    IF_ID IF_ID0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .stall_in(stall_out),
        .pcJump_in(pcJump),
        .pc_in(pc),
        .inst_in(mem_din),
        .pc_out(IF_ID_pc_out),
        .inst_out(IF_ID_inst_out)
    );

    // link ID to RegFile
    wire                ID_reg1E_out;
    wire                ID_reg2E_out;
    wire[`regIdxRange]  ID_reg1Idx_out;
    wire[`regIdxRange]  ID_reg2Idx_out;

    // link RegFile to ID
    wire[`dataRange]    RegFile_reg1Data_out;
    wire[`dataRange]    RegFile_reg2Data_out;

    // link ID to ID_EX
    wire[`addrRange]        ID_pc_out;
    wire                    ID_rdE_out;
    wire[`regIdxRange]      ID_rdIdx_out;
    wire[`instIdxRange]     ID_instIdx_out;
    wire[`instTypeRange]    ID_instType_out;
    wire[`dataRange]        ID_rs1Data_out;
    wire[`dataRange]        ID_rs2Data_out;
    wire[`dataRange]        ID_immData_out;

    // link EX to EX_MEM, also forwarding to ID
    wire                    EX_rdE_out;
    wire[`regIdxRange]      EX_rdIdx_out;
    wire[`dataRange]        EX_rdData_out;

    // link MEM to MEM_WB, also forwarding to ID
    wire                    MEM_rdE_out;
    wire[`regIdxRange]      MEM_rdIdx_out;
    wire[`dataRange]        MEM_rdData_out;

    ID ID0(
        .rst_in(rst_in),
        .pc_in(IF_ID_pc_out),
        .inst_in(IF_ID_inst_out),
        .reg1Data_in(RegFile_reg1Data_out),
        .reg2Data_in(RegFile_reg2Data_out),
        // -- begin forwarding input --
        .EX_rdE_in(EX_rdE_out),
        .EX_rdIdx_in(EX_rdIdx_out),
        .EX_rdData_in(EX_rdData_out),
        .MEM0_rdE_in(MEM_rdE_out),
        .MEM0_rdIdx_in(MEM_rdIdx_out),
        .MEM0_rdData_in(MEM_rdData_out),
        // --- end forwarding input ---
        .reg1E_out(ID_reg1E_out),
        .reg2E_out(ID_reg2E_out),
        .reg1Idx_out(ID_reg1Idx_out),
        .reg2Idx_out(ID_reg2Idx_out),
        .pc_out(ID_pc_out),
        .rdE_out(ID_rdE_out),
        .rdIdx_out(ID_rdIdx_out),
        .instIdx_out(ID_instIdx_out),
        .instType_out(ID_instType_out),
        .rs1Data_out(ID_rs1Data_out),
        .rs2Data_out(ID_rs2Data_out),
        .immData_out(ID_immData_out),
        .idStall_out(idStall)
    );

    // link ID_EX to EX
    wire[`addrRange]        ID_EX_pc_out;
    wire                    ID_EX_rdE_out;
    wire[`regIdxRange]      ID_EX_rdIdx_out;
    wire[`instIdxRange]     ID_EX_instIdx_out;
    wire[`instTypeRange]    ID_EX_instType_out;
    wire[`dataRange]        ID_EX_rs1Data_out;
    wire[`dataRange]        ID_EX_rs2Data_out;
    wire[`dataRange]        ID_EX_immData_out;

    ID_EX ID_EX0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .stall_in(stall_out),
        .pcJump_in(pcJump),
        .pc_in(ID_pc_out),
        .rdE_in(ID_rdE_out),
        .rdIdx_out(ID_rdIdx_out),
        .instIdx_in(ID_instIdx_out),
        .instType_in(ID_instType_out),
        .rs1Data_in(ID_rs1Data_out),
        .rs2Data_in(ID_rs2Data_out),
        .immData_out(ID_immData_out),
        .pc_out(ID_EX_pc_out),
        .rdE_out(ID_EX_rdE_out),
        .rdIdx_out(ID_EX_rdIdx_out),
        .instIdx_out(ID_EX_instIdx_out),
        .instType_out(ID_EX_instType_out),
        .rs1Data_out(ID_EX_rs1Data_out),
        .rs2Data_out(ID_EX_rs2Data_out),
        .immData_out(ID_EX_immData_out)
    );

    EX EX0(
        .rst_in(rst_in),
        .pc_in(ID_EX_pc_out),
        .rdE_in(ID_EX_rdE_out),
        .rdIdx_in(ID_EX_rdIdx_out),
        .instIdx_in(ID_EX_instIdx_out),
        .instType_in(ID_EX_instType_out),
        .rs1Data_in(ID_EX_rs1Data_out),
        .rs2Data_in(ID_EX_rs2Data_out),
        .immData_in(ID_EX_immData_out),
        .rdE_out(EX_rdE_out),
        .rdIdx_out(EX_rdIdx_out),
        .rdData_out(EX_rdData_out)
    );

    // link EX_MEM to MEM
    wire                    EX_MEM_rdE_out;
    wire[`regIdxRange]      EX_MEM_rdIdx_out;
    wire[`dataRange]        EX_MEM_rdData_out;

    EX_MEM EX_MEM0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .stall_in(stall_out),
        .rdE_in(EX_rdE_out),
        .rdIdx_in(EX_rdIdx_out),
        .rdData_in(EX_rdIdx_out),
        .rdE_out(EX_MEM_rdE_out),
        .rdIdx_out(EX_MEM_rdIdx_out),
        .rdData_out(EX_MEM_rdData_out)
    );

    MEM MEM0(
        .rst_in(rst_in),
        .rdE_in(EX_MEM_rdE_out),
        .rdIdx_in(EX_MEM_rdIdx_out),
        .rdData_in(EX_MEM_rdData_out),
        .rdE_out(MEM_rdE_out),
        .rdIdx_out(MEM_rdIdx_out),
        .rdData_out(MEM_rdData_out),
        .memStall_out(memStall)
    );

    // link MEM_WB to RegFile
    wire                    MEM_WB_rdE_out;
    wire[`regIdxRange]      MEM_WB_rdIdx_out;
    wire[`dataRange]        MEM_WB_rdData_out;

    MEM_WB MEM_WB0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .stall_in(stall_out),
        .rdE_in(MEM_rdE_out),
        .rdIdx_in(MEM_rdIdx_out),
        .rdData_in(MEM_rdData_out),
        .rdE_out(MEM_WB_rdE_out),
        .rdIdx_out(MEM_WB_rdIdx_out),
        .rdData_out(MEM_WB_rdData_out)
    );

    RegFile RegFile0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .writeE_in(MEM_WB_rdE_out),
        .writeIdx_in(MEM_WB_rdIdx_out),
        .writeData_in(MEM_WB_rdData_out),
        .reg1E_in(ID_reg1E_out),
        .reg1Idx_in(ID_reg1Idx_out),
        .reg2E_in(ID_reg2E_out),
        .reg2Idx_in(ID_reg2Idx_out),
        .reg1Data_out(RegFile_reg1Data_out),
        .reg2Data_out(RegFile_reg2Data_out)
    );
endmodule : cpu