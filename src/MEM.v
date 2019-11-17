`include "defines.vh"

module MEM(
    input wire                  rst_in,

    // input from EX_MEM
    input reg                   rdE_in,
    input reg[`regIdxRange]     rdIdx_in,
    input reg[`dataRange]       rdData_in,

    // output to MEM_WB
    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,
    output reg[`dataRange]      rdData_out

);

    always @ (*) begin
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

endmodule : MEM