// Module    Version
//
`timescale 1ns/1ps
module version
(
    output [31:0] version
);

/* assign version  = 32'h00000004; */

// 111MHz / 50 MHz / readback of version at reg3, readback of disable at reg15
/* assign version  = 32'h00000005; */
assign version  = 32'h00000006; // peak detection now working

    endmodule

