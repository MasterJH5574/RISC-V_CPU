module stallCtrl(
    input wire                  rst_in,

    input wire                  ifStall_in,
    input wire                  idStall_in,
    input wire                  memStall_in,

    output reg[`stallRange]     stall_out
);

    always @ (*) begin
        if (rst_in == `rstEnable) begin
            stall_out <= 6'b000000;
        end else if (memStall_in == `Stall) begin
            stall_out <= 6'b011111;
        end else if (idStall_in == `Stall) begin
            stall_out <= 6'b000111;
        end else if (ifStall_in == `Stall) begin
            stall_out <= 6'b000011;
        end else begin
            stall_out <= 6'b000000;
        end
    end
endmodule : stallCtrl