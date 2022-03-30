`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/24 21:24:06
// Design Name: 
// Module Name: Communciate
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


module Communciate(
    input wire          iSys_Clk,
    input wire          iSys_Rst_n,
    input wire [31:0]   iInfo_rev, 
    input wire          iFinish_Kgraph,
    
    output reg [31:0]      oInfo_send,
    output reg             oBuffer_ready,   //control kgraph process 
    output reg             oQuery_ready
    );
    
    localparam Reg_Width = 32;
    
    //(* mark_debug = "true" *) reg [Reg_Width-1:0]   oInfo_send;
    //(* mark_debug = "true" *) reg                   oBuffer_ready;
    //(* mark_debug = "true" *) reg                   oQuery_ready;  
         
    (* mark_debug = "true" *) reg [3-1:0]            rState;
    reg [8-1:0]                                       count;
    reg                                               count_en , count_clr;
    
    
    /******************************************************************************************
    **                       new protocol
    *******************************************************************************************/
    
    always @(posedge iSys_Clk or negedge iSys_Rst_n ) begin 
            if(!iSys_Rst_n) begin
                oInfo_send      <= 0;
                rState          <= 0;
                oBuffer_ready   <= 0;
                count_en        <= 0;
                count_clr       <= 0;
            end
            else begin
                case (rState)
                    0:begin  // handshake
                        if(iInfo_rev[1]) begin// SYN:handshake reguest
                            oInfo_send[0]   <= 1'b1; // ACK=1;
                            oInfo_send[1]   <= 1'b0;
                            rState          <= 1;
                        end else begin
                            oInfo_send[0]   <= 1'b0; // ACK=1;
                            oInfo_send[2]   <= 1'b0;
                            oInfo_send[3]   <= 1'b0;
                            rState          <= 0;
                            oBuffer_ready   <= 0;
                        end
                    end
                    1:begin
                        if(iFinish_Kgraph) begin
                            oInfo_send[3]   <= 1'b1;  // stop signal=1
                            rState          <= 0;
                            oBuffer_ready   <= 0;
                            count_clr       <= 1'b1;
                            count_en        <= 0;
                        end else if(count == 50000) begin
                            rState          <= 0;
                            count_clr       <= 1'b1;
                            count_en        <= 0;
                        end else begin
                            oInfo_send[3]   <= 1'b0;  // stop signal=1
                            oBuffer_ready   <= 1;
                            count_clr       <= 1'b0;
                            count_en        <= 1;
                            rState          <= 1;
                        end
                    end
                    default:begin
                        oInfo_send      <= 0;
                        rState          <= 0;
                        count_en        <= 0;
                        count_clr       <= 0;
                    end
                endcase
            end
        end    
        always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
            if (!iSys_Rst_n) begin
                // reset
                count<=0;
            end
            else if (count_clr) begin
                count<=0;
            end
            else if(count_en)begin
                count<=count+1'b1;
            end
        end 
    /*******************************************************************************************************
    **                              Main Program    
    **  
    ********************************************************************************************************/    
    //assign statement
    
    //always statement
    /*always @(posedge iSys_Clk or negedge iSys_Rst_n ) begin 
        if(!iSys_Rst_n) begin
            oInfo_send      <= 0;
            rState          <= 0;
            oData_Ready     <= 0;
            oBuffer_ready   <= 0;
            count_en        <= 0;
            count_clr       <= 0;
        end
        else begin
            case (rState)
                0:begin  // handshake
                    if(iInfo_rev[1]) begin// SYN:handshake reguest
                        oInfo_send[0]   <= 1'b1; // ACK=1;
                        rState          <= 1;
                        count_en        <= 1;
                        count_clr       <= 1'b0;
                    end
                end
                1: begin
                    if(iInfo_rev[0])begin   // ACK=1 from arm
                        rState          <= 2;
                        oInfo_send[0]   <= 1'b0; // ACK=0;
                        count_clr       <= 1'b1;
                        count_en        <= 0;
                    end
                    else if(count==100) begin
                        rState          <= 0;       // timeout;
                        count_clr       <= 1'b1;
                        count_en        <= 0;
                    end
                end
                2:begin // data ready
                    oInfo_send[1]       <= 1'b0;  // stop signal=0
                    count_clr           <= 1'b1;
                    if(iInfo_rev[2])begin  // data_ready from arm
                        oInfo_send[0]   <= 1'b1; //ACK=1;
                        oData_Ready     <= 1;
                        rState          <= 3;
                    end
                    else if(iInfo_rev[3])begin  // close :FIN request
                        oInfo_send[0]   <= 1'b1; // ACK=1;
                        rState          <= 4;
                        count_en        <= 1;
                    end
                end
                3:begin    // stop signal
                    if(iPc_Stop)begin
                        oInfo_send[0]   <= 1'b0; //ACK=0;                
                        oData_Ready     <= 0;
                        if(iInfo_rev[0]) begin //ACK from arm
                            rState      <= 2;
                        end
                        else begin
                            oInfo_send[1]  <= 1'b1;  // stop signal=1
                        end
                    end
                end
                4: begin
                    if(iInfo_rev[0])begin   // ACK=1 from arm
                        rState          <= 5;
                        oInfo_send[0]   <= 1'b0; // ACK=0;
                        count_clr       <= 1'b1;
                        count_en        <= 0;
                    end
                    else if(count==100) begin
                        rState          <= 2;       // timeout;
                        count_clr       <= 1'b1;
                        count_en        <= 0;
                    end
                end
                5: begin
                    if(iFinish_Kgraph) begin
                        rState          <= 0;
                        oBuffer_ready   <= 0;
                    end else begin
                        oBuffer_ready   <= 1;
                    end
                end
                default:begin
                        oInfo_send      <= 0;
                        rState          <= 0;
                        oData_Ready     <= 0;
                        count_en        <= 0;
                        count_clr       <= 0;
                end
            endcase
        end
    end
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if (!iSys_Rst_n) begin
            // reset
            count<=0;
        end
        else if (count_clr) begin
            count<=0;
        end
        else if(count_en)begin
            count<=count+1'b1;
        end
    end*/
    
    //*************** kgraph processs *******************************************
    
    
    /*always @(posedge iSys_Clk or negedge iSys_Rst_n ) begin 
        if(!iSys_Rst_n) begin
            oInfo_send      <=0;
            oBuffer_ready   <= 1'b0;
            oData_Ready     <= 0;
            oQuery_ready    <= 1'b0;
            rState          <= 2'b00;
        end
        else begin
            case(rState)
                2'b00:begin
                    if(iInfo_rev[0])begin
                        rState <= 2'b01;
                        oInfo_send[0] <=1'b0;
                        oBuffer_ready <=1'b1;
                        oQuery_ready  <=1'b0;
                    end else if(iInfo_rev[2])begin
                        rState <= 2'b10;
                        oInfo_send[2] <= 1'b0;
                        oQuery_ready  <= 1'b1;
                        oBuffer_ready <= 1'b0;
                    end else begin
                        rState <= 2'b00;
                        oBuffer_ready <=1'b0;
                        oQuery_ready  <=1'b0;                       
                    end
                end
                2'b01:begin
                    if(iInfo_rev[1])begin
                        rState <= 2'b00;
                        oInfo_send[1] <= 1'b0;
                        oBuffer_ready <= 1'b0;
                        oQuery_ready  <= 1'b0;
                    end else begin
                        rState <= 2'b01;
                        oBuffer_ready <= 1'b1;
                        oQuery_ready  <= 1'b0;
                    end
                end
                2'b10:begin
                    if(iInfo_rev[3])begin
                        rState <= 2'b00;
                        oInfo_send[3] <= 1'b0;
                        oQuery_ready  <= 1'b0;
                        oBuffer_ready <= 1'b0;
                    end else begin
                        rState <= 2'b10;
                        oQuery_ready  <= 1'b1;
                        oBuffer_ready <= 1'b0;
                    end
                end
                default:begin
                    rState <= 2'b00;
                    oInfo_send <= 0;
                    oBuffer_ready <= 0;
                end
                
            endcase
        end
    end*/
                      
endmodule
