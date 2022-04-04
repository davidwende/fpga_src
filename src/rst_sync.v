
`timescale 1 ns / 1 ps

	module rstn_sync
	(
        input clk,
        input asyncrst_n,
        output reg rst_n
    );

reg rff1;

always @ (posedge clk or negedge asyncrst_n)
    if (!asyncrst_n) {rst_n, rff1} <= 2'b0;
    else  {rst_n, rff1} <= {rff1, 1'b1};

endmodule
