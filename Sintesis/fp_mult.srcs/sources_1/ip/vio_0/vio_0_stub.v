// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.1 (lin64) Build 2188600 Wed Apr  4 18:39:19 MDT 2018
// Date        : Mon Apr 21 21:31:14 2025
// Host        : franco-ThinkPad-E15-Gen-2 running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/franco/CLP/Recursos/CESE_CLP_TPFINAL/fp_mult.srcs/sources_1/ip/vio_0/vio_0_stub.v
// Design      : vio_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2018.1" *)
module vio_0(clk, probe_in0, probe_out0, probe_out1, 
  probe_out2)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_in0[31:0],probe_out0[31:0],probe_out1[31:0],probe_out2[0:0]" */;
  input clk;
  input [31:0]probe_in0;
  output [31:0]probe_out0;
  output [31:0]probe_out1;
  output [0:0]probe_out2;
endmodule
