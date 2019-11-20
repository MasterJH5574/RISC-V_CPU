`include "defines.vh"

module ID_EX(
    input wire                  clk_in,
    input wire                  rst_in,

    // stall or not
    input wire[`stallRange]     stall_in,

    // pc change target for Jump and Branch
    input wire                  pcJump_in,

    // input from ID
    input wire[`addrRange]      pc_in,

    input wire                  rdE_in,
    input wire[`regIdxRange]    rdIdx_in,

    input wire[`instIdxRange]   instIdx_in,
    input wire[`instTypeRange]  instType_in,

    input wire[`dataRange]      rs1Data_in,
    input wire[`dataRange]      rs2Data_in,
    input wire[`dataRange]      immData_in,

    // output to EX
    output reg[`addrRange]      pc_out,

    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,

    output reg[`instIdxRange]   instIdx_out,
    output reg[`instTypeRange]  instType_out,

    output reg[`dataRange]      rs1Data_out,
    output reg[`dataRange]      rs2Data_out,
    output reg[`dataRange]      immData_out

);

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            pc_out          <= `ZERO32;
            instIdx_out     <= `idNOP;
            instType_out    <= `typeNOP;
            rs1Data_out     <= `ZERO32;
            rs2Data_out     <= `ZERO32;
            immData_out     <= `ZERO32;
            rdE_out         <= `writeDisable;
            rdIdx_out       <= `regNOP;
        end else if (pcJump_in == `Jump) begin
            pc_out          <= `ZERO32;
            instIdx_out     <= `idNOP;
            instType_out    <= `typeNOP;
            rs1Data_out     <= `ZERO32;
            rs2Data_out     <= `ZERO32;
            immData_out     <= `ZERO32;
            rdE_out         <= `writeDisable;
            rdIdx_out       <= `regNOP;
        end else if (stall_in[2] == `Stall && stall_in[3] == `NoStall) begin
            pc_out          <= `ZERO32;
            instIdx_out     <= `idNOP;
            instType_out    <= `typeNOP;
            rs1Data_out     <= `ZERO32;
            rs2Data_out     <= `ZERO32;
            immData_out     <= `ZERO32;
            rdE_out         <= `writeDisable;
            rdIdx_out       <= `regNOP;
        end else if (stall_in[2] == `NoStall) begin
            pc_out          <= pc_in;
            instIdx_out     <= instIdx_in;
            instType_out    <= instType_in;
            rs1Data_out     <= rs1Data_in;
            rs2Data_out     <= rs2Data_in;
            immData_out     <= immData_in;
            rdE_out         <= rdE_in;
            rdIdx_out       <= rdIdx_in;
        end else begin
            // do nothing
        end
    end

endmodule : ID_EX