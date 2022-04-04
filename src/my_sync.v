
`timescale 1 ns / 1 ps

	module my_sync #
	(
		parameter integer WIDTH	= 1
	)
	(
        input clk,
        input [WIDTH-1 :0]  in,
        output [WIDTH-1 :0] out
	);

(* ASYNC_REG = "TRUE" *) reg [WIDTH-1 :0]  sync1;
(* ASYNC_REG = "TRUE" *) reg [WIDTH-1 :0]  sync2;

always @ (posedge clk)
    sync1 <= in;
always @ (posedge clk)
    sync2 <= sync1;

assign out = sync2;


endmodule
