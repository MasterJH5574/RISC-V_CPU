`include "defines.vh"

module IF(
    input wire                  rst_in,

    // input from PC
    input wire[`addrRange]      pc_in,

    // clock count for IF
    input wire[`stallCntRange]  cnt_in,
    output reg[`stallCntRange]  cnt_out,

    // output to IF_ID
    output reg[`addrRange]      pc_out,
    output reg[`instRange]      inst_out,

    // stall request
    output reg                  ifStall_out
);

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            pc_out      <= `ZERO32;
            inst_out    <= `ZERO32;
            cnt_out     <= 1'b0;
            ifStall_out <= `NoStall;
        end else begin
            pc_out      <= pc_in;
            inst_out    <= `ZERO32; // Todo: modify after memory control
            cnt_out     <= 1'b0;    // Todo: modify after memory control
            ifStall_out <= `NoStall;
        end
    end
endmodule : IF