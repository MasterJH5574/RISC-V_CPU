// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
    input  wire					rdy_in,		    // ready signal, pause cpu when low

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

    // stall controller
    wire ifStall, idStall, memStall; // send request
    wire[`stallRange] stall_out;
    stallCtrl stallCtrl0(
        .rst_in(rst_in),
        .ifStall_in(ifStall),
        .idStall_in(idStall),
        .memStall_in(memStall),
        .stall_out(stall_out)
    );

    // Branch Target Buffer
    wire[`addrRange] IF_BTB_pc;
    wire EX_BTB_in;
    wire EX_BTB_opt;
    wire[`addrRange] EX_BTB_pc;
    wire[`addrRange] EX_BTB_target;
    wire[`addrRange] BTB_pcPred;
    wire BTB_taken;

    BTB BTB0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .rdy_in(rdy_in),
        .IF_pc_in(IF_BTB_pc),
        .EX_in(EX_BTB_in),
        .EX_opt(EX_BTB_opt),
        .EX_pc_in(EX_BTB_pc),
        .EX_target_in(EX_BTB_target),
        .taken_out(BTB_taken),
        .pcPred_out(BTB_pcPred)
    );


    // link EX to PC, IF_ID and ID_EX for Jump and Branch
    wire                pcJump;
    wire[`addrRange]    pcTarget;

    // link IF to IF_ID
    wire  IF_instE_out;
    wire[`addrRange] IF_pc_out;
    wire[`instRange] IF_inst_out;
    wire IF_taken_out;
    wire[`addrRange] IF_pcPred_out;

    // Memory Controller busy signal
    wire MC_busyICache;
    wire MC_busyMEM;

    // MEM accessing MC
    wire MEM_MCAccess_out;

    // link IF and I-cache
    wire                ICache_IF_instE_out;
    wire[`instRange]    ICache_IF_inst_out;
    wire                IF_ICacheE_out;
    wire[17:0]          IF_ICacheAddr_out;

    IF IF0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .rdy_in(rdy_in),
        .stall_in(stall_out),
        .pcJump_in(pcJump),
        .pcTarget_in(pcTarget),
        .MEM_MCAccess_in(MEM_MCAccess_out),
        .instE_in(ICache_IF_instE_out),
        .inst_in(ICache_IF_inst_out),
        .IF_BTB_taken_in(BTB_taken),
        .IF_BTB_pcPred_in(BTB_pcPred),
        .ICache_out(IF_ICacheE_out),
        .ICacheAddr_out(IF_ICacheAddr_out),
        .instE_out(IF_instE_out),
        .IF_pc_out(IF_pc_out),
        .inst_out(IF_inst_out),
        .IF_taken_out(IF_taken_out),
        .IF_pcPred_out(IF_pcPred_out),
        .IF_BTB_pc_out(IF_BTB_pc)
    );

    // link IF_ID to ID
    wire[`addrRange] IF_ID_pc_out;
    wire[`instRange] IF_ID_inst_out;
    wire             IF_ID_taken_out;
    wire[`addrRange] IF_ID_pcPred_out;

    IF_ID IF_ID0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .rdy_in(rdy_in),
        .stall_in(stall_out),
        .pcJump_in(pcJump),
        .instE_in(IF_instE_out),
        .pc_in(IF_pc_out),
        .inst_in(IF_inst_out),
        .IF_ID_taken_in(IF_taken_out),
        .IF_ID_pcPred_in(IF_pcPred_out),
        .IF_ID_pc_out(IF_ID_pc_out),
        .inst_out(IF_ID_inst_out),
        .IF_ID_taken_out(IF_ID_taken_out),
        .IF_ID_pcPred_out(IF_ID_pcPred_out)
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
    wire                    ID_instType_out;
    wire[`dataRange]        ID_rs1Data_out;
    wire[`dataRange]        ID_rs2Data_out;
    wire[`dataRange]        ID_immData_out;
    wire                    ID_taken_out;
    wire[`addrRange]        ID_pcPred_out;

    // link EX to EX_MEM, also forwarding to ID
    wire[`instIdxRange]     EX_instIdx_out; // link EX to ID to handle data hazard caused by LOAD
    wire[`addrRange]        EX_memAddr_out;  // no forwarding
    wire[`dataRange]        EX_valStore_out; // no forwarding
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
        .ID_taken_in(IF_ID_taken_out),
        .ID_pcPred_in(IF_ID_pcPred_out),
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
        .instIdxEx_in(EX_instIdx_out),
        .reg1E_out(ID_reg1E_out),
        .reg2E_out(ID_reg2E_out),
        .reg1Idx_out(ID_reg1Idx_out),
        .reg2Idx_out(ID_reg2Idx_out),
        .ID_pc_out(ID_pc_out),
        .rdE_out(ID_rdE_out),
        .rdIdx_out(ID_rdIdx_out),
        .instIdx_out(ID_instIdx_out),
        .instType_out(ID_instType_out),
        .rs1Data_out(ID_rs1Data_out),
        .rs2Data_out(ID_rs2Data_out),
        .immData_out(ID_immData_out),
        .ID_taken_out(ID_taken_out),
        .ID_pcPred_out(ID_pcPred_out),
        .idStall_out(idStall)
    );

    // link ID_EX to EX
    wire[`addrRange]        ID_EX_pc_out;
    wire                    ID_EX_rdE_out;
    wire[`regIdxRange]      ID_EX_rdIdx_out;
    wire[`instIdxRange]     ID_EX_instIdx_out;
    wire                    ID_EX_instType_out;
    wire[`dataRange]        ID_EX_rs1Data_out;
    wire[`dataRange]        ID_EX_rs2Data_out;
    wire[`dataRange]        ID_EX_immData_out;
    wire                    ID_EX_taken_out;
    wire[`addrRange]        ID_EX_pcPred_out;

    ID_EX ID_EX0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .rdy_in(rdy_in),
        .stall_in(stall_out),
        .pcJump_in(pcJump),
        .pc_in(ID_pc_out),
        .rdE_in(ID_rdE_out),
        .rdIdx_in(ID_rdIdx_out),
        .instIdx_in(ID_instIdx_out),
        .instType_in(ID_instType_out),
        .rs1Data_in(ID_rs1Data_out),
        .rs2Data_in(ID_rs2Data_out),
        .immData_in(ID_immData_out),
        .ID_EX_taken_in(ID_taken_out),
        .ID_EX_pcPred_in(ID_pcPred_out),
        .ID_EX_pc_out(ID_EX_pc_out),
        .rdE_out(ID_EX_rdE_out),
        .rdIdx_out(ID_EX_rdIdx_out),
        .instIdx_out(ID_EX_instIdx_out),
        .instType_out(ID_EX_instType_out),
        .rs1Data_out(ID_EX_rs1Data_out),
        .rs2Data_out(ID_EX_rs2Data_out),
        .immData_out(ID_EX_immData_out),
        .ID_EX_taken_out(ID_EX_taken_out),
        .ID_EX_pcPred_out(ID_EX_pcPred_out)
    );

    // link EX to counter
//    wire[1:0] counter_signal;

    EX EX0(
        .rst_in(rst_in),
        .stall_in(stall_out),
        .pc_in(ID_EX_pc_out),
        .rdE_in(ID_EX_rdE_out),
        .rdIdx_in(ID_EX_rdIdx_out),
        .instIdx_in(ID_EX_instIdx_out),
        .instType_in(ID_EX_instType_out),
        .rs1Data_in(ID_EX_rs1Data_out),
        .rs2Data_in(ID_EX_rs2Data_out),
        .immData_in(ID_EX_immData_out),
        .EX_taken_in(ID_EX_taken_out),
        .EX_pcPred_in(ID_EX_pcPred_out),
        .instIdx_out(EX_instIdx_out),
        .memAddr_out(EX_memAddr_out),
        .valStore_out(EX_valStore_out),
        .rdE_out(EX_rdE_out),
        .rdIdx_out(EX_rdIdx_out),
        .rdData_out(EX_rdData_out),
        .EX_BTB_out(EX_BTB_in),
        .EX_BTB_opt_out(EX_BTB_opt),
        .EX_BTB_pc_out(EX_BTB_pc),
        .EX_BTB_target_out(EX_BTB_target),
//        .counter_out(counter_signal),
        .pcJump_out(pcJump),
        .pcTarget_out(pcTarget)
    );

    // link EX_MEM to MEM
    wire[`instIdxRange]     EX_MEM_instIdx_out;
    wire[17:0]              EX_MEM_memAddr_out;
    wire[`dataRange]        EX_MEM_valStore_out;
    wire                    EX_MEM_rdE_out;
    wire[`regIdxRange]      EX_MEM_rdIdx_out;
    wire[`dataRange]        EX_MEM_rdData_out;

    EX_MEM EX_MEM0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .rdy_in(rdy_in),
        .stall_in(stall_out),
        .instIdx_in(EX_instIdx_out),
        .memAddr_in(EX_memAddr_out),
        .valStore_in(EX_valStore_out),
        .rdE_in(EX_rdE_out),
        .rdIdx_in(EX_rdIdx_out),
        .rdData_in(EX_rdData_out),
        .instIdx_out(EX_MEM_instIdx_out),
        .memAddr_out(EX_MEM_memAddr_out),
        .valStore_out(EX_MEM_valStore_out),
        .rdE_out(EX_MEM_rdE_out),
        .rdIdx_out(EX_MEM_rdIdx_out),
        .rdData_out(EX_MEM_rdData_out)
    );

    // link MEM to Memory Controller
    wire                MEM_MCE_out;
    wire                MEM_MCrw_out;
    wire[`addrRange]    MEM_MCAddr_out;
    wire[`dataRange]    MEM_MCData_out;
    wire[2:0]           MEM_MCLen_out;
    wire                MC_DataE_out;
    wire[`instRange]    MC_Data_out;

    MEM MEM0(
        .rst_in(rst_in),
        .instIdx_in(EX_MEM_instIdx_out),
        .memAddr_in(EX_MEM_memAddr_out),
        .valStore_in(EX_MEM_valStore_out),
        .rdE_in(EX_MEM_rdE_out),
        .rdIdx_in(EX_MEM_rdIdx_out),
        .rdData_in(EX_MEM_rdData_out),
        .MC_busyICache_in(MC_busyICache),
        .MC_busyMEM_in(MC_busyMEM),
        .MC_dataE_in(MC_DataE_out),
        .MC_data_in(MC_Data_out),
        .MCE_out(MEM_MCE_out),
        .MCrw_out(MEM_MCrw_out),
        .MCAddr_out(MEM_MCAddr_out),
        .MCData_out(MEM_MCData_out),
        .MCLen_out(MEM_MCLen_out),
        .MEM_MCAccess_out(MEM_MCAccess_out),
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
        .rdy_in(rdy_in),
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
        .rdy_in(rdy_in),
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

    // link Memory Controller and I-cache
    wire                    MC_ICache_instE_out;
    wire[`instRange]        MC_ICache_inst_out;
    wire                    ICache_MCE_out;
    wire[17:0]              ICache_MC_addr_out;

    memCtrl memCtrl0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .rdy_in(rdy_in),
        .ICache_in(ICache_MCE_out),
        .ICacheAddr_in(ICache_MC_addr_out),
        .MEM_in(MEM_MCE_out),
        .MEMrw_in(MEM_MCrw_out),
        .MEMAddr_in(MEM_MCAddr_out),
        .MEMData_in(MEM_MCData_out),
        .MEMLen_in(MEM_MCLen_out),
        .ramData_in(mem_din),
        .ramRW_out(mem_wr),
        .ramAddr_out(mem_a),
        .ramData_out(mem_dout),
        .busyICache_out(MC_busyICache),
        .busyMEM_out(MC_busyMEM),
        .ICache_instE_out(MC_ICache_instE_out),
        .ICache_inst_out(MC_ICache_inst_out),
        .MEMdataE_out(MC_DataE_out),
        .MEMdata_out(MC_Data_out)
    );

    ICache ICache0(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .rdy_in(rdy_in),
        .pcJump_in(pcJump),
        .IF_in(IF_ICacheE_out),
        .IFAddr_in(IF_ICacheAddr_out),
        .MEM_MCAccess_in(MEM_MCAccess_out),
        .MC_busyICache_in(MC_busyICache),
        .MC_busyMEM_in(MC_busyMEM),
        .MCinstE_in(MC_ICache_instE_out),
        .MCinst_in(MC_ICache_inst_out),
        .IF_instE_out(ICache_IF_instE_out),
        .IF_inst_out(ICache_IF_inst_out),
        .MCE_out(ICache_MCE_out),
        .MC_addr_out(ICache_MC_addr_out),
        .ifStall_out(ifStall)
    );

//    counter counter0(
//        .clk_in(clk_in),
//        .rst_in(rst_in),
//        .rdy_in(rdy_in),
//        .counter_in(counter_signal)
//    );
endmodule : cpu