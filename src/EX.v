`include "defines.vh"

module EX(
    input wire                  rst_in,

    // stall or not (if stall, DO NOT execute)
    input wire[`stallRange]     stall_in,

    // input from ID_EX
    input wire[`addrRange]      pc_in,

    input wire                  rdE_in,
    input wire[`regIdxRange]    rdIdx_in,

    input wire[`instIdxRange]   instIdx_in,
    input wire                  instType_in,

    input wire[`dataRange]      rs1Data_in,
    input wire[`dataRange]      rs2Data_in,
    input wire[`dataRange]      immData_in,

    input wire                  EX_taken_in,
    input wire[`addrRange]      EX_pcPred_in,

    // output to EX_MEM
    output reg[`instIdxRange]   instIdx_out,           // also output to ID
    output reg[`addrRange]      memAddr_out,
    output reg[`dataRange]      valStore_out,

    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,
    output reg[`dataRange]      rdData_out,

    // output to BTB
    output reg                  EX_BTB_out,
    output reg                  EX_BTB_opt_out,
    output reg[`addrRange]      EX_BTB_pc_out,
    output reg[`addrRange]      EX_BTB_target_out,

    // output to counter
//    output reg[1:0]             counter_out,

    // output to PC for jump and branch
    output reg                  pcJump_out,
    output reg[`addrRange]      pcTarget_out
);

    reg[`dataRange] res;

    wire[`addrRange] target;
    assign target = (instIdx_in == `idBEQ || instIdx_in == `idBNE || instIdx_in == `idBLT
        || instIdx_in == `idBGE || instIdx_in == `idBLTU || instIdx_in == `idBGEU) ?
        pc_in + immData_in : 0;

    always @ (*) begin
        if (rst_in == `rstEnable || stall_in[3] == `Stall) begin
            res             <= `ZERO32;
            pcJump_out      <= 0;
            pcTarget_out    <= `ZERO32;
            EX_BTB_out      <= 0;
            EX_BTB_opt_out  <= 0;
            EX_BTB_pc_out   <= `ZERO32;
            EX_BTB_target_out <= `ZERO32;
//            counter_out <= 0;
        end else begin
//            counter_out <= 0;
            case (instIdx_in)
                `idLUI: begin                               // LUI
                    res             <= immData_in;
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idAUIPC: begin                             // AUIPC
                    res             <= pc_in + immData_in;
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idJAL: begin                               // JAL
                    res             <= pc_in + `PCSTEP;
                    pcJump_out      <= 1;
                    pcTarget_out    <= pc_in + immData_in;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idJALR: begin                              // JALR
                    res             <= pc_in + `PCSTEP;
                    pcJump_out      <= 1;
                    pcTarget_out    <= (rs1Data_in + immData_in) & 32'hFFFFFFFE;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idBEQ: begin                               // BEQ
                    res             <= `ZERO32;
                    if (rs1Data_in == rs2Data_in) begin
                        if (EX_taken_in && EX_pcPred_in == target) begin
                            pcJump_out      <= 0;
                            pcTarget_out    <= `ZERO32;
                            EX_BTB_out      <= 0;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= `ZERO32;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 2'b01;
                        end else begin
                            pcJump_out      <= 1;
                            pcTarget_out    <= target;
                            EX_BTB_out      <= 1;
                            EX_BTB_opt_out  <= 1;
                            EX_BTB_pc_out   <= pc_in;
                            EX_BTB_target_out <= target;
