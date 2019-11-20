`include "defines.vh"

module EX_MEM(
    input wire                  clk_in,
    input wire                  rst_in,

    // stall or not
    input wire[`stallRange]     stall_in,

    // input from EX
    input wire                  rdE_in,
    input wire[`regIdxRange]    rdIdx_in,
    input wire[`dataRange]      rdData_in,

    // output to MEM
    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,
    output reg[`dataRange]      rdData_out
);

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            rdE_out     <= `writeDisable;
            rdIdx_out   <= `regNOP;
            rdData_out  <= `ZERO32;
        end else if (stall_in[3] == `Stall && stall_in[4] == `NoStall) begin
            rdE_out     <= `writeDisable;
            rdIdx_out   <= `regNOP;
            rdData_out  <= `ZERO32;
        end else if (stall_in[3] == `NoStall) begin
            rdE_out     <= rdE_in;
            rdIdx_out   <= rdIdx_in;
            rdData_out  <= rdData_in;
        end else begin
            // do nothing
        end

    end
endmodule : EX_MEM