`include "defines.vh"

module IF(
    input wire                  clk_in,
    input wire                  rst_in,
    input wire                  rdy_in,

    // input from PC
    input wire[`addrRange]      pc_in,

    // input from EX for pc jump
    input wire                  pcJump_in,

    // input from MEM, MEM is accessing MC
    input wire                  MEM_MCAccess_in,

    // input from I-cache
    input wire                  instE_in,
    input wire[`instRange]      inst_in,

    // output to I-cache
    output reg                  ICache_out,
    output reg[17:0]            ICacheAddr_out,

    // output to IF_ID
    output reg                  instE_out,
    output reg[`addrRange]      pc_out,
    output reg[`instRange]      inst_out,

    // stall request
    output reg                  ifStall_out
);

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            instE_out       <= `Disable;
            pc_out          <= `ZERO32;
            inst_out        <= `ZERO32;
            ifStall_out     <= `NoStall;
            ICache_out      <= `Disable;
            ICacheAddr_out  <= `ZERO32;
        end else if (pcJump_in == `Jump || MEM_MCAccess_in == `Enable) begin
            instE_out       <= `Disable;
            pc_out          <= `ZERO32;
            inst_out        <= `ZERO32;
            ifStall_out     <= `NoStall;
            ICache_out      <= `Disable;
            ICacheAddr_out  <= `ZERO32;
        end else if (instE_in == `writeEnable) begin
            instE_out       <= `Enable;
            pc_out          <= pc_in;
            inst_out        <= inst_in;
            ifStall_out     <= `NoStall;
            ICache_out      <= `Enable;
            ICacheAddr_out  <= pc_in;
        end else begin
            instE_out       <= `Disable;
            pc_out          <= `ZERO32;
            inst_out        <= `ZERO32;
            ifStall_out     <= `Stall;
            ICache_out      <= `Enable;
            ICacheAddr_out  <= pc_in;
        end
    end
endmodule : IF