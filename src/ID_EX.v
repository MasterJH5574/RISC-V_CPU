`include "defines.vh"

module ID_EX(
    input wire                  clk_in,
    input wire                  rst_in,

    // input from ID
    input wire                   rdE_in,
    input wire[`regIdxRange]     rdIdx_in,

    input wire[`instIdxRange]    instIdx_in,
    input wire[`instTypeRange]   instType_in,

    input wire[`dataRange]       rs1Data_in,
    input wire[`dataRange]       rs2Data_in,

    // output to EX
    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,

    output reg[`instIdxRange]   instIdx_out,
    output reg[`instTypeRange]  instType_out,

    output reg[`dataRange]      rs1Data_out,
    output reg[`dataRange]      rs2Data_out

);

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            instIdx_out     <= `idNOP;
            instType_out    <= `typeNOP;
            rs1Data_out     <= `ZERO32;
            rs2Data_out     <= `ZERO32;
            rdE_out         <= `writeDisable;
            rdIdx_out       <= `regNOP;
        end else begin
            instIdx_out     <= instIdx_in;
            instType_out    <= instType_in;
            rs1Data_out     <= rs1Data_in;
            rs2Data_out     <= rs2Data_in;
            rdE_out         <= rdE_in;
            rdIdx_out       <= rdIdx_in;
        end
    end

endmodule : ID_EX