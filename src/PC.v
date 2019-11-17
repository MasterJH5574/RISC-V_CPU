`include "defines.vh"

module PC (
    input wire                  clk_in,
    input wire                  rst_in,
    input wire                  rdy_in,

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
            pc = `ZERO32;
        end else begin
            pc = pc + `PCSTEP;
        end
    end

endmodule : PC