//                            counter_out <= 2'b10;
                        end
                    end else begin
                        if (EX_taken_in) begin
                            pcJump_out      <= 1;
                            pcTarget_out    <= pc_in + `PCSTEP;
                            EX_BTB_out      <= 1;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= pc_in;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 2;
                        end else begin
                            pcJump_out      <= 0;
                            pcTarget_out    <= `ZERO32;
                            EX_BTB_out      <= 0;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= `ZERO32;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 1;
                        end
                    end
                end
                `idBNE: begin                               // BNE
                    res             <= `ZERO32;
                    if (rs1Data_in != rs2Data_in) begin
                        if (EX_taken_in && EX_pcPred_in == target) begin
                            pcJump_out      <= 0;
                            pcTarget_out    <= `ZERO32;
                            EX_BTB_out      <= 0;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= `ZERO32;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 1;
                        end else begin
                            pcJump_out      <= 1;
                            pcTarget_out    <= target;
                            EX_BTB_out      <= 1;
                            EX_BTB_opt_out  <= 1;
                            EX_BTB_pc_out   <= pc_in;
                            EX_BTB_target_out <= target;
//                            counter_out <= 2;
                        end
                    end else begin
                        if (EX_taken_in) begin
                            pcJump_out      <= 1;
                            pcTarget_out    <= pc_in + `PCSTEP;
                            EX_BTB_out      <= 1;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= pc_in;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 2;
                        end else begin
                            pcJump_out      <= 0;
                            pcTarget_out    <= `ZERO32;
                            EX_BTB_out      <= 0;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= `ZERO32;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 1;
                        end
                    end
                end
                `idBLT: begin                               // BLT
                    res             <= `ZERO32;
                    if ($signed(rs1Data_in) < $signed(rs2Data_in)) begin
                        if (EX_taken_in && EX_pcPred_in == target) begin
                            pcJump_out      <= 0;
                            pcTarget_out    <= `ZERO32;
                            EX_BTB_out      <= 0;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= `ZERO32;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 1;
                        end else begin
                            pcJump_out      <= 1;
                            pcTarget_out    <= target;
                            EX_BTB_out      <= 1;
                            EX_BTB_opt_out  <= 1;
                            EX_BTB_pc_out   <= pc_in;
                            EX_BTB_target_out <= target;
//                            counter_out <= 2;
                        end
                    end else begin
                        if (EX_taken_in) begin
                            pcJump_out      <= 1;
                            pcTarget_out    <= pc_in + `PCSTEP;
                            EX_BTB_out      <= 1;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= pc_in;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 2;
                        end else begin
                            pcJump_out      <= 0;
                            pcTarget_out    <= `ZERO32;
                            EX_BTB_out      <= 0;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= `ZERO32;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 1;
                        end
                    end
                end
                `idBGE: begin                               // BGE
                    res             <= `ZERO32;
                    if ($signed(rs1Data_in) >= $signed(rs2Data_in)) begin
                        if (EX_taken_in && EX_pcPred_in == target) begin
                            pcJump_out      <= 0;
                            pcTarget_out    <= `ZERO32;
                            EX_BTB_out      <= 0;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= `ZERO32;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 1;
                        end else begin
                            pcJump_out      <= 1;
                            pcTarget_out    <= target;
                            EX_BTB_out      <= 1;
                            EX_BTB_opt_out  <= 1;
                            EX_BTB_pc_out   <= pc_in;
                            EX_BTB_target_out <= target;
//                            counter_out <= 2;
                        end
                    end else begin
                        if (EX_taken_in) begin
                            pcJump_out      <= 1;
                            pcTarget_out    <= pc_in + `PCSTEP;
                            EX_BTB_out      <= 1;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= pc_in;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 2;
                        end else begin
                            pcJump_out      <= 0;
                            pcTarget_out    <= `ZERO32;
                            EX_BTB_out      <= 0;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= `ZERO32;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 1;
                        end
                    end
                end
                `idBLTU: begin                              // BLTU
                    res             <= `ZERO32;
                    if (rs1Data_in < rs2Data_in) begin
                        if (EX_taken_in && EX_pcPred_in == target) begin
                            pcJump_out      <= 0;
                            pcTarget_out    <= `ZERO32;
                            EX_BTB_out      <= 0;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= `ZERO32;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 1;
                        end else begin
                            pcJump_out      <= 1;
                            pcTarget_out    <= target;
                            EX_BTB_out      <= 1;
                            EX_BTB_opt_out  <= 1;
                            EX_BTB_pc_out   <= pc_in;
                            EX_BTB_target_out <= target;
