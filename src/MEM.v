`include "defines.vh"

module MEM(
    input wire                  rst_in,

    // input from EX_MEM
    input wire[`instIdxRange]   instIdx_in,
    input wire                  rdE_in,
    input wire[`regIdxRange]    rdIdx_in,
    input wire[`dataRange]      rdData_in,

    // output to MEM_WB
    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,
    output reg[`dataRange]      rdData_out,

    // stall request
    output reg                  memStall_out
);

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            rdE_out     <= `writeDisable;
            rdIdx_out   <= `regNOP;
            rdData_out  <= `ZERO32;
            memStall_out <= `NoStall;
        end else begin
            rdE_out     <= rdE_in;
            rdIdx_out   <= rdIdx_in;
            rdData_out  <= rdData_in;
            memStall_out <= `NoStall;
        end
    end

endmodule : MEM