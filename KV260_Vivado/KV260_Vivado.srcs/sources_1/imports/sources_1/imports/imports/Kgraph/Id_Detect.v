`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/30 18:35:16
// Design Name: 
// Module Name: Id_Detect
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


module Id_Detect
    #(
    parameter ID_WIDTH       = 32,
    parameter HASHCODE_WIDTH = 48,
    parameter DISTANCE_WIDTH = 6,
    parameter RAM_COUNTER    = 10 
    )
    (
    input  wire iSys_Clk,
    input  wire iSys_Rst_n,
    
    input  wire iQuery_Enable,
    
    input  wire [ID_WIDTH-1:0]           iId_Number,
    input  wire [HASHCODE_WIDTH-1:0]     iHash_Code,
    
    output reg [ID_WIDTH-1:0]           oId_Number,
    output reg [HASHCODE_WIDTH-1:0]     oHash_Code,
    output reg                          oData_Enable
    );
    /*localparam SET_BIT     = 128'b1;
    localparam CLEAR_BIT   = {128{1'b0}};
    localparam RAM_WIDTH   = 128;
    localparam RAM_DEPTH   = 10010;
     
    reg                                     rWea;
    wire [RAM_WIDTH-1:0]                    wDina;
    wire [RAM_WIDTH-1:0]                    wTemp_Dina;
    wire [clogb2(RAM_DEPTH-1)-1:0]          wAddra;
    wire [clogb2(RAM_DEPTH-1)-1:0]          wAddrb;
    reg  [clogb2(RAM_DEPTH-1)-1:0]          rClear_Addr;
    (* mark_debug = "true" *) wire [RAM_WIDTH-1:0]    wDetect_Result;
    (* mark_debug = "true" *) reg  [RAM_WIDTH-1:0]    rDetect_Result;   //delay one cycle
    (* mark_debug = "true" *) reg  [RAM_WIDTH-1:0]    rDetect_Result_1;      
    BitMap  BM(
      .clka(iSys_Clk),
      .wea(rWea),
      .addra(wAddra),
      .dina(wDina),
      .clkb(iSys_Clk),
      .addrb(wAddrb),
      .doutb(wDetect_Result)
    );
    assign wAddrb = iId_Number >> 7;
    assign wAddra = iQuery_Enable ? oId_Number>>7 : rClear_Addr;
    assign wDina = iQuery_Enable ? wTemp_Dina : CLEAR_BIT;
    
    assign wTemp_Dina = (rDetect_Result_1|(SET_BIT<<(oId_Number&127)));
                              
                          
     wire                        wRepeated_Detect;
     reg [ID_WIDTH-1:0]          rRepeated_Detect_iId_Number,rRepeated_Detect_iId_Number_1;
                        
     reg [ID_WIDTH-1:0]          rDelay_iId_Number,rDelay_iId_Number_1;
     reg [HASHCODE_WIDTH-1:0]    rDelay_Hashcode,rDelay_Hashcode_1;
     // series repeated number will cause bug, this is fixed.
     assign wRepeated_Detect = ((rDelay_iId_Number == iId_Number) || (rDelay_iId_Number_1 == iId_Number) || (oId_Number == iId_Number))? 1: 0; 
     always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if(!iSys_Rst_n) begin
            rRepeated_Detect_iId_Number <= 0;
        end else begin
            rRepeated_Detect_iId_Number <= iId_Number;
            rRepeated_Detect_iId_Number_1 <= rRepeated_Detect_iId_Number;
        end
     end    
     
      
    reg [ID_WIDTH-1:0]          rDelay_iId_Number,rDelay_iId_Number_1;
    reg [HASHCODE_WIDTH-1:0]    rDelay_Hashcode,rDelay_Hashcode_1;
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if(!iSys_Rst_n) begin
            rDelay_iId_Number   <= 0;
            rDelay_Hashcode     <= 0;
            rDelay_iId_Number_1 <= 0;
            rDelay_Hashcode_1   <= 0;
        end else if (wRepeated_Detect) begin
            rDelay_iId_Number   <= 0;
            rDelay_Hashcode     <= 0;
            rDelay_iId_Number_1 <= rDelay_iId_Number;
            rDelay_Hashcode_1   <= rDelay_Hashcode;
        end else begin
            rDelay_iId_Number   <= iId_Number;
            rDelay_Hashcode     <= iHash_Code;
            rDelay_iId_Number_1 <= rDelay_iId_Number;
            rDelay_Hashcode_1   <= rDelay_Hashcode;
        end
    end  
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if(!iSys_Rst_n) begin
            rDetect_Result <= 0;
            rDetect_Result_1 <= 0;
        end else begin
            rDetect_Result   <= ((rRepeated_Detect_iId_Number   >> 7) == (oId_Number>>7)) ? (wDina|wDetect_Result) : wDetect_Result;
            rDetect_Result_1 <= ((rRepeated_Detect_iId_Number_1 >> 7) == (oId_Number>>7)) ? (wDina|rDetect_Result) : rDetect_Result;
        end
    end
    
    localparam BM_DEPTH = 65536;
    reg [clogb2(RAM_DEPTH-1)-1:0]   BM_COUNTER;
    wire                            wResult_Enable;
    assign wResult_Enable = (oId_Number == iId_Number)?
                            ((((SET_BIT<<(rRepeated_Detect_iId_Number_1&127))&(rDetect_Result|wDina)))? 1 : 0):
                            ((((SET_BIT<<(rRepeated_Detect_iId_Number_1&127))&rDetect_Result))? 1 : 0);
    
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if(!iSys_Rst_n) begin
            oId_Number      <= 0;
            oHash_Code      <= 0;
            oData_Enable    <= 0;
            rWea            <= 0; 
            BM_COUNTER      <= 0;           
        end else if(!iQuery_Enable) begin
            rWea            <= 1;
            rClear_Addr     <= BM_COUNTER;
            BM_COUNTER      <= BM_COUNTER + 1'b1;
        end else if(wResult_Enable) begin    // this id already been computed 
            oId_Number      <= 0;
            oHash_Code      <= 0;
            oData_Enable    <= 0;
            rWea            <= 0;
        end else begin                      // this id not be compute
            oId_Number      <= rDelay_iId_Number_1;
            oHash_Code      <= rDelay_Hashcode_1;
            oData_Enable    <= 1;
            rWea            <= 1;
        end
    end*/
    
    //-----------------no--bug----------------------------
    localparam SET_BIT     = 128'b1;
    localparam CLEAR_BIT   = {128{1'b0}};
    localparam RAM_WIDTH   = 128;
    localparam RAM_DEPTH   = 10011;
    reg       rWea;
    reg  [RAM_WIDTH-1:0]     rDina;
    reg  [RAM_WIDTH-1:0]     rDina_1;
    reg                      rDina_Enable;
    reg  [RAM_WIDTH-1:0]     rTemp_Dina;
    reg  [clogb2(RAM_DEPTH-1)-1:0]      rAddra;
    reg  [clogb2(RAM_DEPTH-1)-1:0]      rAddrb;
    reg  [clogb2(RAM_DEPTH-1)-1:0]      rClear_Addr;
    (* mark_debug = "true" *) wire [RAM_WIDTH-1:0]       wDetect_Result;
    (* mark_debug = "true" *) wire [RAM_WIDTH-1:0]       wBm_Outb;
    (* mark_debug = "true" *) reg  [RAM_WIDTH-1:0]       rDetect_Result;   //delay one cycle   
    (* mark_debug = "true" *) reg  [RAM_WIDTH-1:0]       rDetect_Result_1;   //delay one cycle  
    BitMap  BM(
      .clka(iSys_Clk),
      .wea(rWea),
      .addra(rAddra),
      .dina(rDina),
      .clkb(iSys_Clk),
      .addrb(rAddrb),
      .doutb(wBm_Outb)
    );
    
    reg [clogb2(RAM_DEPTH-1)-1:0]  rAddrb_1;
    reg [clogb2(RAM_DEPTH-1)-1:0]  rAddrb_2;
    reg [clogb2(RAM_DEPTH-1)-1:0]  rAddrb_3;
    reg [RAM_WIDTH-1:0]  rBit_Mask;
    reg [RAM_WIDTH-1:0]  rBit_Mask_1;
    reg [RAM_WIDTH-1:0]  rBit_Mask_2;
    //------------------ram operation parameter--------------
    assign wDetect_Result = rDina_Enable ? rDina_1 : wBm_Outb;
    always @(*) begin
       if(!iQuery_Enable) begin
          rWea   = 1;
          rDina   = CLEAR_BIT;
          rAddra  = rClear_Addr;
          rAddrb  = (iId_Number>>7);
       end else begin
          rWea    = ~rResult_Enable;
          rDina   = rDetect_Result | rBit_Mask_1;
          rAddra  = rAddrb_2;
          rAddrb  = (iId_Number>>7);
       end
    end
    
    always@(posedge iSys_Clk or negedge iSys_Rst_n)begin
      if(!iSys_Rst_n) begin
          rDina_1 <= 0;
      end else begin
          rDina_1 <= rDina;
          rDina_Enable <= (rAddrb_2  == iId_Number>>7)?1:0;
      end
    end
    //---------------address compute--------------------
  
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
       if(!iSys_Rst_n) begin
           rAddrb_1   <= 0;
           rAddrb_2   <= 0;
       end else begin
           rAddrb_1   <= (iId_Number>>7);
           rAddrb_2   <= rAddrb_1;
       end
    end
    
    //------------bit mask compute----------------------
  
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
       if(!iSys_Rst_n) begin
           rBit_Mask    <= 1;
           rBit_Mask_1  <= 1;             
       end else begin
           rBit_Mask    <= (SET_BIT<<(iId_Number&127));
           rBit_Mask_1  <=  rBit_Mask;
       end
    end
  
  
       (* mark_debug = "true" *) wire                        wRepeated_Detect;
       (* mark_debug = "true" *) reg [ID_WIDTH-1:0]          rRepeated_Detect_iId_Number;
       
       assign wRepeated_Detect = ((rDelay_iId_Number == iId_Number) || (rDelay_iId_Number_1 == iId_Number))? 1: 0; 
       
        always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
           if(!iSys_Rst_n) begin
                rRepeated_Detect_iId_Number   <= 0;
           end else begin
                rRepeated_Detect_iId_Number <= iId_Number;
           end
       end                           
    reg [ID_WIDTH-1:0]          rDelay_iId_Number,rDelay_iId_Number_1;
    reg [HASHCODE_WIDTH-1:0]    rDelay_Hashcode,rDelay_Hashcode_1;       
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if(!iSys_Rst_n) begin
            rDelay_iId_Number     <= 0;
            rDelay_Hashcode       <= 0;
            rDelay_iId_Number_1   <= 0;
            rDelay_Hashcode_1     <= 0;
        end else if(wRepeated_Detect) begin
            rDelay_iId_Number     <= 0;
            rDelay_Hashcode       <= 0;
            rDelay_iId_Number_1   <= rDelay_iId_Number;
            rDelay_Hashcode_1     <= rDelay_Hashcode;
        end else begin
            rDelay_iId_Number     <= iId_Number;
            rDelay_Hashcode       <= iHash_Code;
            rDelay_iId_Number_1   <= rDelay_iId_Number;
            rDelay_Hashcode_1     <= rDelay_Hashcode;           
        end
    end  
    
  
  
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if(!iSys_Rst_n) begin
            rDetect_Result <= 0;  
        end else if(!iQuery_Enable) begin
            rDetect_Result <= 0;
        end else begin
            rDetect_Result <= (rAddrb_2 == rAddrb_1) ? (rDina|wDetect_Result) : wDetect_Result;
        end
    end
    
    localparam BM_DEPTH = 65536;
    reg [clogb2(RAM_DEPTH-1)-1:0] BM_COUNTER;
    reg rResult_Enable;
      always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
          if(!iSys_Rst_n) begin
              rResult_Enable <= 0;
          end else if(rAddrb_2  == rAddrb) begin
              rResult_Enable <= (((wDetect_Result|rDina)>>(rRepeated_Detect_iId_Number&127))&1); 
          end else if(rAddrb_2 == rAddrb_1) begin
              rResult_Enable <= (((rDetect_Result|rDina)>>(rRepeated_Detect_iId_Number&127))&1); 
          end else begin
              rResult_Enable <= (((wDetect_Result)>>(rRepeated_Detect_iId_Number&127))&1); 
          end
      end
    
    //assign wResult_Enable =  (((wDetect_Result)>>(rDelay_iId_Number&127))&1);
    
    
    always @(posedge iSys_Clk or negedge iSys_Rst_n) begin
        if(!iSys_Rst_n) begin
            oId_Number      <= 0;
            oHash_Code      <= 0;
            oData_Enable    <= 0;
            BM_COUNTER      <= 0;           
        end else if(!iQuery_Enable) begin
            rClear_Addr     <= BM_COUNTER;
            BM_COUNTER      <= BM_COUNTER + 1'b1;
        end else if(rResult_Enable) begin    // this id already been computed 
            oId_Number      <= 0;
            oHash_Code      <= 0;
            oData_Enable    <= 0;
        end else begin                      // this id not be compute
            oId_Number      <= rDelay_iId_Number_1;
            oHash_Code      <= rDelay_Hashcode_1;
            oData_Enable    <= 1;
        end
    end
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
          
    endfunction     
    
    
    
endmodule
