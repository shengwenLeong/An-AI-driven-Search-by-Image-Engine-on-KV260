`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/06 10:57:20
// Design Name: 
// Module Name: Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top
  ( );
   

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
  wire iSys_Clk;
  wire iSys_Rst_n;
  wire [31:0]ctr_arm;
  wire [31:0]ctr_fpga;

    //***************liangshengwen**********************************
    localparam WeightBuffer_wea_width     = 64;
    localparam WeightBuffer_addr_width    = 9;
    localparam WeightBuffer_din_width     = 512;
    localparam WeightBuffer_dout_width    = 512;
    localparam DISABLE                    = 1'b0;
    localparam ENABLE                     = 1'b1;
    parameter ID_WIDTH       = 32;
    parameter HASHCODE_WIDTH = 48;
    parameter DISTANCE_WIDTH = 6;
    parameter RAM_COUNTER    = 10;
    parameter USER_K         = 300;        //user configuration K 
    localparam WEIGHT_DATA_WIDTH = 512; 
    
    /*(* mark_debug = "true" *)*/ wire [13:0]Generate_ID_addr;
    wire Generate_ID_clk;
    wire [31:0]Generate_ID_din;
    /*(* mark_debug = "true" *)*/ wire [31:0]Generate_ID_dout;
    wire Generate_ID_en;
    wire Generate_ID_rst;
    wire [3:0]Generate_ID_we;
    
    /*(* mark_debug = "true" *)*/ wire [16:0]WeightBuffer_addr;
    wire WeightBuffer_clk;
    /*(* mark_debug = "true" *)*/ wire [511:0]WeightBuffer_din;
    reg  [511:0]WeightBuffer_dout;
    /*(* mark_debug = "true" *)*/ wire WeightBuffer_en;
    wire WeightBuffer_rst;
    wire [63:0]WeightBuffer_we;
    (* mark_debug = "true" *) wire cdma_introut;
    
    (* mark_debug = "true" *) wire [31:0]out_K;
    (* mark_debug = "true" *) wire [63:0]out_hash_code;
    (* mark_debug = "true" *) wire [31:0]   wInfo_rev;   //in
    (* mark_debug = "true" *) wire [31:0]   wInfo_send;    //out
    //****************** liangshengwen ******************************************************
     reg [HASHCODE_WIDTH-1:0]    iQuery_Code   = 48'hc7d8d8706c11;
     //reg [HASHCODE_WIDTH-1:0]    iQuery_Code   = 48'h71ba7160d569;
     //reg [HASHCODE_WIDTH-1:0]    iQuery_Code     = 48'h6d47c6177f30; //ImageNet dataset first image hash code
     (* mark_debug = "true" *) reg                         iQuery_Enable;
     

     wire                         wSGID_C_Buffer_Ready;
     
     /*(* mark_debug = "true" *)*/ reg                                 rWeightBuffer0_ena , rWeightBuffer1_ena , rWeightBuffer2_ena , rWeightBuffer3_ena;
     reg[WeightBuffer_wea_width-1 : 0]   rWeightBuffer0_wea , rWeightBuffer1_wea , rWeightBuffer2_wea , rWeightBuffer3_wea;
     reg[WeightBuffer_addr_width-1 : 0]  rWeightBuffer0_addra , rWeightBuffer1_addra , rWeightBuffer2_addra , rWeightBuffer3_addra;
     reg[WeightBuffer_din_width-1 : 0]   rWeightBuffer0_dina , rWeightBuffer1_dina , rWeightBuffer2_dina , rWeightBuffer3_dina;
     wire [WeightBuffer_dout_width-1 : 0]  rWeightBuffer0_douta , rWeightBuffer1_douta , rWeightBuffer2_douta , rWeightBuffer3_douta;
 
     /*(* mark_debug = "true" *)*/ reg                                 rWeightBuffer0_enb , rWeightBuffer1_enb , rWeightBuffer2_enb , rWeightBuffer3_enb;
     reg[WeightBuffer_wea_width-1 : 0]   rWeightBuffer0_web , rWeightBuffer1_web , rWeightBuffer2_web , rWeightBuffer3_web;
     /*(* mark_debug = "true" *)*/ reg[WeightBuffer_addr_width-1 : 0]  rWeightBuffer0_addrb , rWeightBuffer1_addrb , rWeightBuffer2_addrb , rWeightBuffer3_addrb;
     reg[WeightBuffer_din_width-1 : 0]   rWeightBuffer0_dinb , rWeightBuffer1_dinb , rWeightBuffer2_dinb , rWeightBuffer3_dinb;
     (* mark_debug = "true" *) wire [WeightBuffer_dout_width-1 : 0]  rWeightBuffer0_doutb;    
     (* mark_debug = "true" *) wire [WeightBuffer_dout_width-1 : 0]  rWeightBuffer1_doutb , rWeightBuffer2_doutb , rWeightBuffer3_doutb;  
     /*(* mark_debug = "true" *)*/ reg[7:0] rAcc_Weight_Count,rKgraph_Weight_Count;
     
    (* mark_debug = "true" *) wire wBuffer_ready; 
    wire                            wKGR_2_Comm_Finish_Kgraph; 
    
    reg  [8:0]               rWeightBuffer_Addrb;
    wire [8:0]               wKGR_2_Buffer_Addrb; 
    
    reg [WEIGHT_DATA_WIDTH*4-1:0] rWeightBuffer_2_SGID_C;            // this is id + code data width = 2048 and only get the 2000 bit data
    wire                         wBuffer_Read_Enable;
    wire                         wKGR_2_Buffer_Read_Enable; 
     
  //-------------------DMA SIGNAL-----------------------------------
  /*(* mark_debug="true" *)*/  wire  [1:0]        wCdma_ctl_2_AXI_Master_Cmd;
  /*(* mark_debug="true" *)*/  wire               wCdma_ctl_2_AXI_Master_INIT_AXI_TXN;
  wire                                            wAXI_Master_2_Cdma_ctl_ERROR;
  /*(* mark_debug="true" *)*/  wire               wAXI_Master_2_Cdma_ctl_TXN_DONE;
  /*(* mark_debug="true" *)*/  wire [31:0]        wCdma_ctl_2_AXI_Master_Awaddr;
  /*(* mark_debug="true" *)*/  wire [31:0]        wCdma_ctl_2_AXI_Master_Wdata;
  /*(* mark_debug="true" *)*/  wire [31:0]        wCdma_ctl_2_AXI_Master_Araddr;
  /*(* mark_debug="true" *)*/  wire [31:0]        wAXI_Master_2_Cdma_ctl_Rdata;
  
  (* mark_debug = "true" *) wire                wCDMA_Finish;
  (* mark_debug = "true" *) wire                wCDMA_Clear=1'b0;
  (* mark_debug = "true" *) wire                wCDMA_Clear_pluse;
  (* mark_debug = "true" *) wire [31:0]         wCDMA_Source_Address;
  (* mark_debug = "true" *) wire [31:0]         wCDMA_Destion_Address;
  (* mark_debug = "true" *) wire [31:0]         wCDMA_Transfer_Bytes;
  
  (* mark_debug = "true" *) reg                 rKgraph_CDMA_Clear=1'b0;
  (* mark_debug = "true" *) wire                wKgraph_CDMA_Clear_pluse;
  (* mark_debug = "true" *) reg [31:0]          rKgraph_CDMA_Source_Address;
  (* mark_debug = "true" *) reg [31:0]          rKgraph_CDMA_Destion_Address;
  (* mark_debug = "true" *) reg [31:0]          rKgraph_CDMA_Transfer_Bytes;
  
  wire                                           wCDMA_C_2_SGID_C_CDMA_Valid;
  wire [31:0]                                    wSGID_C_2_CDMA_C_Source_Addr;
  wire [31:0]                                    wSGID_C_2_CDMA_C_Dest_Addr;
  wire [31:0]                                    wSGID_C_2_CDMA_C_Transfer_Bytes;
  wire                                           wSGID_C_2_CDMA_C_CDMA_Enable;


  design_1_wrapper Kgraph_i
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
        .Sys_Clk(iSys_Clk),
        .Sys_Rst_n(iSys_Rst_n),
        .WeightBuffer_addr(WeightBuffer_addr),
        .WeightBuffer_clk(WeightBuffer_clk),
        .WeightBuffer_din(WeightBuffer_din),
        .WeightBuffer_dout(WeightBuffer_dout),
        .WeightBuffer_en(WeightBuffer_en),
        .WeightBuffer_rst(WeightBuffer_rst),
        .WeightBuffer_we(WeightBuffer_we),
        .cdma_introut(cdma_introut),
        .ctr_fpga(wInfo_send[31:0]),
        .ctr_arm(wInfo_rev[31:0]),
        .out_K(out_K),
        .out_hash_code(out_hash_code));


    axi_master_lite_v1_0_M00_AXI master(
        .iCmd(wCdma_ctl_2_AXI_Master_Cmd),
        .iAwaddr(wCdma_ctl_2_AXI_Master_Awaddr),
        .iWdata(wCdma_ctl_2_AXI_Master_Wdata),
        .iAraddr(wCdma_ctl_2_AXI_Master_Araddr),
        .oRdata(wAXI_Master_2_Cdma_ctl_Rdata),
        .INIT_AXI_TXN(wCdma_ctl_2_AXI_Master_INIT_AXI_TXN),        //inpuput
        .ERROR(wAXI_Master_2_Cdma_ctl_ERROR),                     //output
        .TXN_DONE(wAXI_Master_2_Cdma_ctl_TXN_DONE),              //output
        .M_AXI_ACLK(iSys_Clk),
        .M_AXI_ARESETN(iSys_Rst_n),
        .M_AXI_AWADDR(S_AXI_LITE_awaddr),
        .M_AXI_AWPROT(),
        .M_AXI_AWVALID(S_AXI_LITE_awvalid),
        .M_AXI_AWREADY(S_AXI_LITE_awready),
        .M_AXI_WDATA(S_AXI_LITE_wdata),
        .M_AXI_WSTRB(),
        .M_AXI_WVALID(S_AXI_LITE_wvalid),
        .M_AXI_WREADY(S_AXI_LITE_wready),
        .M_AXI_BRESP(S_AXI_LITE_bresp),
        .M_AXI_BVALID(S_AXI_LITE_bvalid),
        .M_AXI_BREADY(S_AXI_LITE_bready),
        .M_AXI_ARADDR(S_AXI_LITE_araddr),
        .M_AXI_ARPROT(),
        .M_AXI_ARVALID(S_AXI_LITE_arvalid),
        .M_AXI_ARREADY(S_AXI_LITE_arready),
        .M_AXI_RDATA(S_AXI_LITE_rdata),
        .M_AXI_RRESP(S_AXI_LITE_rresp),
        .M_AXI_RVALID(S_AXI_LITE_rvalid),
        .M_AXI_RREADY(S_AXI_LITE_rready)
        );         
        
    CDMA_Control cdma_ctl(
        .iSys_Clk(iSys_Clk),
        .iSys_Rst_n(iSys_Rst_n),
        .iClr(wCDMA_Clear_pluse),                              // user control
        .iCdma_Introut(cdma_introut),
        .iSA(wCDMA_Source_Address),           //user source address
        .iDA(wCDMA_Destion_Address),           //user destion address
        .iBTT(wCDMA_Transfer_Bytes),          //user transfer bytes
        .iM_AXI_RVALID(S_AXI_LITE_rvalid), //
        .oCDMA_Valid(wCDMA_C_2_SGID_C_CDMA_Valid),                         // to reflect the cdma state;
        .oCmd(wCdma_ctl_2_AXI_Master_Cmd),
        .oAwaddr(wCdma_ctl_2_AXI_Master_Awaddr),
        .oWdata(wCdma_ctl_2_AXI_Master_Wdata),
        .oAraddr(wCdma_ctl_2_AXI_Master_Araddr),
        .iRdata(S_AXI_LITE_rdata),
        .oINIT_AXI_TXN(wCdma_ctl_2_AXI_Master_INIT_AXI_TXN),
        .oFinish(wCDMA_Finish),      //user dma finish task
        .iERROR(wAXI_Master_2_Cdma_ctl_ERROR),
        .iTXN_DONE(wAXI_Master_2_Cdma_ctl_TXN_DONE)
        );
        
  One_Clock oclk(
        .iSys_Clk(iSys_Clk),
        .iSys_Rst_n(iSys_Rst_n),
        .iEnable(rKgraph_CDMA_Clear),
        .oWave(wKgraph_CDMA_Clear_pluse)
        );  

    assign wCDMA_Clear_pluse        =  wKgraph_CDMA_Clear_pluse; 
    assign wCDMA_Source_Address     =  rKgraph_CDMA_Source_Address;
    assign wCDMA_Destion_Address    =  rKgraph_CDMA_Destion_Address;
    assign wCDMA_Transfer_Bytes     =  rKgraph_CDMA_Transfer_Bytes;
                
            
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if(!iSys_Rst_n) begin
            rKgraph_CDMA_Clear             <= 0;
            rKgraph_CDMA_Source_Address    <= 32'h0000_0000;
            rKgraph_CDMA_Destion_Address   <= 32'h0000_0000;
            rKgraph_CDMA_Transfer_Bytes    <= 32'h0000_0000;
        end else if(wSGID_C_2_CDMA_C_CDMA_Enable) begin
            rKgraph_CDMA_Clear             <= 1;
            rKgraph_CDMA_Source_Address    <= wSGID_C_2_CDMA_C_Source_Addr;
            rKgraph_CDMA_Destion_Address   <= wSGID_C_2_CDMA_C_Dest_Addr;
            rKgraph_CDMA_Transfer_Bytes    <= wSGID_C_2_CDMA_C_Transfer_Bytes;
        end else if(!wBuffer_ready) begin
            rKgraph_CDMA_Clear             <= 0;
            rKgraph_CDMA_Source_Address    <= 32'h0000_0000;
            rKgraph_CDMA_Destion_Address   <= 32'h0000_0000;
            rKgraph_CDMA_Transfer_Bytes    <= 32'h0000_0000;
        end else begin
            rKgraph_CDMA_Clear             <= 0;
            rKgraph_CDMA_Source_Address    <= rKgraph_CDMA_Source_Address;
            rKgraph_CDMA_Destion_Address   <= rKgraph_CDMA_Destion_Address;
            rKgraph_CDMA_Transfer_Bytes    <= rKgraph_CDMA_Transfer_Bytes;
        end
    end
    
    Communciate comm(
        .iSys_Clk(iSys_Clk),
        .iSys_Rst_n(iSys_Rst_n),
        .iInfo_rev(wInfo_rev),
        .iFinish_Kgraph(wKGR_2_Comm_Finish_Kgraph),
           
        .oInfo_send(wInfo_send),
        .oBuffer_ready(wBuffer_ready)
        );
        
        Graph_Buffer_0 graph_buffer_0 (
          .clka(iSys_Clk),    // input wire clka
          .ena(rWeightBuffer0_ena),      // input wire ena
          .wea(rWeightBuffer0_wea[63:0]),      // input wire [0 : 0] wea
          .addra(rWeightBuffer0_addra[8:0]),  // input wire [7 : 0] addra
          .dina(rWeightBuffer0_dina[511:0]),    // input wire [2047 : 0] dina
          .douta(rWeightBuffer0_douta[511:0]),  // output wire [2047 : 0] douta
          
          .clkb(iSys_Clk),    // input wire clka
          .enb(rWeightBuffer0_enb),      // input wire ena
          .web(rWeightBuffer0_web[63:0]),      // input wire [0 : 0] wea
          .addrb(rWeightBuffer0_addrb[8:0]),  // input wire [7 : 0] addra
          .dinb(rWeightBuffer0_dinb[511:0]),    // input wire [2047 : 0] dina
          .doutb(rWeightBuffer0_doutb[511:0])  // output wire [2047 : 0] douta 
        );
        Graph_Buffer_1 graph_buffer_1 (
          .clka(iSys_Clk),    // input wire clka
          .ena(rWeightBuffer1_ena),      // input wire ena
          .wea(rWeightBuffer1_wea[63:0]),      // input wire [0 : 0] wea
          .addra(rWeightBuffer1_addra[8:0]),  // input wire [7 : 0] addra
          .dina(rWeightBuffer1_dina[511:0]),    // input wire [2047 : 0] dina
          .douta(rWeightBuffer1_douta[511:0]),  // output wire [2047 : 0] douta
          
          .clkb(iSys_Clk),    // input wire clka
          .enb(rWeightBuffer1_enb),      // input wire ena
          .web(rWeightBuffer1_web[63:0]),      // input wire [0 : 0] wea
          .addrb(rWeightBuffer1_addrb[8:0]),  // input wire [7 : 0] addra
          .dinb(rWeightBuffer1_dinb[511:0]),    // input wire [2047 : 0] dina
          .doutb(rWeightBuffer1_doutb[511:0])  // output wire [2047 : 0] douta          
        );
        Graph_Buffer_2 graph_buffer_2 (
          .clka(iSys_Clk),    // input wire clka
          .ena(rWeightBuffer2_ena),      // input wire ena
          .wea(rWeightBuffer2_wea[63:0]),      // input wire [0 : 0] wea
          .addra(rWeightBuffer2_addra[8:0]),  // input wire [7 : 0] addra
          .dina(rWeightBuffer2_dina[511:0]),    // input wire [2047 : 0] dina
          .douta(rWeightBuffer2_douta[511:0]),  // output wire [2047 : 0] douta
          
          .clkb(iSys_Clk),    // input wire clka
          .enb(rWeightBuffer2_enb),      // input wire ena
          .web(rWeightBuffer2_web[63:0]),      // input wire [0 : 0] wea
          .addrb(rWeightBuffer2_addrb[8:0]),  // input wire [7 : 0] addra
          .dinb(rWeightBuffer2_dinb[511:0]),    // input wire [2047 : 0] dina
          .doutb(rWeightBuffer2_doutb[511:0])  // output wire [2047 : 0] douta
        );
        Graph_Buffer_3 graph_buffer_3 (
          .clka(iSys_Clk),    // input wire clka
          .ena(rWeightBuffer3_ena),      // input wire ena
          .wea(rWeightBuffer3_wea[63:0]),      // input wire [0 : 0] wea
          .addra(rWeightBuffer3_addra[8:0]),  // input wire [7 : 0] addra
          .dina(rWeightBuffer3_dina[511:0]),    // input wire [2047 : 0] dina
          .douta(rWeightBuffer3_douta[511:0]),  // output wire [2047 : 0] douta
          
          .clkb(iSys_Clk),    // input wire clka
          .enb(rWeightBuffer3_enb),      // input wire ena
          .web(rWeightBuffer3_web[63:0]),      // input wire [0 : 0] wea
          .addrb(rWeightBuffer3_addrb[8:0]),  // input wire [7 : 0] addra
          .dinb(rWeightBuffer3_dinb[511:0]),    // input wire [2047 : 0] dina
          .doutb(rWeightBuffer3_doutb[511:0])  // output wire [2047 : 0] douta
        ); 
 
 //*********************generate weight buffer address and cyclic 00 01 10 11 00 ;            
 //weightbuffer wea(mask) ,addr and data 
        always @(posedge iSys_Clk or negedge iSys_Rst_n)begin
          if(!iSys_Rst_n) begin
            rWeightBuffer0_ena  <= DISABLE;
            rWeightBuffer0_wea  <= 64'b0;
            rWeightBuffer0_addra<= 0;
            rWeightBuffer0_dina <= 0;
            rWeightBuffer1_ena  <= DISABLE;
            rWeightBuffer1_wea  <= 64'b0;
            rWeightBuffer1_addra<= 0;
            rWeightBuffer1_dina <= 0;
            rWeightBuffer2_ena  <= DISABLE;
            rWeightBuffer2_wea  <= 64'b0;
            rWeightBuffer2_addra<= 0;
            rWeightBuffer2_dina <= 0;
            rWeightBuffer3_ena  <= DISABLE;
            rWeightBuffer3_wea  <= 64'b0;
            rWeightBuffer3_addra<= 0;
            rWeightBuffer3_dina <= 0;
          end else begin
            rWeightBuffer0_wea   <= WeightBuffer_we;
            rWeightBuffer0_addra <= WeightBuffer_addr[16:8];
            rWeightBuffer0_dina  <= WeightBuffer_din;
          
            rWeightBuffer1_wea   <= WeightBuffer_we;
            rWeightBuffer1_addra <= WeightBuffer_addr[16:8];
            rWeightBuffer1_dina  <= WeightBuffer_din;
        
            rWeightBuffer2_wea   <= WeightBuffer_we;
            rWeightBuffer2_addra <= WeightBuffer_addr[16:8];
            rWeightBuffer2_dina  <= WeightBuffer_din;
          
            rWeightBuffer3_wea   <= WeightBuffer_we;
            rWeightBuffer3_addra <= WeightBuffer_addr[16:8];
            rWeightBuffer3_dina  <= WeightBuffer_din;                 
            case(rKgraph_Weight_Count)
              0:begin
                  rWeightBuffer0_ena <= WeightBuffer_en;
                  rWeightBuffer1_ena <= DISABLE;
                  rWeightBuffer2_ena <= DISABLE;
                  rWeightBuffer3_ena <= DISABLE;
              end
              1:begin
                  rWeightBuffer1_ena <= WeightBuffer_en;
                  rWeightBuffer0_ena <= DISABLE;
                  rWeightBuffer2_ena <= DISABLE;
                  rWeightBuffer3_ena <= DISABLE;
              end
              2:begin
                  rWeightBuffer2_ena <= WeightBuffer_en;
                  rWeightBuffer0_ena <= DISABLE;
                  rWeightBuffer1_ena <= DISABLE;
                  rWeightBuffer3_ena <= DISABLE;
              end
              3:begin
                  rWeightBuffer3_ena <= WeightBuffer_en;
                  rWeightBuffer0_ena <= DISABLE;
                  rWeightBuffer1_ena <= DISABLE;
                  rWeightBuffer2_ena <= DISABLE;
              end                              
            endcase           
          end
        end       
        
// Kgraph weight_count 
        always @(posedge iSys_Clk or negedge iSys_Rst_n)begin
          if(!iSys_Rst_n) begin
            rKgraph_Weight_Count <= 0;
          end
          else if(!wBuffer_ready) begin
            rKgraph_Weight_Count <= 0;
          end else if(WeightBuffer_en & wBuffer_ready)begin   
            rKgraph_Weight_Count <= (rKgraph_Weight_Count == 3) ? 0 : rKgraph_Weight_Count + 1'b1;
          end
        end

 //**************read graph id and neighborhood code *******************************
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if(!iSys_Rst_n) begin
            rWeightBuffer0_enb      <= DISABLE;
            rWeightBuffer0_web      <= {64{1'b0}};
            rWeightBuffer0_dinb     <= {512{1'bz}};
        
            rWeightBuffer1_enb      <= DISABLE;
            rWeightBuffer1_web      <= {64{1'b0}};
            rWeightBuffer1_dinb     <= {512{1'bz}};
        
            rWeightBuffer2_enb      <= DISABLE;
            rWeightBuffer2_web      <= {64{1'b0}};
            rWeightBuffer2_dinb     <= {512{1'bz}};
        
            rWeightBuffer3_enb      <= DISABLE;
            rWeightBuffer3_web      <= {64{1'b0}};
            rWeightBuffer3_dinb     <= {512{1'bz}};
        end else begin
            rWeightBuffer0_enb      <= ENABLE;
            rWeightBuffer0_web      <= {64{1'b0}};
            rWeightBuffer0_dinb     <= {512{1'bz}};
            
            rWeightBuffer1_enb      <= ENABLE;
            rWeightBuffer1_web      <= {64{1'b0}};
            rWeightBuffer1_dinb     <= {512{1'bz}};
            
            rWeightBuffer2_enb      <= ENABLE;
            rWeightBuffer2_web      <= {64{1'b0}};
            rWeightBuffer2_dinb     <= {512{1'bz}};
            
            rWeightBuffer3_enb      <= ENABLE;
            rWeightBuffer3_web      <= {64{1'b0}};
            rWeightBuffer3_dinb     <= {512{1'bz}};
        end
    end 
    
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if(!iSys_Rst_n) begin
            rWeightBuffer_2_SGID_C <= {2048{1'b0}};
        end else if(wKGR_2_Buffer_Read_Enable) begin
            rWeightBuffer_2_SGID_C <= {rWeightBuffer0_doutb,rWeightBuffer1_doutb,rWeightBuffer2_doutb,rWeightBuffer3_doutb}; 
        end else if(!iQuery_Enable) begin
            rWeightBuffer_2_SGID_C <= {2048{1'b0}};   
        end else begin
            rWeightBuffer_2_SGID_C <= rWeightBuffer_2_SGID_C;
        end
    end 
    
    always @(*) begin
        if(wBuffer_ready) begin
            rWeightBuffer0_addrb    = wKGR_2_Buffer_Addrb; // rWeightBuffer_Addrb;
            rWeightBuffer1_addrb    = wKGR_2_Buffer_Addrb; //rWeightBuffer_Addrb;
            rWeightBuffer2_addrb    = wKGR_2_Buffer_Addrb; //rWeightBuffer_Addrb;                                                  
            rWeightBuffer3_addrb    = wKGR_2_Buffer_Addrb; //rWeightBuffer_Addrb;
        end else begin
            rWeightBuffer0_addrb    = 9'bzzzzzzzzz;
            rWeightBuffer1_addrb    = 9'bzzzzzzzzz;
            rWeightBuffer2_addrb    = 9'bzzzzzzzzz;
            rWeightBuffer3_addrb    = 9'bzzzzzzzzz;
        end
    end 
           
        always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
            if(!iSys_Rst_n) begin
                iQuery_Enable <= 0;
            end else if(wBuffer_ready) begin
                iQuery_Enable <= 1;
            end else begin
                iQuery_Enable <= 0;
            end
        end
   
   wire [HASHCODE_WIDTH-1:0] wiQuery_Code;
   assign wiQuery_Code = out_hash_code >> 16;

 //**************The module is kgraph processing core ******************************/       
        
    Kgraph_core
            #(
            .USER_K            (300),
            .WEIGHT_DATA_WIDTH (512),
            .ID_WIDTH          (32),
            .HASHCODE_WIDTH    (48),
            .RAM_DEPTH         (4096)
            )
    KGR     (
            .iSys_Clk(iSys_Clk),
            .iSys_Rst_n(iSys_Rst_n),
            .iWeight_Data(rWeightBuffer_2_SGID_C),
            .iUser_K(out_K),                            // User K value
            .iQuery_Enable(iQuery_Enable),
            .iQuery_Code(wiQuery_Code),
            .iCDMA_Valid(wCDMA_C_2_SGID_C_CDMA_Valid),
            .iCDMA_Finish(wCDMA_Finish),
            .iGenerate_ID_Addr(Generate_ID_addr[13:2]),  
               
            .oSource_Addr(wSGID_C_2_CDMA_C_Source_Addr),
            .oDest_Addr(wSGID_C_2_CDMA_C_Dest_Addr),
            .oTransfer_Bytes(wSGID_C_2_CDMA_C_Transfer_Bytes),
            .oCDMA_Enable(wSGID_C_2_CDMA_C_CDMA_Enable),
            .oGenerate_ID_dout(Generate_ID_dout),
            
            .oWeightBuffer_Addrb(wKGR_2_Buffer_Addrb),
            .oBuffer_Read_Enable(wKGR_2_Buffer_Read_Enable),
            
            .oFinish_Kgraph(wKGR_2_Comm_Finish_Kgraph)
            );   
   
    
    
   
endmodule
