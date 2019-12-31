`include "defines.vh"

module IF(
    input wire                  clk_in,
    input wire                  rst_in,
    input wire                  rdy_in,

    // input from PC
//    input wire[`addrRange]      pc_in,

    // stall or not
    input wire[`stallRange]     stall_in,

    // input from EX for pc jump
    input wire                  pcJump_in,
    input wire[`addrRange]      pcTarget_in,

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
    output reg[`addrRange]      IF_pc_out,
    output reg[`instRange]      inst_out

    // stall request
//    output reg                  ifStall_out
);

    reg[`addrRange] PC_pc;

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            PC_pc <= `ZERO32;
        end else if (rdy_in == 1 && stall_in[0] == `NoStall) begin
            if (pcJump_in == `Jump) begin
                PC_pc <= pcTarget_in;
            end else begin
                PC_pc <= PC_pc + `PCSTEP;
            end
        end
    end

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            instE_out       <= `Disable;
            IF_pc_out       <= `ZERO32;
            inst_out        <= `ZERO32;
//            ifStall_out     <= `NoStall;
            ICache_out      <= `Disable;
            ICacheAddr_out  <= `ZERO32;
        end else if (pcJump_in == `Jump || MEM_MCAccess_in == `Enable) begin
            instE_out       <= `Disable;
            IF_pc_out       <= `ZERO32;
            inst_out        <= `ZERO32;
//            ifStall_out     <= `NoStall;
            ICache_out      <= `Disable;
            ICacheAddr_out  <= `ZERO32;
        end else if (instE_in == `writeEnable) begin
            instE_out       <= `Enable;
            IF_pc_out       <= PC_pc;
            inst_out        <= inst_in;
//            ifStall_out     <= `NoStall;
            ICache_out      <= `Enable;
            ICacheAddr_out  <= PC_pc;
        end else begin
            instE_out       <= `Disable;
            IF_pc_out       <= `ZERO32;
            inst_out        <= `ZERO32;
//            ifStall_out     <= `Stall;
            ICache_out      <= `Enable;
            ICacheAddr_out  <= PC_pc;
        end
    end
endmodule : IF