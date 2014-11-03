///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2009 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 11.1i (L.12)
//  \   \         Description : Xilinx Timing Simulation Library Component
//  /   /                  16-Bit Shift Register Look-Up-Table with Carry and Clock Enable
// /___/   /\     Filename : SRLC16E.v
// \   \  /  \    Timestamp : Thu Mar 25 16:44:04 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/11/05 - Add LOC paramter;
//    05/07/08 - Add negative setup/hold support (CR468872)
//    12/13/11 - Added `celldefine and `endcelldefine (CR 524859).
//    04/16/13 - PR683925 - add invertible pin support.
// End Revision

`timescale 1 ps/1 ps

`celldefine

module SRLC16E #(
  `ifdef XIL_TIMING
  parameter LOC = "UNPLACED",
  `endif
  parameter [15:0] INIT = 16'h0000, 
  parameter [0:0] IS_CLK_INVERTED = 1'b0
)(
  output Q,
  output Q15,
  
  input A0,
  input A1,
  input A2,
  input A3,
  input CE,
  input CLK,
  input D
);

  reg  [15:0] data;
  wire [3:0]  addr;
  wire CLK_dly, D_dly, CE_dly;
  wire CLK_in, D_in, CE_in;
  wire clk_is_inverted;
  reg notifier;
  reg first_time = 1'b1;

  initial
  begin
    assign  data = INIT;
    first_time <= #100000 1'b0;
    while ((CLK_in !== 1'b0) && (first_time == 1'b1)) #1000;
    deassign data;
  end

  assign addr[3:0] = {A3, A2, A1, A0};

  always @(posedge CLK_in) 
    if (CE_in == 1'b1) 
      {data[15:0]} <= #100 {data[14:0], D_in};

    assign Q = data[addr];
    assign Q15 = data[15];

  always @(notifier) 
    data[0] <= 1'bx;

    
`ifndef XIL_TIMING

    assign D_dly = D;
    assign CLK_dly = CLK;
    assign CE_dly = CE;

`endif
    assign clk_is_inverted = IS_CLK_INVERTED;

    assign CLK_in = clk_is_inverted ^ CLK_dly;
    assign D_in = D_dly;
    assign CE_in = CE_dly;
    

  specify
  (A0 => Q) = (0:0:0, 0:0:0);
  (A1 => Q) = (0:0:0, 0:0:0);
  (A2 => Q) = (0:0:0, 0:0:0);
  (A3 => Q) = (0:0:0, 0:0:0);
  (CLK => Q) = (0:0:0, 0:0:0);
  (CLK => Q15) = (0:0:0, 0:0:0);
`ifdef XIL_TIMING
    $period (negedge CLK, 0:0:0, notifier);
    $period (posedge CLK, 0:0:0, notifier);
    $setuphold (negedge CLK, negedge CE, 0:0:0, 0:0:0, notifier,,,CLK_dly,CE_dly);
    $setuphold (negedge CLK, negedge D &&& CE, 0:0:0, 0:0:0, notifier,,,CLK_dly,D_dly);
    $setuphold (negedge CLK, posedge CE, 0:0:0, 0:0:0, notifier,,,CLK_dly,CE_dly);
    $setuphold (negedge CLK, posedge D &&& CE, 0:0:0, 0:0:0, notifier,,,CLK_dly,D_dly);
    $setuphold (posedge CLK, negedge CE, 0:0:0, 0:0:0, notifier,,,CLK_dly,CE_dly);
    $setuphold (posedge CLK, negedge D &&& CE, 0:0:0, 0:0:0, notifier,,,CLK_dly,D_dly);
    $setuphold (posedge CLK, posedge CE, 0:0:0, 0:0:0, notifier,,,CLK_dly,CE_dly);
    $setuphold (posedge CLK, posedge D &&& CE, 0:0:0, 0:0:0, notifier,,,CLK_dly,D_dly);
    $width (negedge CLK, 0:0:0, 0, notifier);
    $width (posedge CLK, 0:0:0, 0, notifier);
`endif
    specparam PATHPULSE$ = 0;
  endspecify

endmodule

`endcelldefine
