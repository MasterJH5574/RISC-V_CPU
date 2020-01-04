`include "defines.vh"

module IF(
    input wire                  clk_in,
    input wire                  rst_in,
    input wire                  rdy_in,

    // stall or not
    input wire[`stallRange]     stall_in,

    // input from EX for pc jump
    input wire                  pcJump_in,
    input wire[`addrRange]      pcTarget_in,

    // input from MEM, MEM is accessing MC
    input wire                  MEM_MCAccess_in,

    // input from I-cache
    input wire                  instE_in,
    input wire[`instRange]      inst_in,

    // input from BTB
    input wire                  IF_BTB_taken_in,
    input wire[`addrRange]      IF_BTB_pcPred_in,

    // output to I-cache
    output reg                  ICache_out,
    output reg[17:0]            ICacheAddr_out,

    // output to IF_ID
    output reg                  instE_out,
    output reg[`addrRange]      IF_pc_out,
    output reg[`instRange]      inst_out,
    output reg                  IF_taken_out,
    output reg[`addrRange]      IF_pcPred_out,

    // output to BTB
    output reg[`addrRange]      IF_BTB_pc_out
);

    reg[`addrRange] PC_pc, PC_pc_new;
    reg pause;

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            PC_pc <= `ZERO32;
            PC_pc_new <= `ZERO32;
            pause <= 0;
        end else if (rdy_in == 1) begin
            if (stall_in[0] == `NoStall) begin
                if (pause == 0) begin
                    if (pcJump_in == `Jump) begin
                        PC_pc <= pcTarget_in;
                        PC_pc_new <= pcTarget_in + `PCSTEP;
                        pause <= 1;
                    end else if (IF_BTB_taken_in) begin
                        PC_pc <= IF_BTB_pcPred_in;
                        PC_pc_new <= IF_BTB_pcPred_in + `PCSTEP;
                        pause <= 1;
                    end else begin
                        PC_pc <= PC_pc_new;
                        PC_pc_new <= PC_pc_new + `PCSTEP;
                        pause <= 0;
                    end
                end else begin
                    if (pcJump_in == `Jump) begin
                        PC_pc <= pcTarget_in;
                        PC_pc_new <= pcTarget_in + `PCSTEP;
                        pause <= 1;
                    end else if (IF_BTB_taken_in) begin
                        PC_pc <= IF_BTB_pcPred_in;
                        PC_pc_new <= IF_BTB_pcPred_in + `PCSTEP;
                        pause <= 1;
                    end else begin
                        pause <= 0;
                    end
                end
            end else begin
                // pause <= MEM_MCAccess_in;
                if (MEM_MCAccess_in) begin
                    if (pcJump_in) begin
                        PC_pc <= pcTarget_in;
                        PC_pc_new <= pcTarget_in + `PCSTEP;
                        pause <= 1;
                    end
                    pause <= MEM_MCAccess_in;
                end else begin
                    pause <= 0;
                end
            end
        end
    end

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            instE_out       <= `Disable;
            inst_out        <= `ZERO32;
            IF_pc_out       <= `ZERO32;
            IF_taken_out    <= 0;
            IF_pcPred_out   <= `ZERO32;
            ICache_out      <= `Disable;
            ICacheAddr_out  <= `ZERO32;
            IF_BTB_pc_out   <= `ZERO32;
        end else if (rdy_in == 1) begin
            if (pcJump_in == `Jump) begin
                instE_out       <= `Disable;
                inst_out        <= `ZERO32;
                IF_pc_out       <= `ZERO32;
                IF_taken_out    <= 0;
                IF_pcPred_out   <= `ZERO32;
                ICache_out      <= `Disable;
                ICacheAddr_out  <= `ZERO32;
                IF_BTB_pc_out   <= `ZERO32;
            end else if (MEM_MCAccess_in == `Enable) begin
                ICache_out      <= `Disable;
                ICacheAddr_out  <= `ZERO32;
                IF_BTB_pc_out   <= `ZERO32;
            end else if (stall_in[1] == `NoStall) begin
                if (instE_in == `writeEnable) begin
                    instE_out       <= `Enable;
                    inst_out        <= inst_in;
                    IF_pc_out       <= PC_pc;
                    IF_taken_out    <= IF_BTB_taken_in;
                    IF_pcPred_out   <= IF_BTB_pcPred_in;
                    if (IF_BTB_taken_in) begin
                        ICache_out      <= `Disable;
                        ICacheAddr_out  <= `ZERO32;
                        IF_BTB_pc_out   <= `ZERO32;
                    end else begin
                        ICache_out      <= `Enable;
                        ICacheAddr_out  <= PC_pc_new;
                        IF_BTB_pc_out   <= PC_pc_new;
                    end
                end else begin
                    instE_out       <= `Disable;
                    inst_out        <= `ZERO32;
                    IF_pc_out       <= `ZERO32;
                    IF_taken_out    <= 0;
                    IF_pcPred_out   <= `ZERO32;
                    if (IF_BTB_taken_in) begin
                        ICache_out      <= `Disable;
                        ICacheAddr_out  <= `ZERO32;
                        IF_BTB_pc_out   <= `ZERO32;
                    end else begin
                        ICache_out      <= `Enable;
                        ICacheAddr_out  <= PC_pc;
                        IF_BTB_pc_out   <= PC_pc;
                    end
                end
            end else if (stall_in[2] == `NoStall) begin
                instE_out       <= `Disable;
                inst_out        <= `ZERO32;
                IF_pc_out       <= `ZERO32;
                IF_taken_out    <= 0;
                IF_pcPred_out   <= `ZERO32;
                ICache_out      <= `Enable;
                ICacheAddr_out  <= PC_pc;
                IF_BTB_pc_out   <= PC_pc;
            end // else keep the output signal
        end
    end

endmodule : IF