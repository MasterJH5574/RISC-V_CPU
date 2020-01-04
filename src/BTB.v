`include "defines.vh"

module BTB(
    input wire                  clk_in,
    input wire                  rst_in,
    input wire                  rdy_in,

    // input from IF
    input wire[`addrRange]      IF_pc_in,

    // input from EX
    input wire                  EX_in,
    input wire                  EX_opt, // 1 for add, 0 for remove
    input wire[`addrRange]      EX_pc_in,
    input wire[`addrRange]      EX_target_in,

    // output to IF
    output reg                  taken_out,
    output reg[`addrRange]      pcPred_out
);

//    reg[15:0] target[31:0];
//    reg[10:0] tag[31:0];
//    reg valid[31:0];
    reg[15:0] target[7:0];
    reg[12:0] tag[7:0];
    reg valid[7:0];

//    wire[10:0] IF_pc_tag;
//    assign IF_pc_tag = IF_pc_in[17:7];
    wire[12:0] IF_pc_tag;
    assign IF_pc_tag = IF_pc_in[17:5];

//    wire[4:0] IF_pc_index, EX_pc_index;
//    assign IF_pc_index = IF_pc_in[6:2];
//    assign EX_pc_index = EX_pc_in[6:2];
    wire[2:0] IF_pc_index, EX_pc_index;
    assign IF_pc_index = IF_pc_in[4:2];
    assign EX_pc_index = EX_pc_in[4:2];

    wire hit;
    assign hit = valid[IF_pc_index] && tag[IF_pc_index] == IF_pc_tag;


    // read by IF
    always @ (*) begin
        if (rst_in == `rstDisable && IF_pc_in && hit) begin
            taken_out <= 1;
//            pcPred_out <= {14'b0, target[IF_pc_index], 2'b0}; // 14 + 16 + 2 = 32
            pcPred_out <= {target[IF_pc_index], 2'b0}; // 14 + 16 + 2 = 32
        end else begin
            taken_out <= 0;
            pcPred_out <= `ZERO32;
        end
    end

    // write by EX
    integer i;
    always @ (posedge clk_in) begin
        if (rst_in == `rstEnable) begin
//            for (i = 0; i < 32; i = i + 1) begin
            for (i = 0; i < 8; i = i + 1) begin
                target[i]   <= 0;
                tag[i]      <= 0;
                valid[i]    <= 0;
            end
        end else if (rdy_in == 1 && EX_in == `Enable) begin
            if (EX_opt == 1) begin  // add
                target[EX_pc_index] <= EX_target_in[17:2];
//                tag[EX_pc_index]    <= EX_pc_in[17:7];
                tag[EX_pc_index]    <= EX_pc_in[17:5];
                valid[EX_pc_index]  <= 1;
            end else begin          // remove
                valid[EX_pc_index]  <= 0;
            end
        end
    end

endmodule : BTB