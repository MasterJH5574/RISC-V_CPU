`include "defines.vh"

module IF_ID(
    input wire                  clk_in,
    input wire                  rst_in,

    // stall or not
    input wire[`stallRange]     stall_in,

    // pc change target for Jump and Branch
    input wire                  pcJump_in,

    // input from IF
    input wire                  instE_in,
    input wire[`addrRange]      pc_in,
    input wire[`instRange]      inst_in,

    // output to ID
    output reg[`addrRange]      pc_out,
    output reg[`instRange]      inst_out
);

    reg[`addrRange] pc;
    reg[`instRange] inst;

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            pc      <= `ZERO32;
            inst    <= `ZERO32;
        end else if (instE_in == `Enable) begin
            pc      <= pc_in;
            inst    <= inst_in;
        end
    end

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            pc_out <= `ZERO32;
            inst_out <= `ZERO32;
        end else if (pcJump_in == `Jump) begin
            pc_out <= `ZERO32;
            inst_out <= `ZERO32;
        end else if (stall_in[1] == `Stall && stall_in[2] == `NoStall) begin
            pc_out <= `ZERO32;
            inst_out <= `ZERO32;
        end else if (stall_in[1] == `NoStall) begin
            pc_out      <= pc;
            inst_out    <= inst;
            pc          <= `ZERO32;
            inst        <= `ZERO32;
        end else begin
            // do nothing
        end
    end
endmodule : IF_ID