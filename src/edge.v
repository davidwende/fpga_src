// Module edge.v
// Function : Detects either rising or falling edge
//
`timescale 1ns/1ps
module edge_detect   #(
    parameter integer TYPE = 0 // 0 for falling, 1 for rising
)
(
    output o,
    input clk,
    input i
);

reg i_d;
wire falling, rising;

always @ (posedge clk)
    i_d <= i;

generate
    if (TYPE == 0)
        assign o = (~i && i_d) ? 1'b1 : 1'b0; // falling
    else
        assign o = (i && ~i_d) ? 1'b1 : 1'b0; // rising
endgenerate

endmodule

