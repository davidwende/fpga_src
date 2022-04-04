
`timescale 1ns/1ps
module pm_resets (
            //
            // AXI S slave - incoming data to be processed
            input wire src_clk,
            input wire dest_clk,

            input io_rst_in,
            input clk_rst_in,

            output io_rst_out,
            output clk_rst_out
        );

 xpm_cdc_async_rst #(
      .DEST_SYNC_FF(3),    // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
   )
   xpm_cdc_async_io_rst_inst (
      .dest_arst(io_rst_out), // 1-bit output: src_arst asynchronous reset signal synchronized to destination
                             // clock domain. This output is registered. NOTE: Signal asserts asynchronously
                             // but deasserts synchronously to dest_clk. Width of the reset signal is at least
                             // (DEST_SYNC_FF*dest_clk) period.

      .dest_clk(dest_clk),   // 1-bit input: Destination clock.
      .src_arst(io_rst_in)    // 1-bit input: Source asynchronous reset signal.
   );

 xpm_cdc_async_rst #(
      .DEST_SYNC_FF(3),    // DECIMAL; range: 2-10
      .INIT_SYNC_FF(1),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
   )
   xpm_cdc_async_clk_rst_inst (
      .dest_arst(clk_rst_out), // 1-bit output: src_arst asynchronous reset signal synchronized to destination
                             // clock domain. This output is registered. NOTE: Signal asserts asynchronously
                             // but deasserts synchronously to dest_clk. Width of the reset signal is at least
                             // (DEST_SYNC_FF*dest_clk) period.

      .dest_clk(dest_clk),   // 1-bit input: Destination clock.
      .src_arst(clk_rst_in)    // 1-bit input: Source asynchronous reset signal.
   );

   endmodule
