`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:53:53 10/30/2008 
// Design Name: 
// Module Name:    SevSeg 
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
module SevSeg(
    input [3:0] Data,
    output [7:0] Segments
    );

	reg [7:0] SegmentsInt;

	assign Segments=SegmentsInt;

	always @(Data)
		case (Data)
			4'h0 : SegmentsInt<=8'b00000011;
			4'h1 : SegmentsInt<=8'b10011111;
			4'h2 : SegmentsInt<=8'b00100101;
			4'h3 : SegmentsInt<=8'b00001101;
			4'h4 : SegmentsInt<=8'b10011001;
			4'h5 : SegmentsInt<=8'b01001001;
			4'h6 : SegmentsInt<=8'b01000001;
			4'h7 : SegmentsInt<=8'b00011111;
			4'h8 : SegmentsInt<=8'b00000001;
			4'h9 : SegmentsInt<=8'b00001001;
			4'hA : SegmentsInt<=8'b00010001;
			4'hB : SegmentsInt<=8'b11000001;
			4'hC : SegmentsInt<=8'b01100011;
			4'hD : SegmentsInt<=8'b10000101;
			4'hE : SegmentsInt<=8'b01100001;
			4'hF : SegmentsInt<=8'b01110001;
			default : SegmentsInt<=8'b11000101;
		endcase                
endmodule
