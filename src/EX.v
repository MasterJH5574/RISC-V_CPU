`include "defines.vh"

module EX(
    input wire                  rst_in,

    // input from ID_EX
    input wire[`addrRange]      pc_in,

    input wire                  rdE_in,
    input wire[`regIdxRange]    rdIdx_in,

    input wire[`instIdxRange]   instIdx_in,
    input wire[`instTypeRange]  instType_in,

    input wire[`dataRange]      rs1Data_in,
    input wire[`dataRange]      rs2Data_in,
    input wire[`dataRange]      immData_in,

    // output to EX_MEM
    output reg[`instIdxRange]   instIdx_out,           // also output to ID
    output reg[`addrRange]      memAddr_out,
    output reg[`dataRange]      valStore_out,

    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,
    output reg[`dataRange]      rdData_out,

    // output to PC for jump and branch
    output reg                  pcJump_out,
    output reg[`addrRange]      pcTarget_out
);

    reg[`dataRange] res;


    always @ (*) begin
        if (rst_in == `rstEnable) begin
            res             <= `ZERO32;
            pcJump_out      <= `NoJump;
            pcTarget_out    <= `ZERO32;
        end else begin
            case (rdIdx_in)
                `idLUI: begin                               // LUI
                    res             <= rs1Data_in;
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
                `idAUIPC: begin                             // AUIPC
                    res             <= pc_in + immData_in;
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
                `idJAL: begin                               // JAL
                    res             <= pc_in + `PCSTEP;
                    pcJump_out      <= `Jump;
                    pcTarget_out    <= pc_in + immData_in;
                end
                `idJALR: begin                              // JALR
                    res             <= pc_in + `PCSTEP;
                    pcJump_out      <= `Jump;
                    pcTarget_out    <= (rs1Data_in + immData_in) & 32'hFFFFFFFE;
                end
                `idBEQ: begin                               // BEQ
                    res             <= `ZERO32;
                    if (rs1Data_in == rs2Data_in) begin
                        pcJump_out  <= `Jump;
                        pcTarget_out<= pc_in + immData_in;
                    end else begin
                        pcJump_out  <= `NoJump;
                        pcTarget_out<= `ZERO32;
                    end
                end
                `idBNE: begin                               // BNE
                    res             <= `ZERO32;
                    if (rs1Data_in != rs2Data_in) begin
                        pcJump_out  <= `Jump;
                        pcTarget_out<= pc_in + immData_in;
                    end else begin
                        pcJump_out  <= `NoJump;
                        pcTarget_out<= `ZERO32;
                    end
                end
                `idBLT: begin                               // BLT
                    res             <= `ZERO32;
                    if ($signed(rs1Data_in) < $signed(rs2Data_in)) begin
                        pcJump_out  <= `Jump;
                        pcTarget_out<= pc_in + immData_in;
                    end else begin
                        pcJump_out  <= `NoJump;
                        pcTarget_out<= `ZERO32;
                    end
                end
                `idBGE: begin                               // BGE
                    res             <= `ZERO32;
                    if ($signed(rs1Data_in) >= $signed(rs2Data_in)) begin
                        pcJump_out  <= `Jump;
                        pcTarget_out<= pc_in + immData_in;
                    end else begin
                        pcJump_out  <= `NoJump;
                        pcTarget_out<= `ZERO32;
                    end
                end
                `idBLTU: begin                              // BLTU
                    res             <= `ZERO32;
                    if (rs1Data_in < rs2Data_in) begin
                        pcJump_out  <= `Jump;
                        pcTarget_out<= pc_in + immData_in;
                    end else begin
                        pcJump_out  <= `NoJump;
                        pcTarget_out<= `ZERO32;
                    end
                end
                `idBGEU: begin                              // BGEU
                    res             <= `ZERO32;
                    if (rs1Data_in < rs2Data_in) begin
                        pcJump_out  <= `Jump;
                        pcTarget_out<= pc_in + immData_in;
                    end else begin
                        pcJump_out  <= `NoJump;
                        pcTarget_out<= `ZERO32;
                    end
                end
                `idSLT: begin                               // SLTI, SLT
                    if ($signed(rs1Data_in) < $signed(rs2Data_in)) begin
                        res <= 1'b1;
                    end else begin
                        res <= 1'b0;
                    end
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
                `idSLTU: begin                              // SLTIU, SLTU
                    if (rs1Data_in < rs2Data_in) begin
                        res         <= 1'b1;
                    end else begin
                        res         <= 1'b0;
                    end
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
                `idXOR: begin                               // XORI, XOR
                    res             <= rs1Data_in ^ rs2Data_in;
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
                `idOR: begin                                // ORI, OR
                    res             <= rs1Data_in | rs2Data_in;
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
                `idAND: begin                               // ANDI, AND
                    res             <= rs1Data_in & rs2Data_in;
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
                `idADD: begin                               // ADDI, ADD
                    res             <= rs1Data_in + rs2Data_in;
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
                `idSUB: begin                               // SUB
                    res             <= rs1Data_in - rs2Data_in;
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
                `idSLL: begin                               // SLLI, SLL
                    res             <= rs1Data_in << rs2Data_in[4:0];
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
                `idSRL: begin                               // SRLI, SRL
                    res             <= rs1Data_in >> rs2Data_in[4:0];
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
                `idSRA: begin                               // SRAI, SRA
                    res             <= rs1Data_in >>> rs2Data_in[4:0];
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
                default : begin                             // include LB, LH, LW, LBU, LHU,
                    res             <= `ZERO32;             // SB, SH, SW
                    pcJump_out      <= `NoJump;
                    pcTarget_out    <= `ZERO32;
                end
            endcase
        end

    end

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            instIdx_out <= `idNOP;
            memAddr_out <= `ZERO32;
            valStore_out<= `ZERO32;
            rdE_out     <= `writeDisable;
            rdIdx_out   <= `regNOP;
            rdData_out  <= `ZERO32;
        end else if (instType_in == `typeValid) begin
            instIdx_out <= instIdx_in;
            memAddr_out <= rs1Data_in + immData_in;
            valStore_out<= rs2Data_in;
            rdE_out     <= rdE_in;
            rdIdx_out   <= rdIdx_in;
            rdData_out  <= res;
        end
    end

endmodule : EX