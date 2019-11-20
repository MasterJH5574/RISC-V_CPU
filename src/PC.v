`include "defines.vh"

module PC (
    input wire                  clk_in,
    input wire                  rst_in,
    input wire                  rdy_in,

    // stall or not
    input wire[`stallRange]     stall_in,

    // output to IF_ID
    output reg[`addrRange]      pc_out
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
        end else if (stall_in[0] == `NoStall) begin // Todo: Modify
            pc_out = pc_out + `PCSTEP;
        end else begin
            // do nothing
        end
    end

endmodule : PC