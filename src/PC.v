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

    // output to IF_ID
    output reg[`addrRange]      pc_out
);

    reg pcJump;
    reg Jump;
    reg[`addrRange] pcTarget;

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            pcJump      <= `NoJump;
            pcTarget    <= `ZERO32;
        end else if (pcJump_in == `Jump) begin
            pcJump      <= `Jump;
            pcTarget    <= pcTarget_in;
        end else if (Jump == 1) begin
            pcJump      <= `NoJump;
            pcTarget    <= `ZERO32;
        end else begin
            // do nothing
        end
    end

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            pc_out <= `ZERO32;
            Jump <= 0;
        end else if (stall_in[0] == `NoStall) begin
            if (pcJump == `Jump) begin
                pc_out <= pcTarget;
            end else begin
                pc_out <= pc_out + `PCSTEP;
            end
            Jump <= 1;
        end else begin
            Jump <= 0;
        end
    end

endmodule : PC