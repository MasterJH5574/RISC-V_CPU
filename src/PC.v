`include "defines.vh"

module PC (
    input wire                  clk_in,
    input wire                  rst_in,
    input wire                  rdy_in,

    // stall or not
    input wire[`stallRange]     stall_in,

    // pc change target for Jump and Branch
    input wire                  pcJump_in,
    input wire[`addrRange]      pcTarget_in,

    // output to IF
    output reg[`addrRange]      PC_pc_out
);

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            PC_pc_out <= `ZERO32;
        end else if (rdy_in == 1 && stall_in[0] == `NoStall) begin
            if (pcJump_in == `Jump) begin
                PC_pc_out <= pcTarget_in;
            end else begin
                PC_pc_out <= PC_pc_out + `PCSTEP;
            end
        end
    end

endmodule : PC