//                            counter_out <= 2;
                        end
                    end else begin
                        if (EX_taken_in) begin
                            pcJump_out      <= 1;
                            pcTarget_out    <= pc_in + `PCSTEP;
                            EX_BTB_out      <= 1;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= pc_in;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 2;
                        end else begin
                            pcJump_out      <= 0;
                            pcTarget_out    <= `ZERO32;
                            EX_BTB_out      <= 0;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= `ZERO32;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 1;
                        end
                    end
                end
                `idBGEU: begin                              // BGEU
                    res             <= `ZERO32;
                    if (rs1Data_in >= rs2Data_in) begin
                        if (EX_taken_in && EX_pcPred_in == target) begin
                            pcJump_out      <= 0;
                            pcTarget_out    <= `ZERO32;
                            EX_BTB_out      <= 0;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= `ZERO32;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 1;
                        end else begin
                            pcJump_out      <= 1;
                            pcTarget_out    <= target;
                            EX_BTB_out      <= 1;
                            EX_BTB_opt_out  <= 1;
                            EX_BTB_pc_out   <= pc_in;
                            EX_BTB_target_out <= target;
//                            counter_out <= 2;
                        end
                    end else begin
                        if (EX_taken_in) begin
                            pcJump_out      <= 1;
                            pcTarget_out    <= pc_in + `PCSTEP;
                            EX_BTB_out      <= 1;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= pc_in;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 2;
                        end else begin
                            pcJump_out      <= 0;
                            pcTarget_out    <= `ZERO32;
                            EX_BTB_out      <= 0;
                            EX_BTB_opt_out  <= 0;
                            EX_BTB_pc_out   <= `ZERO32;
                            EX_BTB_target_out <= `ZERO32;
//                            counter_out <= 1;
                        end
                    end
                end
                `idSLT: begin                               // SLT
                    if ($signed(rs1Data_in) < $signed(rs2Data_in)) begin
                        res <= 1'b1;
                    end else begin
                        res <= 1'b0;
                    end
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idSLTI: begin                              // SLTI
                    if ($signed(rs1Data_in) < $signed(immData_in)) begin
                        res <= 1'b1;
                    end else begin
                        res <= 1'b0;
                    end
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idSLTU: begin                              // SLTU
                    if (rs1Data_in < rs2Data_in) begin
                        res         <= 1'b1;
                    end else begin
                        res         <= 1'b0;
                    end
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idSLTIU: begin                             // SLTIU
                    if (rs1Data_in < immData_in) begin
                        res         <= 1'b1;
                    end else begin
                        res         <= 1'b0;
                    end
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idXOR: begin                               // XOR
                    res             <= rs1Data_in ^ rs2Data_in;
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idXORI: begin                              // XORI
                    res             <= rs1Data_in ^ immData_in;
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idOR: begin                                // OR
                    res             <= rs1Data_in | rs2Data_in;
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idORI: begin                               // ORI
                    res             <= rs1Data_in | immData_in;
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idAND: begin                               // AND
                    res             <= rs1Data_in & rs2Data_in;
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idANDI: begin                              // ANDI
                    res             <= rs1Data_in & immData_in;
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idADD: begin                               // ADD
                    res             <= rs1Data_in + rs2Data_in;
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idADDI: begin                              // ADDI
                    res             <= rs1Data_in + immData_in;
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idSUB: begin                               // SUB
                    res             <= rs1Data_in - rs2Data_in;
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idSLL: begin                               // SLL
                    res             <= rs1Data_in << rs2Data_in[4:0];
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idSLLI: begin                              // SLLI
                    res             <= rs1Data_in << immData_in[4:0];
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idSRL: begin                               // SRL
                    res             <= rs1Data_in >> rs2Data_in[4:0];
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idSRLI: begin                              // SRLI
                    res             <= rs1Data_in >> immData_in[4:0];
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idSRA: begin                               // SRA
                    res             <= rs1Data_in >>> rs2Data_in[4:0];
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                `idSRAI: begin
                    res             <= rs1Data_in >>> immData_in[4:0];
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
                default : begin                             // include LB, LH, LW, LBU, LHU,
                    res             <= `ZERO32;             // SB, SH, SW
                    pcJump_out      <= 0;
                    pcTarget_out    <= `ZERO32;
                    EX_BTB_out      <= 0;
                    EX_BTB_opt_out  <= 0;
                    EX_BTB_pc_out   <= `ZERO32;
                    EX_BTB_target_out <= `ZERO32;
                end
            endcase
        end

    end

    always @ (*) begin
        if (rst_in == `rstEnable || stall_in[3] == `Stall) begin
            instIdx_out <= `idNOP;
            memAddr_out <= `ZERO32;
            valStore_out<= `ZERO32;
            rdE_out     <= `writeDisable;
            rdIdx_out   <= `regNOP;
            rdData_out  <= `ZERO32;
        end else if (instType_in == `typeValid) begin
            instIdx_out <= instIdx_in;
            memAddr_out <= rs1Data_in + immData_in;
            valStore_out<= rs2Data_in;
            rdE_out     <= rdE_in;
            rdIdx_out   <= rdIdx_in;
            rdData_out  <= res;
        end else begin
            instIdx_out <= `idNOP;
            memAddr_out <= `ZERO32;
            valStore_out<= `ZERO32;
            rdE_out     <= `writeDisable;
            rdIdx_out   <= `regNOP;
            rdData_out  <= `ZERO32;
        end
    end

