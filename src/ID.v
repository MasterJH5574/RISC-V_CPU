`include "defines.vh"

module ID(
    input wire                  rst_in,

    input wire[`addrRange]      pc_in,
    input wire[`instRange]      inst_in,

    input wire[`dataRange]      reg1Data_in,
    input wire[`dataRange]      reg2Data_in,

    // accept forwarding from the end of EX, MEM(not LD/ST)
    input wire                  EX_rdE_in,
    input wire[`regIdxRange]    EX_rdIdx_in,
    input wire[`dataRange]      EX_rdData_in,

    input wire                  MEM0_rdE_in,        // named "MEM0" in order to emphasize not LD/ST
    input wire[`regIdxRange]    MEM0_rdIdx_in,
    input wire[`dataRange]      MEM0_rdData_in,

    // input instruction ID from EX for data hazard caused by LOAD
    input wire[`instIdxRange]   instIdxEx_in,

    // output to RegFile
    output reg                  reg1E_out,
    output reg                  reg2E_out,
    output reg[`regIdxRange]    reg1Idx_out,
    output reg[`regIdxRange]    reg2Idx_out,

    // output to ID_EX
    output reg[`addrRange]      pc_out,

    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,

    output reg[`instIdxRange]   instIdx_out,
    output reg[`instTypeRange]  instType_out,

    output reg[`dataRange]      rs1Data_out,
    output reg[`dataRange]      rs2Data_out,
    output reg[`dataRange]      immData_out,

    // stall request
    output wire                 idStall_out
);

    wire[6:0] opcode = inst_in[6:0];
    wire[2:0] funct3 = inst_in[14:12];
    wire[6:0] funct7 = inst_in[31:25];

    reg instValid;              // Todo: usage of instValid?

    // ---------------- DECODE -------------------
    always @ (*) begin
        if (rst_in == `rstEnable) begin
            instValid       <= `instValid;
            instIdx_out     <= `idNOP;
            instType_out    <= `typeNOP;
            rdE_out         <= `writeDisable;
            rdIdx_out       <= `regNOP;
            reg1E_out       <= `readDisable;
            reg2E_out       <= `readDisable;
            reg1Idx_out     <= `regNOP;
            reg2Idx_out     <= `regNOP;
            immData_out     <= `ZERO32;
        end else begin
            case (opcode)
                `opLUI: begin                                       // LUI, U-type
                    instValid   <= `instValid;
                    reg1E_out   <= `readDisable;
                    reg2E_out   <= `readDisable;
                    reg1Idx_out <= `regNOP;
                    reg2Idx_out <= `regNOP;
                    rdE_out     <= `writeEnable;
                    rdIdx_out   <= inst_in[11:7];
                    immData_out <= {inst_in[31:12], {12{1'b0}}};
                    instIdx_out <= `idLUI;
                    instType_out<= `typeValid;
                end
                `opAUIPC: begin                                     // AUIPC, U-type
                    instValid   <= `instValid;
                    reg1E_out   <= `readDisable;
                    reg2E_out   <= `readDisable;
                    reg1Idx_out <= `regNOP;
                    reg2Idx_out <= `regNOP;
                    rdE_out     <= `writeEnable;
                    rdIdx_out   <= inst_in[11:7];
                    immData_out <= {inst_in[31:12], {12{1'b0}}};
                    instIdx_out <= `idAUIPC;
                    instType_out<= `typeValid;
                end
                `opJAL: begin                                       // JAL, J-type
                    instValid   <= `instValid;
                    reg1E_out   <= `readDisable;
                    reg2E_out   <= `readDisable;
                    reg1Idx_out <= `regNOP;
                    reg2Idx_out <= `regNOP;
                    rdE_out     <= `writeEnable;
                    rdIdx_out   <= inst_in[11:7];
                    immData_out <= {{12{inst_in[31]}}, inst_in[19:12],
                                    inst_in[20], inst_in[30:25], inst_in[24:21], 1'b0};
                    instIdx_out <= `idJAL;
                    instType_out<= `typeValid;
                end
                `opJALR: begin                                      // JALR, I-type
                    instValid   <= `instValid;
                    reg1E_out   <= `readEnable;
                    reg2E_out   <= `readDisable;
                    reg1Idx_out <= inst_in[19:15];
                    reg2Idx_out <= `regNOP;
                    rdE_out     <= `writeEnable;
                    rdIdx_out   <= inst_in[11:7];
                    immData_out <= {{20{inst_in[31]}}, inst_in[31:20]};
                    instIdx_out <= `idJALR;
                    instType_out<= `typeValid;
                end
                `opBranch: begin
                    instValid   <= `instValid;
                    reg1E_out   <= `readEnable;
                    reg2E_out   <= `readEnable;
                    reg1Idx_out <= inst_in[19:15];
                    reg2Idx_out <= inst_in[24:20];
                    rdE_out     <= `writeDisable;
                    rdIdx_out   <= `regNOP;
                    immData_out <= {{20{inst_in[31]}}, inst_in[7], inst_in[30:25], inst_in[11:8], 1'b0};
                    case (funct3)
                        3'b000: begin                                   // BEQ, B-type
                            instIdx_out     <= `idBEQ;
                            instType_out    <= `instValid;
                        end
                        3'b001: begin                                   // BNE, B-type
                            instIdx_out     <= `idBNE;
                            instType_out    <= `instValid;
                        end
                        3'b100: begin                                   // BLT, B-type
                            instIdx_out     <= `idBLT;
                            instType_out    <= `instValid;
                        end
                        3'b101: begin                                   // BGE, B-type
                            instIdx_out     <= `idBGE;
                            instType_out    <= `instValid;
                        end
                        3'b110: begin                                   // BLTU, B-type
                            instIdx_out     <= `idBLTU;
                            instType_out    <= `instValid;
                        end
                        3'b111: begin                                   // BGEU, B-type
                            instIdx_out     <= `idBGEU;
                            instType_out    <= `instValid;
                        end
                        default: begin
                            instValid       <= `instValid;
                            instIdx_out     <= `idNOP;
                            instType_out    <= `typeNOP;
                            rdE_out         <= `writeDisable;
                            rdIdx_out       <= `regNOP;
                            reg1E_out       <= `readDisable;
                            reg2E_out       <= `readDisable;
                            reg1Idx_out     <= `regNOP;
                            reg2Idx_out     <= `regNOP;
                            immData_out     <= `ZERO32;
                        end
                    endcase
                end
                `opLoad: begin
                    instValid   <= `instValid;
                    rdE_out     <= `writeEnable;
                    reg1E_out   <= `readEnable;
                    reg2E_out   <= `readDisable;
                    rdIdx_out   <= inst_in[11:7];
                    reg1Idx_out <= inst_in[19:15];
                    reg2Idx_out <= `regNOP;
                    immData_out <= {{20{inst_in[31]}}, inst_in[31:20]};
                    instType_out<= `typeValid;
                    case (funct3)
                        3'b000: begin                                   // LB, I-type
                            instIdx_out     <= `idLB;
                        end
                        3'b001: begin                                   // LH, I-type
                            instIdx_out     <= `idLH;
                        end
                        3'b010: begin                                   // LW, I-type
                            instIdx_out     <= `idLW;
                        end
                        3'b100: begin                                   // LBU, I-type
                            instIdx_out     <= `idLBU;
                        end
                        3'b101: begin                                   // LHU, I-type
                            instIdx_out     <= `idLHU;
                        end
                        default: begin
                            instIdx_out     <= `idNOP;
                            instType_out    <= `typeNOP;
                            instValid       <= `instInvalid;
                            rdE_out         <= `writeDisable;
                            reg1E_out       <= `readDisable;
                            reg2E_out       <= `readDisable;
                            rdIdx_out       <= `regNOP;
                            reg1Idx_out     <= `regNOP;
                            reg2Idx_out     <= `regNOP;
                            immData_out     <= `ZERO32;
                        end
                    endcase
                end
                `opStore: begin
                    instValid   <= `instValid;
                    rdE_out     <= `writeDisable;
                    reg1E_out   <= `readEnable;
                    reg2E_out   <= `readEnable;
                    rdIdx_out   <= `regNOP;
                    reg1Idx_out <= inst_in[19:15];
                    reg2Idx_out <= inst_in[24:20];
                    immData_out <= {{20{inst_in[31]}}, inst_in[31:25], inst_in[11:7]};
                    instType_out<= `typeValid;
                    case (funct3)
                        3'b000: begin                                   // SB, S-type
                            instIdx_out     <= `idSB;
                        end
                        3'b001: begin                                   // SH, S-type
                            instIdx_out     <= `idSH;
                        end
                        3'b010: begin                                   // SW, S-type
                            instIdx_out     <= `idSW;
                        end
                        default: begin
                            instIdx_out     <= `idNOP;
                            instType_out    <= `typeNOP;
                            instValid       <= `instInvalid;
                            rdE_out         <= `writeDisable;
                            reg1E_out       <= `readDisable;
                            reg2E_out       <= `readDisable;
                            rdIdx_out       <= `regNOP;
                            reg1Idx_out     <= `regNOP;
                            reg2Idx_out     <= `regNOP;
                            immData_out     <= `ZERO32;
                        end
                    endcase
                end
                `opRI: begin                                        // Reg-Imm
                    instValid   <= `instValid;
                    rdE_out     <= `writeEnable;
                    reg1E_out   <= `readEnable;
                    reg2E_out   <= `readDisable;
                    rdIdx_out   <= inst_in[11:7];
                    reg1Idx_out <= inst_in[19:15];
                    reg2Idx_out <= `regNOP;

                    case (funct3)
                        3'b000: begin                                   // ADDI, I-type
                            instIdx_out     <= `idADDI;
                            instType_out    <= `typeValid;
                            immData_out     <= {{20{inst_in[31]}}, inst_in[31:20]};
                        end
                        3'b010: begin                                   // SLTI, I-type
                            instIdx_out     <= `idSLTI;
                            instType_out    <= `typeValid;
                            immData_out     <= {{20{inst_in[31]}}, inst_in[31:20]};
                        end
                        3'b011: begin                                   // SLTIU, I_type
                            instIdx_out     <= `idSLTIU;
                            instType_out    <= `typeValid;
                            immData_out     <= {{20{inst_in[31]}}, inst_in[31:20]};
                        end
                        3'b100: begin                                   // XORI, I-type
                            instIdx_out     <= `idXORI;
                            instType_out    <= `typeValid;
                            immData_out     <= {{20{inst_in[31]}}, inst_in[31:20]};
                        end
                        3'b110: begin                                   // ORI, I-type
                            instIdx_out     <= `idORI;
                            instType_out    <= `typeValid;
                            immData_out     <= {{20{inst_in[31]}}, inst_in[31:20]};
                        end
                        3'b111: begin                                   // ANDI, I-type
                            instIdx_out     <= `idANDI;
                            instType_out    <= `typeValid;
                            immData_out     <= {{20{inst_in[31]}}, inst_in[31:20]};
                        end
                        3'b001: begin                                   // SLLI, I-type
                            instIdx_out     <= `idSLLI;
                            instType_out    <= `typeValid;
                            immData_out     <= inst_in[24:20];
                        end
                        3'b101: begin
                            if (funct7[5] == 1'b0) begin                // SRLI, I-type
                                instIdx_out <= `idSRLI;
                                instType_out<= `typeValid;
                                immData_out <= inst_in[24:20];
                            end else if (funct7[5] == 1'b1) begin       // SRAI, I-type
                                instIdx_out <= `idSRAI;
                                instType_out<= `typeValid;
                                immData_out <= inst_in[24:20];
                            end else begin
                                instIdx_out <= `idNOP;
                                instType_out<= `typeNOP;
                                immData_out <= `ZERO32;
                            end
                        end
                        default : begin
                            instIdx_out     <= `idNOP;
                            instType_out    <= `typeNOP;
                            instValid       <= `instInvalid;
                            rdE_out         <= `writeDisable;
                            reg1E_out       <= `readDisable;
                            reg2E_out       <= `readDisable;
                            rdIdx_out       <= `regNOP;
                            reg1Idx_out     <= `regNOP;
                            reg2Idx_out     <= `regNOP;
                            immData_out     <= `ZERO32;
                        end
                    endcase
                end
                `opRR: begin                                        // Reg-Reg
                    instValid   <= `instValid;
                    rdE_out     <= `writeEnable;
                    reg1E_out   <= `readEnable;
                    reg2E_out   <= `readEnable;
                    rdIdx_out   <= inst_in[11:7];
                    reg1Idx_out <= inst_in[19:15];
                    reg2Idx_out <= inst_in[24:20];
                    immData_out <= `ZERO32;

                    case (funct3)
                        3'b000: begin
                            if (funct7[5] == 1'b0) begin                // ADD, R-type
                                instIdx_out <= `idADD;
                                instType_out<= `typeValid;
                            end else if (funct7[5] == 1'b1) begin       // SUB, R-type
                                instIdx_out <= `idSUB;
                                instType_out<= `typeValid;
                            end else begin
                                instIdx_out <= `idNOP;
                                instType_out<= `typeNOP;
                            end
                        end
                        3'b010: begin                                   // SLT, R-type
                            instIdx_out     <= `idSLT;
                            instType_out    <= `typeValid;
                        end
                        3'b011: begin                                   // SLTU, R-type
                            instIdx_out     <= `idSLTU;
                            instType_out    <= `typeValid;
                        end
                        3'b100: begin                                   // XOR, R-type
                            instIdx_out     <= `idXOR;
                            instType_out    <= `typeValid;
                        end
                        3'b110: begin                                   // OR, R-type
                            instIdx_out     <= `idOR;
                            instType_out    <= `typeValid;
                        end
                        3'b111: begin                                   // AND, R-type
                            instIdx_out     <= `idAND;
                            instType_out    <= `typeValid;
                        end
                        3'b001: begin                                   // SLL, R-type
                            instIdx_out     <= `idSLL;
                            instType_out    <= `typeValid;
                        end
                        3'b101: begin
                            if (funct7[5] == 1'b0) begin                // SRL, R-type
                                instIdx_out <= `idSRL;
                                instType_out<= `typeValid;
                            end else if (funct7[5] == 1'b1) begin       // SRA, R-type
                                instIdx_out <= `idSRA;
                                instType_out<= `typeValid;
                            end else begin
                                instIdx_out <= `idNOP;
                                instType_out<= `typeNOP;
                            end
                        end
                    endcase
                end

                default : begin
                    instValid       <= `instValid;
                    instIdx_out     <= `idNOP;
                    instType_out    <= `typeNOP;
                    rdE_out         <= `writeDisable;
                    rdIdx_out       <= `regNOP;
                    reg1E_out       <= `readDisable;
                    reg2E_out       <= `readDisable;
                    reg1Idx_out     <= `regNOP;
                    reg2Idx_out     <= `regNOP;
                    immData_out     <= `ZERO32;
                end
            endcase
        end
    end

    // handle data hazard caused by LOAD
    reg reg1Stall, reg2Stall;
    wire Loading;

    assign Loading = instIdxEx_in == `idLB || instIdxEx_in == `idLH || instIdxEx_in == `idLW ||
        instIdxEx_in == `idLBU || instIdxEx_in == `idLHU || instIdxEx_in == `idSB ||
        instIdxEx_in == `idSH || instIdxEx_in == `idSW;

    // ----------------- DECODE FINISH ----------------
    always @ (*) begin
        reg1Stall <= `NoStall;
        if (rst_in == `rstEnable) begin
            rs1Data_out <= `ZERO32;
        end else if (Loading == 1'b1 && reg1E_out == `readEnable
            && EX_rdIdx_in && reg1Idx_out) begin
            rs1Data_out <= `ZERO32;
            reg1Stall <= `Stall;
        end else if (reg1E_out == `readEnable && EX_rdE_in == `writeEnable &&
            EX_rdIdx_in == reg1Idx_out) begin
            rs1Data_out <= EX_rdData_in;
        end else if (reg1E_out == `readEnable && MEM0_rdE_in == `writeEnable &&
            MEM0_rdIdx_in == reg1Idx_out) begin
            rs1Data_out <= MEM0_rdData_in;
        end else if (reg1E_out == `readEnable) begin
            rs1Data_out <= reg1Data_in;
        end else begin
            rs1Data_out <= `ZERO32;
        end
    end

    always @ (*) begin
        reg2Stall <= `NoStall;
        if (rst_in == `rstEnable) begin
            rs2Data_out <= `ZERO32;
        end else if (Loading == 1'b1 && reg2E_out == `readEnable
            && EX_rdIdx_in && reg2Idx_out) begin
            rs2Data_out <= `ZERO32;
            reg2Stall <= `Stall;
        end else if (reg2E_out == `readEnable && EX_rdE_in == `writeEnable &&
            EX_rdIdx_in == reg2Idx_out) begin
            rs2Data_out <= EX_rdData_in;
        end else if (reg2E_out == `readEnable && MEM0_rdE_in == `writeEnable &&
            MEM0_rdIdx_in== reg2Idx_out) begin
            rs2Data_out <= MEM0_rdData_in;
        end else if (reg2E_out == `readEnable) begin
            rs2Data_out <= reg2Data_in;
        end else begin
            rs2Data_out <= `ZERO32;
        end
    end

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            pc_out <= `ZERO32;
        end else begin
            pc_out <= pc_in;
        end
    end

    assign idStall_out = reg1Stall | reg2Stall;
endmodule : ID