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

    // output to RegFile
    output reg                  reg1E_out,
    output reg                  reg2E_out,
    output reg[`regIdxRange]    reg1Idx_out,
    output reg[`regIdxRange]    reg2Idx_out,

    // output to ID_EX
    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,

    output reg[`instIdxRange]   instIdx_out,
    output reg[`instTypeRange]  instType_out,

    output reg[`dataRange]      rs1Data_out,
    output reg[`dataRange]      rs2Data_out

);

    wire[6:0] opcode = inst_in[6:0];
    wire[2:0] funct3 = inst_in[14:12];
    wire[6:0] funct7 = inst_in[31:25];

    reg[`dataRange] imm;
    reg instValid;              // Todo: usage of instValid?

    // ---------------- DECODE -------------------
    // Todo: Remember to decode the IMMEDIATE
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
            imm             <= `ZERO32;
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
                    imm         <= {inst_in[31:12], {12{1'b0}}};
                    instIdx_out <= `idLUI;
                    instType_out<= `typeOther;
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
                        3'b010: begin                                   // SLTI, I-type
                            instIdx_out     <= `idSLT;
                            instType_out    <= `typeOther;
                            imm             <= {{20{inst_in[31]}}, inst_in[31:20]};
                        end
                        3'b011: begin                                   // SLTIU, I_type
                            instIdx_out     <= `idSLTU;
                            instType_out    <= `typeOther;
                            imm             <= {{20{inst_in[31]}}, inst_in[31:20]};
                        end
                        3'b100: begin                                   // XORI, I-type
                            instIdx_out     <= `idXOR;
                            instType_out    <= `typeLogic;
                            imm             <= {{20{inst_in[31]}}, inst_in[31:20]};
                        end
                        3'b110: begin                                   // ORI, I-type
                            instIdx_out     <= `idOR;
                            instType_out    <= `typeLogic;
                            imm             <= {{20{inst_in[31]}}, inst_in[31:20]};
                        end
                        3'b111: begin                                   // ANDI, I-type
                            instIdx_out     <= `idAND;
                            instType_out    <= `typeLogic;
                            imm             <= {{20{inst_in[31]}}, inst_in[31:20]};
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
                            imm             <= `ZERO32;
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
                    imm         <= `ZERO32;

                    case (funct3)
                        3'b010: begin                                   // SLT, R-type
                            instIdx_out     <= `idSLT;
                            instType_out    <= `typeOther;
                        end
                        3'b011: begin                                   // SLTU, R-type
                            instIdx_out     <= `idSLTU;
                            instType_out    <= `typeOther;
                        end
                        3'b100: begin                                   // XOR, R-type
                            instIdx_out     <= `idXOR;
                            instType_out    <= `typeLogic;
                        end
                        3'b110: begin                                   // OR, R-type
                            instIdx_out     <= `idOR;
                            instType_out    <= `typeLogic;
                        end
                        3'b111: begin                                   // AND, R-type
                            instIdx_out     <= `idAND;
                            instType_out    <= `typeLogic;
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
                    imm             <= `ZERO32;
                end
            endcase
        end
    end

    // ----------------- DECODE FINISH ----------------
    always @ (*) begin
        if (rst_in == `rstEnable) begin
            rs1Data_out <= `ZERO32;
        end else if (reg1E_out == `readEnable && EX_rdE_in == `writeEnable &&
            EX_rdIdx_in == reg1Idx_out) begin
            rs1Data_out <= EX_rdData_in;
        end else if (reg1E_out == `readEnable && MEM0_rdE_in == `writeEnable &&
            MEM0_rdIdx_in == reg1Idx_out) begin
            rs1Data_out <= MEM0_rdData_in;
        end else if (reg1E_out == `readEnable) begin
            rs1Data_out <= reg1Data_in;
        end else if (reg1E_out == `readDisable) begin
            rs1Data_out <= imm;  // Todo: why "rs1Data_out <= imm"? For LUI?
        end else begin
            rs1Data_out <= `ZERO32;
        end
    end

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            rs2Data_out <= `ZERO32;
        end else if (reg2E_out == `readEnable && EX_rdE_in == `writeEnable &&
            EX_rdIdx_in == reg2Idx_out) begin
            rs2Data_out <= EX_rdData_in;
        end else if (reg2E_out == `readEnable && MEM0_rdE_in == `writeEnable &&
            MEM0_rdIdx_in== reg2Idx_out) begin
            rs2Data_out <= MEM0_rdData_in;
        end else if (reg2E_out == `readEnable) begin
            rs2Data_out <= reg2Data_in;
        end else if (reg2E_out == `readDisable) begin
            rs2Data_out <= imm;  // Todo: why "rs2Data_oujt <= imm"?
        end else begin
            rs2Data_out <= `ZERO32;
        end
    end

endmodule : ID