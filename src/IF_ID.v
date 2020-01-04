`include "defines.vh"

module IF_ID(
    input wire                  clk_in,
    input wire                  rst_in,
    input wire                  rdy_in,

    // stall or not
    input wire[`stallRange]     stall_in,

    // pc change target for Jump and Branch
    input wire                  pcJump_in,

    // input from IF
    input wire                  instE_in,
    input wire[`addrRange]      pc_in,
    input wire[`instRange]      inst_in,
    input wire                  IF_ID_taken_in,
    input wire[`addrRange]      IF_ID_pcPred_in,

    // output to ID
    output reg[`addrRange]      IF_ID_pc_out,
    output reg[`instRange]      inst_out,
    output reg                  IF_ID_taken_out,
    output reg[`addrRange]      IF_ID_pcPred_out
);

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            IF_ID_pc_out<= `ZERO32;
            inst_out    <= `ZERO32;
            IF_ID_taken_out     <= 0;
            IF_ID_pcPred_out    <= `ZERO32;
        end else if (rdy_in == 1) begin
            if (pcJump_in == `Jump) begin
                IF_ID_pc_out<= `ZERO32;
                inst_out    <= `ZERO32;
                IF_ID_taken_out     <= 0;
                IF_ID_pcPred_out    <= `ZERO32;
            end else if (stall_in[2] == `Stall) begin
                // do nothing, keep the output signal
            end else if (instE_in == `Disable) begin
                IF_ID_pc_out<= `ZERO32;
                inst_out    <= `ZERO32;
                IF_ID_taken_out     <= 0;
                IF_ID_pcPred_out    <= `ZERO32;
            end else begin // else if (stall_in[2] == `NoStall) begin
                IF_ID_pc_out<= pc_in;
                inst_out    <= inst_in;
                IF_ID_taken_out     <= IF_ID_taken_in;
                IF_ID_pcPred_out    <= IF_ID_pcPred_in;
            end
        end
    end
endmodule : IF_ID