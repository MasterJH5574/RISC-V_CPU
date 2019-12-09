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
    input wire[`dataRange]      ramData_in,

    // output to RAM
    output wire                 ramRW_out,
    output wire[`addrRange]     ramAddr_out,
    output wire[`dataRange]     ramData_out,

    // busy signal
    output reg                  busyIF_out,
    output reg                  busyMEM_out,

    // output to IF
    output reg                  IFinstE_out,
    output reg[`instRange]      IFinst_out,

    // output to MEM
    output reg                  MEMdataE_out,
    output reg[`dataRange]      MEMdata_out
);

    reg[2:0] cnt;
    wire[2:0] tot;
    wire[`addrRange] addr;
    wire ramRW_fake;

    reg[7:0] loadData[2:0];
    wire[7:0] storeData[3:0];
    assign storeData[0] = MEMData_in[7:0];
    assign storeData[1] = MEMData_in[15:8];
    assign storeData[2] = MEMData_in[23:16];
    assign storeData[3] = MEMData_in[31:24];

    assign tot          = MEM_in == `Enable ? MEMLen_in : (IF_in == `Enable ? 4 : 0);
    assign addr         = MEM_in == `Enable ? MEMAddr_in[`addrRange] : IFAddr_in[`addrRange];
    assign ramRW_out    = MEM_in == `Enable ?
                                    (cnt == tot ? `READ : MEMrw_in) : `READ;    // real RW signal
    assign ramRW_fake   = MEM_in == `Enable ? MEMrw_in : `READ;                 // used for if
    assign ramAddr_out  = addr + cnt;
    assign ramData_out  = storeData[cnt];

    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
            cnt         <= 0;
            loadData[0] <= 8'b00000000;
            loadData[1] <= 8'b00000000;
            loadData[2] <= 8'b00000000;
            busyIF_out  <= `NotBusy;
            busyMEM_out <= `NotBusy;
            IFinstE_out <= `writeDisable;
            IFinst_out  <= `ZERO32;
            MEMdataE_out<= `writeDisable;
            MEMdata_out <= `ZERO32;
        end else if (ramRW_fake == `READ && tot != 0) begin
            if (cnt == 0) begin
                cnt         <= cnt + 1;
                busyIF_out  <= IF_in == `Enable ? `Busy : `NotBusy;
                busyMEM_out <= MEM_in == `Enable ? `Busy : `NotBusy;
                IFinstE_out <= `writeDisable;
                IFinst_out  <= `ZERO32;
                MEMdataE_out<= `writeDisable;
                MEMdata_out <= `ZERO32;
            end else if (cnt < tot) begin
                cnt         <= cnt + 1;
                loadData[cnt - 1] <= ramData_in;
            end else if (cnt == tot) begin
                cnt         <= 0; // Todo
                if (MEM_in == `Enable) begin
                    MEMdataE_out    <= `writeEnable;
                    case (MEMLen_in)
                        3'b001: begin
                            MEMdata_out <= ramData_in;
                        end
                        3'b010: begin
                            MEMdata_out <= {ramData_in, loadData[0]};
                        end
                        3'b100: begin
                            MEMdata_out <= {ramData_in, loadData[2], loadData[1], loadData[0]};
                        end
                    endcase
                end else if (IF_in == `Enable) begin
                    IFinstE_out <= `writeEnable;
                    IFinst_out  <= {ramData_in, loadData[2], loadData[1], loadData[0]};
                end
            end
        end else if (ramRW_fake == `WRITE && tot != 0) begin
            if (cnt == 0) begin
                cnt         <= cnt + 1;
                busyIF_out  <= `NotBusy;
                busyMEM_out <= `Busy;
                IFinstE_out <= `writeDisable;
                IFinst_out  <= `ZERO32;
                MEMdataE_out<= `writeDisable;
                MEMdata_out <= `ZERO32;
            end else if (cnt < tot) begin
                cnt         <= cnt + 1;
            end else if (cnt == tot) begin
                cnt         <= 0;
                MEMdataE_out<= `writeEnable; // to tell MEM that the store procedure is finished
            end
        end else if (tot == 0) begin
            cnt         <= 0;
            loadData[0] <= 8'b00000000;
            loadData[1] <= 8'b00000000;
            loadData[2] <= 8'b00000000;
            busyIF_out  <= `NotBusy;
            busyMEM_out <= `NotBusy;
            IFinstE_out <= `writeDisable;
            IFinst_out  <= `ZERO32;
            MEMdataE_out<= `writeDisable;
            MEMdata_out <= `ZERO32;
        end
    end



endmodule : memCtrl