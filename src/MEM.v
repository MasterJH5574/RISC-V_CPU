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
    input wire                  MC_busyIF_in,
    input wire                  MC_busyMEM_in,
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
            memStall_out<= `NoStall;
        end else if (instIdx_in != `idLB && instIdx_in != `idLH && instIdx_in != `idLW &&
                    instIdx_in != `idLBU && instIdx_in != `idLHU && instIdx_in != `idSB &&
                    instIdx_in != `idSH && instIdx_in != `idSW) begin
            MCE_out     <= `Disable;
            MCrw_out    <= `READ;
            MCAddr_out  <= `ZERO32;
            MCData_out  <= `ZERO32;
            MCLen_out   <= 0;
            MEM_MCAccess_out <= `Disable;
            if (instIdx_in == `idNOP) begin
                rdE_out     <= `writeDisable;
                rdIdx_out   <= `regNOP;
                rdData_out  <= `ZERO32;
            end else begin
                rdE_out     <= rdE_in;
                rdIdx_out   <= rdIdx_in;
                rdData_out  <= rdData_in;
            end
            memStall_out<= `NoStall;
        end else begin
            if (MC_busyIF_in == `Busy) begin
                MCE_out     <= `Disable;
                MCrw_out    <= `READ;
                MCAddr_out  <= `ZERO32;
                MCData_out  <= `ZERO32;
                MCLen_out   <= 0;
                MEM_MCAccess_out <= `Disable;
                rdE_out     <= `writeDisable;
                rdIdx_out   <= `regNOP;
                rdData_out  <= `ZERO32;
                memStall_out<= `Stall;
            end else if (instIdx_in == `idLB || instIdx_in == `idLBU || instIdx_in == `idLH ||
                instIdx_in == `idLHU || instIdx_in == `idLW) begin
                if (MC_dataE_in == `writeEnable) begin
                    MCE_out     <= `Disable;
                    MCrw_out    <= `READ;
                    MCAddr_out  <= `ZERO32;
                    MCData_out  <= `ZERO32;
                    MCLen_out   <= 0;
                    MEM_MCAccess_out <= `Disable;
                    rdE_out     <= rdE_in;
                    rdIdx_out   <= rdIdx_in;
                    if (instIdx_in == `idLB || instIdx_in == `idLH || instIdx_in == `idLW) begin
                        rdData_out <= MC_data_in;
                    end else if (instIdx_in == `idLBU) begin
                        rdData_out <= {{24{MC_data_in[7]}}, MC_data_in};
                    end else if (instIdx_in == `idLHU) begin
                        rdData_out <= {{16{MC_data_in[15]}}, MC_data_in};
                    end
                    memStall_out<= `NoStall;
                end else begin
                    MCE_out     <= `Enable;
                    MCrw_out    <= `READ;
                    MCAddr_out  <= memAddr_in;
                    MCData_out  <= `ZERO32;
                    if (instIdx_in == `idLB || instIdx_in == `idLBU) begin
                        MCLen_out <= 1;
                    end else if (instIdx_in == `idLH || instIdx_in == `idLHU) begin
                        MCLen_out <= 2;
                    end else if (instIdx_in == `idLW) begin
                        MCLen_out <= 4;
                    end
                    MEM_MCAccess_out <= `Enable;
                    rdE_out     <= `writeDisable;
                    rdIdx_out   <= rdIdx_in;
                    rdData_out  <= `ZERO32;
                    memStall_out<= `Stall;
                end
            end else if (instIdx_in == `idSB || instIdx_in == `idSH || instIdx_in == `idSW) begin
                if (MC_dataE_in == `writeEnable) begin
                    MCE_out     <= `Disable;
                    MCrw_out    <= `READ;
                    MCAddr_out  <= `ZERO32;
                    MCData_out  <= `ZERO32;
                    MCLen_out   <= 0;
                    MEM_MCAccess_out <= `Disable;
                    rdE_out     <= `writeDisable;
                    rdIdx_out   <= `regNOP;
                    rdData_out  <= `ZERO32;
                    memStall_out<= `NoStall;
                end else begin
                    MCE_out     <= `Enable;
                    MCrw_out    <= `WRITE;
                    MCAddr_out  <= memAddr_in;
                    if (instIdx_in == `idSB) begin
                        MCData_out  <= valStore_in[7:0];
                        MCLen_out   <= 1;
                    end else if (instIdx_in == `idSH) begin
                        MCData_out  <= valStore_in[15:0];
                        MCLen_out   <= 2;
                    end else if (instIdx_in == `idSW) begin
                        MCData_out  <= valStore_in;
                        MCLen_out   <= 4;
                    end
                    MEM_MCAccess_out <= `Enable;
                    rdE_out     <= `writeDisable;
                    rdIdx_out   <= `regNOP;
                    rdData_out  <= `ZERO32;
                    memStall_out<= `Stall;
                end
            end
        end
    end

endmodule : MEM