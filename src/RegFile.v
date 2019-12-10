`include "defines.vh"

module RegFile(
    input wire                  clk_in,
    input wire                  rst_in,
    input wire                  rdy_in,

    // write
    input wire                  writeE_in,
    input wire[`regIdxRange]    writeIdx_in,
    input wire[`dataRange]      writeData_in,

    // read reg1
    input wire reg1E_in,
    input wire[`regIdxRange]    reg1Idx_in,
    output reg[`dataRange]      reg1Data_out,

    // read reg2
    input wire reg2E_in,
    input wire[`regIdxRange]    reg2Idx_in,
    output reg[`dataRange]      reg2Data_out
);

    integer i;
    reg[`dataRange] regs[1:31];

    // write first
    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            for (i = 1; i < 32; i = i + 1)
                regs[i] <= 0;
        end else if (rdy_in == 1) begin
            if (writeE_in == `writeEnable && writeIdx_in != 5'h0) begin
                regs[writeIdx_in] <= writeData_in;
            end
        end
    end

    // read reg1
    always @ (*) begin
        if (rst_in == `rstEnable) begin
            reg1Data_out <= `ZERO32;
        end else if (reg1Idx_in == 5'h0) begin
            reg1Data_out <= `ZERO32;
        end else if (writeE_in == `writeEnable && reg1E_in == `readEnable
            && reg1Idx_in == writeIdx_in) begin
            reg1Data_out <= writeData_in;
        end else if (reg1E_in == `readEnable) begin
            reg1Data_out <= regs[reg1Idx_in];
        end else begin
            reg1Data_out <= `ZERO32;
        end
    end

    // read reg2
    always @ (*) begin
        if (rst_in == `rstEnable) begin
            reg2Data_out <= `ZERO32;
        end else if (reg2Idx_in == 5'h0) begin
            reg2Data_out <= `ZERO32;
        end else if (writeE_in == `writeEnable && reg2E_in == `readEnable
            && reg2Idx_in == writeIdx_in) begin
            reg2Data_out <= writeData_in;
        end else if (reg2E_in == `readEnable) begin
            reg2Data_out <= regs[reg2Idx_in];
        end else begin
            reg2Data_out <= `ZERO32;
        end
    end

endmodule : RegFile