`include "defines.vh"

module IF(
    input wire                  rst_in,

    // input from PC
    input wire[`addrRange]      pc_in,

    // input from EX for pc jump
    input wire                  pcJump_in,

    // input from MEM, MEM is accessing MC
    input wire                  MEM_MCAccess_in,

    // input from Memory Controller
    input wire                  MC_busyIF_in,
    input wire                  MC_busyMEM_in,
    input wire                  instE_in,
    input wire[`instRange]      inst_in,

    // output to Memory Controller
    output reg                  MCE_out,
    output reg[`addrRange]      MCAddr_out,

    // output to IF_ID
    output reg                  instE_out,
    output reg[`addrRange]      pc_out,
    output reg[`instRange]      inst_out,

    // stall request
    output reg                  ifStall_out
);

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            MCE_out     <= `Disable;
            MCAddr_out  <= `ZERO32;
            instE_out   <= `Disable;
            pc_out      <= `ZERO32;
            inst_out    <= `ZERO32;
            ifStall_out <= `NoStall;
        end else if (pcJump_in == `Jump) begin
            MCE_out     <= `Disable;
            MCAddr_out  <= `ZERO32;
            instE_out   <= `Disable;
            pc_out      <= `ZERO32;
            inst_out    <= `ZERO32;
            ifStall_out <= `NoStall;
        end else if (instE_in == `writeEnable) begin
            MCE_out     <= `Disable;
            MCAddr_out  <= `ZERO32;
            instE_out   <= `Enable;
            pc_out      <= pc_in;
            inst_out    <= inst_in;
            ifStall_out <= `NoStall;
        end else if (MEM_MCAccess_in == `Enable) begin
            MCE_out     <= `Disable;
            MCAddr_out  <= `ZERO32;
            instE_out   <= `Disable;
            pc_out      <= `ZERO32;
            inst_out    <= `ZERO32;
            ifStall_out <= `Stall;
        end else if (MEM_MCAccess_in == `Disable && MC_busyMEM_in == `Busy) begin
            MCE_out     <= `Disable;
            MCAddr_out  <= `ZERO32;
            instE_out   <= `Disable;
            pc_out      <= `ZERO32;
            inst_out    <= `ZERO32;
            ifStall_out <= `NoStall;
        end else begin
            MCE_out     <= `Enable;
            MCAddr_out  <= pc_in;
            instE_out   <= `Disable;
            pc_out      <= `ZERO32;
            inst_out    <= `ZERO32;
            ifStall_out <= `Stall;
        end
    end
endmodule : IF