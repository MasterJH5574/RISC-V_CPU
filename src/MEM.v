`include "defines.vh"

module MEM(
    input wire                  rst_in,

    // input from EX_MEM
    input wire[`instIdxRange]   instIdx_in,
    input wire[`addrRange]      memAddr_in,
    input wire[`dataRange]      valStore_in,

    input wire                  rdE_in,
    input wire[`regIdxRange]    rdIdx_in,
    input wire[`dataRange]      rdData_in,

    // input from Memory Controller
    input wire                  MC_busy_in,
    input wire                  MC_dataE_in,
    input wire[`dataRange]      MC_data_in,

    // output to Memory Controller
    output reg                  MCE_out,
    output reg                  MCrw_out,
    output reg[`addrRange]      MCAddr_out,
    output reg[`dataRange]      MCData_out,
    output reg[2:0]             MCLen_out,

    // output to IF, MEM is accessing MC
    output reg                  MEM_MCAccess_out,

    // output to MEM_WB
    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,
    output reg[`dataRange]      rdData_out,

    // stall request
    output reg                  memStall_out
);

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            MCE_out     <= `Disable;
            MCrw_out    <= `READ;
            MCAddr_out  <= `ZERO32;
            MCData_out  <= `ZERO32;
            MCLen_out   <= 0;
            MEM_MCAccess_out <= `Disable;
            rdE_out     <= `writeDisable;
            rdIdx_out   <= `regNOP;
            rdData_out  <= `ZERO32;
            memStall_out <= `NoStall;
        end else begin
            MCE_out     <= `Disable;
            MCrw_out    <= `READ;
            MCAddr_out  <= `ZERO32;
            MCData_out  <= `ZERO32;
            MCLen_out   <= 0;
            MEM_MCAccess_out <= `Disable;
            rdE_out     <= rdE_in;
            rdIdx_out   <= rdIdx_in;
            rdData_out  <= rdData_in;
            memStall_out <= `NoStall;
        end
    end

endmodule : MEM