`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:12:48 10/30/2008 
// Design Name: 
// Module Name:    FourDigDisp 
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
module FourDigDisp(
    input [15:0] Disp,
    input Clk,
    output [7:0] Segments,
    output [3:0] Anodes
    );
	 
	reg [3:0] Sevseg_AnodeInt;
	reg [15:0] Count;
	reg [3:0] Dig;
	reg LEDClk;
	
	assign Anodes = Sevseg_AnodeInt;
	
	always @(posedge Clk) 
		if (Count == 16'd50000) begin
			Count <= 16'd0;
			LEDClk <= ~LEDClk;
		end
		else Count <= Count+1;
	
	always @(posedge LEDClk)
		case (Sevseg_AnodeInt)
			4'b1110: begin
				Sevseg_AnodeInt<=4'b1101;
				Dig<=Disp[7:4];
			end
			4'b1101: begin
				Sevseg_AnodeInt<=4'b1011;
				Dig<=Disp[11:8];
			end
			4'b1011: begin
				Sevseg_AnodeInt<=4'b0111;
				Dig<=Disp[15:12];
			end
			4'b0111: begin
				Sevseg_AnodeInt<=4'b1110;
				Dig<=Disp[3:0];
			end
			default: begin
				Sevseg_AnodeInt<=4'b1110;
				Dig<=Disp[3:0];
			end
		endcase

	SevSeg SS1 (Dig,Segments);

endmodule
