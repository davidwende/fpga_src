
`include "constants.vh"

`timescale 1ns / 1ps



module tb_peaks_doubles;

localparam logic [`VALUE_WIDTH-1:0] kv[0:31] =
    {
    `VALUE_WIDTH'h4, `VALUE_WIDTH'h28,`VALUE_WIDTH'h34,`VALUE_WIDTH'hA34,
    `VALUE_WIDTH'h137, `VALUE_WIDTH'h084,`VALUE_WIDTH'h1E3,`VALUE_WIDTH'h98,
    `VALUE_WIDTH'h514, `VALUE_WIDTH'hC3,`VALUE_WIDTH'hC3,`VALUE_WIDTH'hC1,
    `VALUE_WIDTH'h37, `VALUE_WIDTH'h102,`VALUE_WIDTH'h34,`VALUE_WIDTH'h34,
    `VALUE_WIDTH'h54, `VALUE_WIDTH'h2F3,`VALUE_WIDTH'h53,`VALUE_WIDTH'h1C1,
    `VALUE_WIDTH'hb37, `VALUE_WIDTH'h884,`VALUE_WIDTH'hE3,`VALUE_WIDTH'h8,
    `VALUE_WIDTH'h7, `VALUE_WIDTH'h132,`VALUE_WIDTH'h134,`VALUE_WIDTH'hc34,
    `VALUE_WIDTH'h37, `VALUE_WIDTH'h884,`VALUE_WIDTH'h1E3,`VALUE_WIDTH'h98
    };


reg [4:0] cnt = 0;
reg valid;
reg aresetn;

reg clk = 0;
reg [`VALUE_WIDTH-1:0] input_i;
reg [`INDEX_WIDTH-1:0] index_i = 0;
wire [31 : 0] p_i_s;
wire [`VALUE_WIDTH-1 : 0] peak;
wire [`INDEX_WIDTH-1 : 0] index;
wire side;
wire last_out;
reg last = 0;

assign input_i = kv[cnt];

always begin
    clk = 1'b1;
    #100 clk = 1'b0;
    #100;
end

initial
begin
    aresetn = 1'b0;
    #753;
    aresetn = 1'b1;
    $display("Finished reset");
    #100000
    assign last = 1'b1;
    #320
    assign last = 1'b0;

    $stop;
end

always @(posedge clk)
    cnt <= cnt + 1;

always @(posedge clk)
    if (0 != cnt % 7)
    begin
        valid <= 1'b1;
        index_i <= index_i + 1;
    end
    else
        valid <= 1'b0;

peak_doubles_shell peaks_inst
   (
    .clk     (clk     ) , // input
    .aresetn (aresetn ) , // input
    .valid   (valid   ) , // input
    .last    (last    ) , // input
    .last_out(last_out) , // output
    .input_i (input_i ) , // input
    .index_i (index_i ) , // input
    .p_i_s   (p_i_s   )  // output
    );

assign peak = p_i_s[31 : 31-`VALUE_WIDTH + 1];
assign index = p_i_s[`INDEX_WIDTH-1:0];
assign side = p_i_s[31-`VALUE_WIDTH];
endmodule
