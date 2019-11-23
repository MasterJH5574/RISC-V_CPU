`include "defines.vh"

module memCtrl (
    input wire                  clk_in,
    input wire                  rst_in,

    // input from IF
    input wire                  IF_in,
    input wire[`addrRange]      IFAddr_in,

    // input from MEM
    input wire                  MEM_in,
    input wire                  MEMrw_in,
    input wire[`addrRange]      MEMAddr_in,
    input wire[`dataRange]      MEMData_in,
    input wire[2:0]             MEMLen_in,

    // input from RAM
    input wire[`dataBusRange]   ramData_in,

    // output to RAM
    output wire                 ramRW_out,
    output wire[`addrBusRange]  ramAddr_out,
    output wire[`dataBusRange]  ramData_out,

    // busy signal
    output reg                  busy_out,

    // output to IF
    output reg                  IFinstE_out,
    output reg[`instRange]      IFinst_out,

    // output to MEM
    output reg                  MEMdataE_out,
    output reg[`dataRange]      MEMdata_out
);

    reg[2:0] cnt;
    wire[2:0] tot;
    wire[`addrBusRange] addr;

    reg[7:0] data[3:0];

    assign tot          = MEM_in == `Enable ? MEMLen_in : (IF_in == `Enable ? 4 : 0);
    assign addr         = MEM_in == `Enable ? MEMAddr_in[`addrBusRange] : IFAddr_in[`addrBusRange];
    assign ramRW_out    = MEM_in == `Enable ? MEMrw_in : `READ;
    assign ramAddr_out  = addr + cnt;
    assign ramData_out  = data[cnt];

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            cnt         <= 0;
            data[0]     <= 8'b00000000;
            data[1]     <= 8'b00000000;
            data[2]     <= 8'b00000000;
            data[3]     <= 8'b00000000;
            busy_out    <= `NotBusy;
            IFinstE_out <= `writeDisable;
            IFinst_out  <= `ZERO32;
            MEMdataE_out<= `writeDisable;
            MEMdata_out <= `ZERO32;
        end else if (ramRW_out == `READ && tot != 0) begin
            if (cnt == 0) begin
                cnt         <= cnt + 1;
                busy_out    <= `Busy;
                IFinstE_out <= `writeDisable;
                IFinst_out  <= `ZERO32;
                MEMdataE_out<= `writeDisable;
                MEMdata_out <= `ZERO32;
            end else if (cnt < tot) begin
                cnt         <= cnt + 1;
                data[cnt - 1] <= ramData_in;
            end else if (cnt == tot) begin
                cnt         <= 0; // Todo
                if (MEM_in == `Enable) begin
                    MEMdataE_out    <= `writeEnable;
                    case (MEMLen_in)
                        3'b001: begin
                            MEMdata_out <= ramData_in;
                        end
                        3'b010: begin
                            MEMdata_out <= {ramData_in, data[0]};
                        end
                        3'b100: begin
                            MEMdata_out <= {ramData_in, data[2], data[1], data[0]};
                        end
                    endcase
                end else if (IF_in == `Enable) begin
                    IFinstE_out <= `writeEnable;
                    IFinst_out  <= {ramData_in, data[2], data[1], data[0]};
                end
            end
        end else if (ramRW_out == `WRITE && tot != 0) begin
            if (cnt == 0) begin

            end
        end else if (tot == 0) begin
            cnt         <= 0;
            data[0]     <= 8'b00000000;
            data[1]     <= 8'b00000000;
            data[2]     <= 8'b00000000;
            data[3]     <= 8'b00000000;
            busy_out    <= `NotBusy;
            IFinstE_out <= `writeDisable;
            IFinst_out  <= `ZERO32;
            MEMdataE_out<= `writeDisable;
            MEMdata_out <= `ZERO32;
        end
    end



endmodule : memCtrl