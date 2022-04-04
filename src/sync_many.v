
`timescale 1 ns / 1 ps

	module sync_many #
	(
		parameter integer WIDTH	= 1,
		parameter integer SYNC_FF = 2
	)
	(
        input [WIDTH-1 :0] clks,
        input [WIDTH-1 :0] ins,
        output [WIDTH-1 :0] outs
	);

genvar i;
generate
    for (i=0; i < WIDTH; i = i + 1) begin
        xpm_cdc_array_single #(
            .DEST_SYNC_FF(2),
            .INIT_SYNC_FF(1),
            .SIM_ASSERT_CHK(0),
            .SRC_INPUT_REG(0),
            .WIDTH(1)
        )
        xpm_cdc_array_single_inst (
            .dest_out(outs[i]),
            .dest_clk(clks[i]),
            .src_clk(1'b0), // just to remove the warning messages
            .src_in(ins[i])
        );
    end
    endgenerate

endmodule
