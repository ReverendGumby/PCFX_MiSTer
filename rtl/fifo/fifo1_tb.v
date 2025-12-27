`timescale 10ns / 1ns

module fifo1_tb;

parameter DSIZE = 8;
parameter ASIZE = 3;

reg [DSIZE-1:0] wdata;
reg             winc, wclk, wrst_n;
reg             rinc, rclk, rrst_n;

wire [DSIZE-1:0] rdata;
wire             wfull, rempty;

fifo1 #(DSIZE,ASIZE) fifo1
  (
   .RRST_N(rrst_n),
   .RCLK(rclk),
   .RDATA(rdata),
   .RINC(rinc),
   .REMPTY(rempty),

   .WRST_N(wrst_n),
   .WCLK(wclk),
   .WDATA(wdata),
   .WINC(winc),
   .WFULL(wfull)
   );

`define wclk_pulse      #1 wclk = 0; #1 wclk = 1
`define rclk_pulse      #1 rclk = 0; #1 rclk = 1

initial begin
  wdata <= {DSIZE{1'bx}};
  winc <= 0; wclk <= 0; wrst_n <= 0; `wclk_pulse;
  wrst_n <= 1; `wclk_pulse;

  winc <= 1; wdata <= 0; `wclk_pulse;
  winc <= 1; wdata <= 1; `wclk_pulse;
  winc <= 0; wdata <= 2; `wclk_pulse;
  winc <= 1; wdata <= 3; `wclk_pulse;
  winc <= 1; wdata <= 4; `wclk_pulse;
  winc <= 1; wdata <= 5; `wclk_pulse;
  winc <= 1; wdata <= 6; `wclk_pulse;
  winc <= 1; wdata <= 7; `wclk_pulse;
  winc <= 1; wdata <= 8; `wclk_pulse;
  winc <= 1; wdata <= 9; `wclk_pulse;
  winc <= 1; wdata <= 10; `wclk_pulse;
  winc <= 1; wdata <= 11; `wclk_pulse;
  winc <= 1; wdata <= 12; `wclk_pulse;
  winc <= 1; wdata <= 13; `wclk_pulse;
  winc <= 1; wdata <= 14; `wclk_pulse;
  winc <= 0; `wclk_pulse;
  `wclk_pulse;
  `wclk_pulse;
  `wclk_pulse;
  `wclk_pulse;
  `wclk_pulse;
  `wclk_pulse;
  `wclk_pulse;
  `wclk_pulse;
  `wclk_pulse;
  `wclk_pulse;
end

initial begin
  rinc <= 0; rclk <= 0; rrst_n <= 0; `rclk_pulse;
  rrst_n <= 1; `rclk_pulse;

  `rclk_pulse;
  `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 0; `rclk_pulse;
  rinc <= 0; `rclk_pulse;
  rinc <= 0; `rclk_pulse;
  rinc <= 0; `rclk_pulse;
  rinc <= 0; `rclk_pulse;
  rinc <= 0; `rclk_pulse;
  rinc <= 0; `rclk_pulse;
  rinc <= 0; `rclk_pulse;
  rinc <= 0; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 1; `rclk_pulse;
  rinc <= 0; `rclk_pulse;
end

endmodule
