`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/01 10:20:23
// Design Name: 
// Module Name: Kgraph_core
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


module Kgraph_core
    #(
    parameter USER_K            = 300,
    parameter WEIGHT_DATA_WIDTH = 512,
    parameter ID_WIDTH          = 32,
    parameter HASHCODE_WIDTH    = 48,
    parameter RAM_DEPTH         = 4096      
    )
    (
    input wire iSys_Clk,
    input wire iSys_Rst_n,
    input wire [WEIGHT_DATA_WIDTH*4-1:0]        iWeight_Data,
    input wire [ID_WIDTH-1:0]                   iUser_K,
    input wire                                  iQuery_Enable,
    input wire [HASHCODE_WIDTH-1:0]             iQuery_Code,
    input wire                                  iCDMA_Valid,
    input wire                                  iCDMA_Finish,
    input wire [clogb2(RAM_DEPTH-1)-1:0]        iGenerate_ID_Addr,
    
    output wire [ID_WIDTH-1:0]                  oSource_Addr,
    output wire [ID_WIDTH-1:0]                  oDest_Addr,
    output wire [ID_WIDTH-1:0]                  oTransfer_Bytes,
    output wire                                 oCDMA_Enable,
    output wire [ID_WIDTH-1:0]                  oGenerate_ID_dout,
    
    output reg [8:0]                            oWeightBuffer_Addrb,
    output wire                                 oBuffer_Read_Enable,
    
    output wire                                 oFinish_Kgraph
    
    );
    
    //reg  [8:0]               rWeightBuffer_Addrb;
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if(!iSys_Rst_n) begin
            oWeightBuffer_Addrb <= 9'b000000000;
        end else if(wSGID_C_Buffer_Ready) begin
            oWeightBuffer_Addrb <= (oWeightBuffer_Addrb == 9'b000000110)?9'b000000000: oWeightBuffer_Addrb + 1'b1;  //change **
        end else begin
            oWeightBuffer_Addrb <= oWeightBuffer_Addrb;
        end
    end
    
    assign oBuffer_Read_Enable = (oDest_Addr == oWeightBuffer_Addrb)? 0: 1;
    
    
    wire [ID_WIDTH-1:0]          wSGID_C_2_SGID_TOP_ID_Number;
    wire [HASHCODE_WIDTH-1:0]    wSGID_C_2_SGID_TOP_Query_Code;
    wire [HASHCODE_WIDTH-1:0]    wSGID_C_2_SGID_TOP_Hash_Code;
    wire                         wSGID_C_2_SGID_TOP_Generate_ID_Enable;
    (* mark_debug = "true" *) wire                         wSGID_TOP_2_SGID_C_Generate_ID_Enable;
    
    (* mark_debug = "true" *) wire [ID_WIDTH-1:0]          wGenerate_ID;  //this port to dma control
    (* mark_debug = "true" *) wire  wSGID_TOP_2_SGID_C_Finish_Enable;
     wire                         wSGID_C_Buffer_Ready;
    (* mark_debug = "true" *) reg [31:0]                   rCycle_Counter;
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if(!iSys_Rst_n) begin
            rCycle_Counter <= 0;
        end else if(iQuery_Enable && !wSGID_TOP_2_SGID_C_Finish_Enable)begin
            rCycle_Counter <= rCycle_Counter + 1'b1;
        end else begin
            rCycle_Counter <= rCycle_Counter; 
        end
    end
    
    SGID_Control
            #(
            .WEIGHT_DATA_WIDTH(512),
            .ID_WIDTH         (32),
            .HASHCODE_WIDTH   (48)
            )
        SGID_C(
            .iSys_Clk(iSys_Clk),
            .iSys_Rst_n(iSys_Rst_n),
            .iWeight_Data(iWeight_Data),
            .iQuery_Enable(iQuery_Enable),
            .iCDMA_Valid(iCDMA_Valid),
            .iCDMA_Finish(iCDMA_Finish),
            
            .iGenerate_ID(wGenerate_ID),
            .iFinish_Enable(wSGID_TOP_2_SGID_C_Finish_Enable),
            .iGenerate_Enable(wSGID_TOP_2_SGID_C_Generate_ID_Enable),
        
            .oId_Number(wSGID_C_2_SGID_TOP_ID_Number),
            .oHash_Code(wSGID_C_2_SGID_TOP_Hash_Code),
            .oBuffer_Ready(wSGID_C_Buffer_Ready),
            .oGenerate_ID_Enable(wSGID_C_2_SGID_TOP_Generate_ID_Enable),
            
            .oSource_Addr(oSource_Addr),
            .oDest_Addr(oDest_Addr),
            .oTransfer_Bytes(oTransfer_Bytes),
            .oCDMA_Enable(oCDMA_Enable),
            
            .oFinish_Kgraph(oFinish_Kgraph)
        );
                 
    Store_Gen_ID_Top
        #(
            .ID_WIDTH(32),
            .HASHCODE_WIDTH(48),
            .DISTANCE_WIDTH(6),
            .RAM_COUNTER(10),
            .USER_K(USER_K)
        )
    SGID_TOP(
            .iSys_Clk(iSys_Clk),
            .iSys_Rst_n(iSys_Rst_n),
            .iUser_K(iUser_K),
            .iQuery_Enable(iQuery_Enable),
            .iId_Number(wSGID_C_2_SGID_TOP_ID_Number),
            .iQuery_Code(iQuery_Code),
            .iHash_Code(wSGID_C_2_SGID_TOP_Hash_Code),
            
            .iOut_Addr(iGenerate_ID_Addr),
            
            .iGenerate_ID_Enable(wSGID_C_2_SGID_TOP_Generate_ID_Enable),
            .oGenerate_Enable(wSGID_TOP_2_SGID_C_Generate_ID_Enable),
            .oGenerate_ID(wGenerate_ID),
            .oFinish_Enable(wSGID_TOP_2_SGID_C_Finish_Enable),
            .oFinish_ID(oGenerate_ID_dout)
        );
        

    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;  
    endfunction   
endmodule
