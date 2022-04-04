// Module    slip_detect
// Function  detects the required slip value in order to maintain the
// 10-bit input byte as 1111100000
// The output is sent every 16 clocks (stam)
//
`timescale 1ns/1ps

module slip_detect   (
    input         clk,
    input         resetn,
    input [9:0]   data,
    output  slip
);

reg [5:0] cnt = 0;
reg slip_l;

always @ (posedge clk)
    cnt <= cnt + 1;

always @ (posedge clk or negedge resetn)
    if (!resetn)
        slip_l <= 0;
    else if (cnt == 0)
        if (data != 10'h01F)
            slip_l <= 1;
        else
            slip_l <= 0;
        else
            slip_l <= 0;

assign slip = slip_l;

        endmodule

