
`timescale 1ns / 1ps

`include "constants.vh"

module tb_peaks;

reg [31:0] my_vector [0:1023];
reg [31:0] A;
integer i;
integer infile; // file descriptor

initial
begin

    infile = $fopen("peak_test.txt", "r");

i = 0;
while (! $feof(infile)) begin
    $fscanf(infile, "%d\n", A);
    my_vector[i] = A;
    i = i + 1;
    #1;
end

end

reg [10:0] cnt = 0;
reg valid;
reg aresetn;

reg clk = 0;
reg [`VALUE_WIDTH-1:0] input_i;

//wire [`INDEX_WIDTH-1:0] index_i;

//assign index_i = ~0;

wire last_out;
reg last = 0;

assign input_i = my_vector[cnt];

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
    if (0 != cnt[3:0] % 7)
        valid <= 1'b1;
    else
        valid <= 1'b0;

peak_2_shell peaks_inst
   (
    .clk     (clk     ) , // input
    .aresetn (aresetn ) , // input
    .valid   (valid   ) , // input
    .last    (last    ) , // input
    .last_out(last_out) , // output
    .input_i (input_i ) , // input
    .index_i (cnt ) , // input
    .peak1_final   (peak1_final   ) , // output
    .peak2_final   (peak2_final   ) , // output
    .index1_final   (index1_final   ) , // output
    .index2_final   (index2_final   )  // output
    );

endmodule
