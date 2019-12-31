`include "defines.vh"

module ICache (
    input wire                  clk_in,
    input wire                  rst_in,
    input wire                  rdy_in,

    // input from IF
    input wire                  IF_in,
    input wire[17:0]            IFAddr_in,

    // input from MEM, MEM is accessing MC
    input wire                  MEM_MCAccess_in,

    // input from Memory Controller
    input wire                  MC_busyICache_in,
    input wire                  MC_busyMEM_in,

    input wire                  MCinstE_in,
    input wire[`instRange]      MCinst_in,

    // output to IF
    output reg                  IF_instE_out,
    output reg[`instRange]      IF_inst_out,

    // output to MC
    output reg                  MCE_out,
    output reg[`addrRange]      MC_addr_out,

    // stall request
    output reg                  ifStall_out
);
    reg[31:0] icache[127:0];
    reg[8:0]  tag[127:0];
    reg       valid[127:0];

    wire[6:0] index;
    wire[8:0] addr_tag;
    assign index = IFAddr_in[8:2];
    assign addr_tag = IFAddr_in[17:9];

    wire hitOrNot;
    wire MEM_Accessing;
    assign hitOrNot = valid[index] && tag[index] == addr_tag;
    assign MEM_Accessing = MEM_MCAccess_in == `Enable ||
        (MEM_MCAccess_in == `Disable && MC_busyMEM_in == `Busy);

    always @(*) begin
        if (rst_in == `rstDisable && IF_in == `Enable) begin
            if (hitOrNot) begin
                IF_instE_out    <= `Enable;
                IF_inst_out     <= icache[index];
                ifStall_out     <= `NoStall;
            end else begin
                IF_instE_out    <= `Disable;
                IF_inst_out     <= `ZERO32;
                ifStall_out     <= `Stall;
            end
        end else begin
            IF_instE_out    <= `Disable;
            IF_inst_out     <= `ZERO32;
            ifStall_out     <= `NoStall;
        end
    end

    always @(posedge clk_in) begin
        if (rst_in == `rstDisable && rdy_in == 1) begin
            if (IF_in == `Enable && hitOrNot == 0) begin
                if (MCinstE_in == `Enable || MEM_Accessing) begin
                    MCE_out     <= `Disable;
                    MC_addr_out <= `ZERO32;
                end else begin
                    MCE_out     <= `Enable;
                    MC_addr_out <= IFAddr_in;
                end
            end else begin
                MCE_out     <= `Disable;
                MC_addr_out <= `ZERO32;
            end
        end else begin
            MCE_out     <= `Disable;
            MC_addr_out <= `ZERO32;
        end
    end

    integer i;
    always @(posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            for (i = 0; i < 128; i = i + 1) begin
                icache[i]   <= 0;
                tag[i]      <= 0;
                valid[i]    <= 0;
            end
        end else if (rdy_in == 1 && MCinstE_in == `Enable) begin
            valid[index]   <= 1;
            tag[index]     <= addr_tag;
            icache[index]  <= MCinst_in;
        end
    end

endmodule : ICache