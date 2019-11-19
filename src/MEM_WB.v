`include "defines.vh"

module MEM_WB(
    input wire                  clk_in,
    input wire                  rst_in,

    // input from MEM
    input wire                  rdE_in,
    input wire[`regIdxRange]    rdIdx_in,
    input wire[`dataRange]      rdData_in,

    // output to WB
    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,
    output reg[`dataRange]      rdData_out
);


    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            rdE_out     <= `writeDisable;
            rdIdx_out   <= `regNOP;
            rdData_out  <= `ZERO32;
        end else begin
            rdE_out     <= rdE_in;
            rdIdx_out   <= rdIdx_in;
            rdData_out  <= rdData_in;
        end
    end
endmodule : MEM_WB