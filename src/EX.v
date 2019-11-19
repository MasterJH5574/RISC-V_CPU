`include "defines.vh"

module EX(
    input wire                  rst_in,


    input wire                   rdE_in,
    input wire[`regIdxRange]     rdIdx_in,

    input wire[`instIdxRange]    instIdx_in,
    input wire[`instTypeRange]   instType_in,

    input wire[`dataRange]       rs1Data_in,
    input wire[`dataRange]       rs2Data_in,


    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,
    output reg[`dataRange]      rdData_out
);

    reg[`dataRange] resLogic;
    reg             resOther;


    always @ (*) begin
        if (rst_in == `rstEnable) begin
            resLogic <= `ZERO32;
        end else begin
            case (rdIdx_in)
                `idLUI: begin
                    resOther <= rs1Data_in;
                end
                `idSLT: begin                               // SLTI, SLT
                    if ($signed(rs1Data_in) < $signed(rs2Data_in)) begin
                        resOther <= 1'b1;
                    end else begin
                        resOther <= 1'b0;
                    end
                end
                `idSLTU: begin                              // SLTIU, SLTU
                    if (rs1Data_in < rs2Data_in) begin
                        resOther <= 1'b1;
                    end else begin
                        resOther <= 1'b0;
                    end
                end
                `idXOR: begin                               // XORI, XOR
                    resLogic <= rs1Data_in ^ rs2Data_in;
                end
                `idOR: begin                                // ORI, OR
                    resLogic <= rs1Data_in | rs2Data_in;
                end
                `idAND: begin                               // ANDI, AND
                    resLogic <= rs1Data_in & rs2Data_in;
                end
                default : begin
                    resLogic <= `ZERO32;
                end
            endcase
        end

    end


    always @ (*) begin              // Todo: handle rst_in?
        rdE_out     <= rdE_in;
        rdIdx_out   <= rdIdx_in;
        case (instType_in)
            `typeLogic: begin
                rdData_out <= resLogic;
            end
            `typeOther: begin
                rdData_out <= resOther;
            end
            default : begin
                rdData_out <= `ZERO32;
            end
        endcase
    end

endmodule : EX