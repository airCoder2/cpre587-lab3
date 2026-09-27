// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
// Date        : Sat Sep 19 23:06:43 2026
// Host        : co2050-18.ece.iastate.edu running 64-bit unknown
// Command     : write_verilog -force -mode synth_stub
//               /home/umhaihl/machine_learning/lab3/cpre487-587-lab3/simple_interface/vivado/simple_interface/simple_interface.srcs/sources_1/ip/ila_0/ila_0_stub.v
// Design      : ila_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2020.1" *)
module ila_0(clk, probe0, probe1)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[15:0],probe1[0:0]" */;
  input clk;
  input [15:0]probe0;
  input [0:0]probe1;
endmodule
