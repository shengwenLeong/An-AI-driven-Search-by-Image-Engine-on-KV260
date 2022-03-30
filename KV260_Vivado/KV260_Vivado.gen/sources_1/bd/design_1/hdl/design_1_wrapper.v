//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
//Date        : Thu Jan 20 13:52:28 2022
//Host        : dell running 64-bit Ubuntu 20.04.1 LTS
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (Generate_ID_addr,
    Generate_ID_clk,
    Generate_ID_din,
    Generate_ID_dout,
    Generate_ID_en,
    Generate_ID_rst,
    Generate_ID_we,
    S_AXI_LITE_araddr,
    S_AXI_LITE_arready,
    S_AXI_LITE_arvalid,
    S_AXI_LITE_awaddr,
    S_AXI_LITE_awready,
    S_AXI_LITE_awvalid,
    S_AXI_LITE_bready,
    S_AXI_LITE_bresp,
    S_AXI_LITE_bvalid,
    S_AXI_LITE_rdata,
    S_AXI_LITE_rready,
    S_AXI_LITE_rresp,
    S_AXI_LITE_rvalid,
    S_AXI_LITE_wdata,
    S_AXI_LITE_wready,
    S_AXI_LITE_wvalid,
    Sys_Clk,
    Sys_Rst_n,
    WeightBuffer_addr,
    WeightBuffer_clk,
    WeightBuffer_din,
    WeightBuffer_dout,
    WeightBuffer_en,
    WeightBuffer_rst,
    WeightBuffer_we,
    cdma_introut,
    ctr_arm,
    ctr_fpga,
    out_K,
    out_hash_code);
  output [16:0]Generate_ID_addr;
  output Generate_ID_clk;
  output [31:0]Generate_ID_din;
  input [31:0]Generate_ID_dout;
  output Generate_ID_en;
  output Generate_ID_rst;
  output [3:0]Generate_ID_we;
  input [5:0]S_AXI_LITE_araddr;
  output S_AXI_LITE_arready;
  input S_AXI_LITE_arvalid;
  input [5:0]S_AXI_LITE_awaddr;
  output S_AXI_LITE_awready;
  input S_AXI_LITE_awvalid;
  input S_AXI_LITE_bready;
  output [1:0]S_AXI_LITE_bresp;
  output S_AXI_LITE_bvalid;
  output [31:0]S_AXI_LITE_rdata;
  input S_AXI_LITE_rready;
  output [1:0]S_AXI_LITE_rresp;
  output S_AXI_LITE_rvalid;
  input [31:0]S_AXI_LITE_wdata;
  output S_AXI_LITE_wready;
  input S_AXI_LITE_wvalid;
  output Sys_Clk;
  output Sys_Rst_n;
  output [16:0]WeightBuffer_addr;
  output WeightBuffer_clk;
  output [511:0]WeightBuffer_din;
  input [511:0]WeightBuffer_dout;
  output WeightBuffer_en;
  output WeightBuffer_rst;
  output [63:0]WeightBuffer_we;
  output cdma_introut;
  output [31:0]ctr_arm;
  input [31:0]ctr_fpga;
  output [31:0]out_K;
  output [63:0]out_hash_code;

  wire [16:0]Generate_ID_addr;
  wire Generate_ID_clk;
  wire [31:0]Generate_ID_din;
  wire [31:0]Generate_ID_dout;
  wire Generate_ID_en;
  wire Generate_ID_rst;
  wire [3:0]Generate_ID_we;
  wire [5:0]S_AXI_LITE_araddr;
  wire S_AXI_LITE_arready;
  wire S_AXI_LITE_arvalid;
  wire [5:0]S_AXI_LITE_awaddr;
  wire S_AXI_LITE_awready;
  wire S_AXI_LITE_awvalid;
  wire S_AXI_LITE_bready;
  wire [1:0]S_AXI_LITE_bresp;
  wire S_AXI_LITE_bvalid;
  wire [31:0]S_AXI_LITE_rdata;
  wire S_AXI_LITE_rready;
  wire [1:0]S_AXI_LITE_rresp;
  wire S_AXI_LITE_rvalid;
  wire [31:0]S_AXI_LITE_wdata;
  wire S_AXI_LITE_wready;
  wire S_AXI_LITE_wvalid;
  wire Sys_Clk;
  wire Sys_Rst_n;
  wire [16:0]WeightBuffer_addr;
  wire WeightBuffer_clk;
  wire [511:0]WeightBuffer_din;
  wire [511:0]WeightBuffer_dout;
  wire WeightBuffer_en;
  wire WeightBuffer_rst;
  wire [63:0]WeightBuffer_we;
  wire cdma_introut;
  wire [31:0]ctr_arm;
  wire [31:0]ctr_fpga;
  wire [31:0]out_K;
  wire [63:0]out_hash_code;

  design_1 design_1_i
       (.Generate_ID_addr(Generate_ID_addr),
        .Generate_ID_clk(Generate_ID_clk),
        .Generate_ID_din(Generate_ID_din),
        .Generate_ID_dout(Generate_ID_dout),
        .Generate_ID_en(Generate_ID_en),
        .Generate_ID_rst(Generate_ID_rst),
        .Generate_ID_we(Generate_ID_we),
        .S_AXI_LITE_araddr(S_AXI_LITE_araddr),
        .S_AXI_LITE_arready(S_AXI_LITE_arready),
        .S_AXI_LITE_arvalid(S_AXI_LITE_arvalid),
        .S_AXI_LITE_awaddr(S_AXI_LITE_awaddr),
        .S_AXI_LITE_awready(S_AXI_LITE_awready),
        .S_AXI_LITE_awvalid(S_AXI_LITE_awvalid),
        .S_AXI_LITE_bready(S_AXI_LITE_bready),
        .S_AXI_LITE_bresp(S_AXI_LITE_bresp),
        .S_AXI_LITE_bvalid(S_AXI_LITE_bvalid),
        .S_AXI_LITE_rdata(S_AXI_LITE_rdata),
        .S_AXI_LITE_rready(S_AXI_LITE_rready),
        .S_AXI_LITE_rresp(S_AXI_LITE_rresp),
        .S_AXI_LITE_rvalid(S_AXI_LITE_rvalid),
        .S_AXI_LITE_wdata(S_AXI_LITE_wdata),
        .S_AXI_LITE_wready(S_AXI_LITE_wready),
        .S_AXI_LITE_wvalid(S_AXI_LITE_wvalid),
        .Sys_Clk(Sys_Clk),
        .Sys_Rst_n(Sys_Rst_n),
        .WeightBuffer_addr(WeightBuffer_addr),
        .WeightBuffer_clk(WeightBuffer_clk),
        .WeightBuffer_din(WeightBuffer_din),
        .WeightBuffer_dout(WeightBuffer_dout),
        .WeightBuffer_en(WeightBuffer_en),
        .WeightBuffer_rst(WeightBuffer_rst),
        .WeightBuffer_we(WeightBuffer_we),
        .cdma_introut(cdma_introut),
        .ctr_arm(ctr_arm),
        .ctr_fpga(ctr_fpga),
        .out_K(out_K),
        .out_hash_code(out_hash_code));
endmodule