//    always @ (*) begin
//        if (rst_in == `rstEnable || stall_in[3] == `Stall) begin
//            pcJump_out      <= 0;
//            pcTarget_out    <= `ZERO32;
//            EX_BTB_out      <= 0;
//            EX_BTB_opt_out  <= 0;
//            EX_BTB_pc_out   <= `ZERO32;
//            EX_BTB_target_out <= `ZERO32;
//        end else begin
//            if (instIdx_in == `idBEQ || instIdx_in == `idBNE || instIdx_in == `idBLT
//                || instIdx_in == `idBGE || instIdx_in == `idBLTU || instIdx_in == `idBGEU) begin
//                if (taken) begin
//                    if (EX_taken_in && EX_pcPred_in == target) begin
//                        pcJump_out      <= 0;
//                        pcTarget_out    <= `ZERO32;
//                        EX_BTB_out      <= 0;
//                        EX_BTB_opt_out  <= 0;
//                        EX_BTB_pc_out   <= `ZERO32;
//                        EX_BTB_target_out <= `ZERO32;
//                    end else begin
//                        pcJump_out      <= 1;
//                        pcTarget_out    <= target;
//                        EX_BTB_out      <= 1;
//                        EX_BTB_opt_out  <= 1;
//                        EX_BTB_pc_out   <= pc_in;
//                        EX_BTB_target_out <= target;
//                    end
//                end else begin
//                    if (EX_taken_in) begin
//                        pcJump_out      <= 1;
//                        pcTarget_out    <= target;
//                        EX_BTB_out      <= 1;
//                        EX_BTB_opt_out  <= 0;
//                        EX_BTB_pc_out   <= pc_in;
//                        EX_BTB_target_out <= `ZERO32;
//                    end else begin
//                        pcJump_out      <= 0;
//                        pcTarget_out    <= `ZERO32;
//                        EX_BTB_out      <= 0;
//                        EX_BTB_opt_out  <= 0;
//                        EX_BTB_pc_out   <= `ZERO32;
//                        EX_BTB_target_out <= `ZERO32;
//                    end
//                end
//            end else if (instIdx_in == `idJAL || instIdx_in == `idJALR) begin
//                pcJump_out      <= 1;
//                pcTarget_out    <= target;
//                EX_BTB_out      <= 0;
//                EX_BTB_opt_out  <= 0;
//                EX_BTB_pc_out   <= `ZERO32;
//                EX_BTB_target_out <= `ZERO32;
//            end else begin
//                pcJump_out      <= 0;
//                pcTarget_out    <= `ZERO32;
//                EX_BTB_out      <= 0;
//                EX_BTB_opt_out  <= 0;
//                EX_BTB_pc_out   <= `ZERO32;
//                EX_BTB_target_out <= `ZERO32;
//            end
//        end
//    end

endmodule : EX


module counter(
    input wire                  clk_in,
    input wire                  rst_in,
    input wire                  rdy_in,

    input wire[1:0]             counter_in
);

    integer hit;
    integer tot;
    initial hit = 0;
    initial tot = 0;

    always @ (posedge clk_in) begin
        if (rst_in == `rstDisable && rdy_in == 1) begin
            if (counter_in == 1) begin
                hit <= hit + 1;
                tot <= tot + 1;
            end else if (counter_in == 2) begin
                tot <= tot + 1;
            end
        end else begin
            hit <= 0;
            tot <= 0;
        end
    end
endmodule : counter