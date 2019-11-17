`include "defines.vh"

module ID(
    input wire                  rst_in,

    input wire[`addrRange]      pc_in,
    input wire[`instRange]      inst_in,

    input wire[`dataRange]      reg1Data_in,
    input wire[`dataRange]      reg2Data_in,

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

    reg[6:0] opcode = inst_in[6:0];
    reg[2:0] funct3 = inst_in[14:12];
    reg[6:0] funct7 = inst_in[31:25];

    reg[`dataRange] imm;
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
            imm             <= `ZERO32;
        end else begin
            case (opcode)
                `opRI : begin                                       // Reg-Imm
                    instValid   <= `instValid;
                    rdE_out     <= `writeEnable;
                    reg1E_out   <= `readEnable;
                    reg2E_out   <= `readDisable;
                    rdIdx_out   <= inst_in[11:7];
                    reg1Idx_out <= inst_in[19:15];
                    reg2Idx_out <= `regNOP;

                    case (funct3)
                        1'b110: begin                                   // ORI
                            instIdx_out     <= `idORI;
                            instType_out    <= `typeLogic;
                            imm             <= inst_in[31:20];
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

                default : begin
                end
            endcase
        end
    end

    // ----------------- DECODE FINISH ----------------
    always @ (*) begin
        if (rst_in == `rstEnable) begin
            rs1Data_out <= `ZERO32;
        end else if (reg1E_out == `readEnable) begin
            rs1Data_out <= reg1Data_in;
        end else if (reg1E_out == `readDisable) begin
            rs1Data_out <= imm;  // Todo: what? <= imm?
        end else begin
            rs1Data_out <= `ZERO32;
        end
    end

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            rs2Data_out <= `ZERO32;
        end else if (reg2E_out == `readEnable) begin
            rs2Data_out <= reg2Data_in;
        end else if (reg2E_out == `readDisable) begin
            rs2Data_out <= imm;  // Todo: what? <= imm?
        end else begin
            rs2Data_out <= `ZERO32;
        end
    end

endmodule : ID