`include "defines.vh"

module IF_ID(
    input wire                  clk_in,
    input wire                  rst_in,

    // input from pc & RAM
    input wire[`addrRange]      pc_in,
    input wire[`instRange]      inst_in,

    // output to ID
    output reg[`addrRange]      pc_out,
    output reg[`instRange]      inst_out
);

    always @ (posedge clk_in) begin
        if (rst == `rstEnable) begin
            pc_out <= `ZERO32;
            inst_out <= `ZERO32;
        end else begin
            pc_out <= pc_in;
            inst_out <= inst_in;
        end
    end
endmodule : IF_ID