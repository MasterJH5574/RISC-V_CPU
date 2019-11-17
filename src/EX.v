`include "defines.vh"

module EX(
    input wire                  rst_in,


    input reg                   rdE_in,
    input reg[`regIdxRange]     rdIdx_in,

    input reg[`instIdxRange]    instIdx_in,
    input reg[`instTypeRange]   instType_in,

    input reg[`dataRange]       rs1Data_in,
    input reg[`dataRange]       rs2Data_in,


    output reg                  rdE_out,
    output reg[`regIdxRange]    rdIdx_out,
    output reg[`dataRange]      rdData_out
);

    reg[`dataRange] resLogic;


    always @ (*) begin
        if (rst_in == `rstEnable) begin
            resLogic <= `ZERO32;
        end else begin
            case (rdIdx_in)
                `idORI: begin
                    resLogic <= rs1Data_in | rs2Data_in;
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
            default : begin
                rdData_out <= `ZERO32;
            end
        endcase
    end

endmodule : EX