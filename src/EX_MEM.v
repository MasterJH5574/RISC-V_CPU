`include "defines.vh"

module EX_MEM(
    input wire                  clk_in,
    input wire                  rst_in,

    // stall or not
    input wire[`stallRange]     stall_in,

    // input from EX
    input wire[`instIdxRange]   instIdx_in,
    input wire[`addrRange]      memAddr_in,
    input wire[`dataRange]      valStore_in,

    input wire                  rdE_in,
    input wire[`regIdxRange]    rdIdx_in,
    input wire[`dataRange]      rdData_in,

    // output to MEM
    output reg[`instIdxRange]   instIdx_out,
    output reg[`addrRange]      memAddr_out,
    output reg[`dataRange]      valStore_out,

    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,
    output reg[`dataRange]      rdData_out
);

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            instIdx_out <= `idNOP;
            memAddr_out <= `ZERO32;
            valStore_out<= `ZERO32;
            rdE_out     <= `writeDisable;
            rdIdx_out   <= `regNOP;
            rdData_out  <= `ZERO32;
        end else if (stall_in[3] == `Stall && stall_in[4] == `NoStall) begin
            instIdx_out <= `idNOP;
            memAddr_out <= `ZERO32;
            valStore_out<= `ZERO32;
            rdE_out     <= `writeDisable;
            rdIdx_out   <= `regNOP;
            rdData_out  <= `ZERO32;
        end else if (stall_in[3] == `NoStall) begin
            instIdx_out <= instIdx_in;
            memAddr_out <= memAddr_in;
            valStore_out<= valStore_in;
            rdE_out     <= rdE_in;
            rdIdx_out   <= rdIdx_in;
            rdData_out  <= rdData_in;
        end else begin
            // do nothing
        end

    end
endmodule : EX_MEM