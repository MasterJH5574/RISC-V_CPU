`include "defines.vh"

module PC (
    input wire                  clk_in,
    input wire                  rst_in,
    input wire                  rdy_in,

    // input from EX when AUIPC
    input wire                  AUIPCpcE_in,
    input wire[`addrRange]      AUIPCpcAddr_in,

    // output to IF_ID
    output reg[`addrRange]      pc_out
//    output reg                  ce_out
);

    reg ce;
    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            ce <= `chipDisable;
        end else begin
            ce <= `chipEnable;
        end
    end

    always @ (posedge clk_in) begin
        if (ce == `chipDisable) begin
            pc_out = `ZERO32;
        end else if (AUIPCpcE_in == `writeEnable) begin
            pc_out = AUIPCpcAddr_in;
        end else begin
            pc_out = pc_out + `PCSTEP;
        end
    end

endmodule : PC