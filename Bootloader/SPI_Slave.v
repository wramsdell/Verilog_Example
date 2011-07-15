`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:41:23 02/12/2011 
// Design Name: 
// Module Name:    SPI_Slave 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module SPI_Slave(
    input CLK,
    output MISO,
    input MOSI,
    input SCLK,
    input CS,
    output [7:0] OUT0,
    output [7:0] OUT1,
    output [7:0] OUT2,
    output [7:0] OUT3,
    output [7:0] OUT4,
    output [7:0] OUT5,
    output [5:0] OUTSTROBE,
    input [31:0] IN
    );
    
reg [7:0] SPIIn;
wire [7:0] SPIOut;
wire SPIStrobe;
reg [2:0] ByteCnt;
reg [7:0] OUT0Int;
reg [7:0] OUT1Int;
reg [7:0] OUT2Int;
reg [7:0] OUT3Int;
reg [7:0] OUT4Int;
reg [7:0] OUT5Int;
reg [5:0] OUTStrobeDly;
reg [5:0] OUTStrobeInt;

//assign OUT0 = OUT0Int;
assign OUT0 = OUT0Int;
assign OUT1 = OUT1Int;
assign OUT2 = OUT2Int;
assign OUT3 = OUT3Int;
assign OUT4 = OUT4Int;
assign OUT5 = OUT5Int;
assign OUTSTROBE = OUTStrobeInt;

SPI_SerDes SSD1(
    .IN(SPIIn),
    .OUT(SPIOut),
    .MOSI(MOSI),
    .MISO(MISO),
    .SCLK(SCLK),
    .CS(CS),
    .CLK(CLK),
    .STROBE(SPIStrobe)
    );

always @(*) begin
    case (ByteCnt)
        3'h2:SPIIn=IN[31:24];
        3'h3:SPIIn=IN[23:16];
        3'h4:SPIIn=IN[15:8];
        3'h5:SPIIn=IN[7:0];
        default:SPIIn=31'h00000000;
     endcase
end

always @(posedge CLK) begin
    if (CS) begin
        ByteCnt<=0;
    end
    else if (SPIStrobe) begin
        if (ByteCnt==6) begin
            ByteCnt<=6;  //If somebody's sending us more than 6 bytes, just spin after the sixth
        end
        else begin
            ByteCnt<=ByteCnt+1;
        end
        case (ByteCnt)
            3'h0:begin
                OUT0Int<=SPIOut;
                OUTStrobeDly<=6'b000001;
            end
            3'h1:begin
                OUT1Int<=SPIOut;
                OUTStrobeDly<=6'b000010;
            end
            3'h2:begin
                OUT2Int<=SPIOut;
                OUTStrobeDly<=6'b000100;
            end
            3'h3:begin
                OUT3Int<=SPIOut;
                OUTStrobeDly<=6'b001000;
            end
            3'h4:begin
                OUT4Int<=SPIOut;
                OUTStrobeDly<=6'b010000;
            end
            3'h5:begin
                OUT5Int<=SPIOut;
                OUTStrobeDly<=6'b100000;
            end
            default: begin
                OUTStrobeDly<=6'b000000;
            end
        endcase
    end
    else begin
        OUTStrobeDly<=6'b000000;
        OUTStrobeInt<=OUTStrobeDly;
    end
end
endmodule
