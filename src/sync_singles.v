`timescale 1ns/1ps
module sync_singles
#(
    parameter integer WIDTH = 8
)
(
    input [WIDTH-1:0] clk,
    input [WIDTH-1:0] in,
    output [31:0] out
);



genvar i;
generate
    for (i=0; i < WIDTH; i = i + 1) begin

        xpm_cdc_array_single #(
            .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
            .INIT_SYNC_FF(1),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
            .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
            .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input
            .WIDTH(1)           // DECIMAL; range: 1-1024
        )
        sync_single (
            .dest_out(out[i]),
            .dest_clk(clk[i]),
            .src_in(in[i])
        );
    end
    endgenerate
    endmodule
