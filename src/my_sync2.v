// my_sync2 : slow to fast or fast to slow sync
// with acknowledge for no lost pulses
//
`timescale 1 ns / 1 ps

	module my_sync2	(
        input reset_n_in, // input clock domain
        input reset_n_out, // output clock domain

        input clkin,
        input clkout,

        input  in,
        output out
	);

(* ASYNC_REG = "TRUE" *) reg  sync1;
(* ASYNC_REG = "TRUE" *) reg  sync1_s;
(* ASYNC_REG = "TRUE" *) reg  sync1_ss;
(* ASYNC_REG = "TRUE" *) reg  sync1_sss;
(* ASYNC_REG = "TRUE" *)reg  ack;
reg  ack_s;

always @ (posedge clkin or negedge reset_n_in)
    if (!reset_n_in)
        sync1 <= 1'b0;
    else if (in)
        sync1 <= 1'b1;
    else if (ack_s)
        sync1 <= 1'b0;

always @(posedge clkin)
    ack <= sync1_ss; // sync1_ss in clkout domain

always @(posedge clkin)
    ack_s <= ack;


/* Logic in destination domain */


always @ (posedge clkout or negedge reset_n_out) begin
    if (!reset_n_out) begin
        sync1_s <= 0;
        sync1_ss <= 0;
        sync1_sss <= 0;
    end
    else begin
        sync1_s <= sync1;
        sync1_ss <= sync1_s;
        sync1_sss <= sync1_ss;
    end
end

assign out = (sync1_ss && ~sync1_sss);


endmodule

