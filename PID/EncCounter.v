`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:20:50 10/30/2008 
// Design Name: 
// Module Name:    EncCounter 
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
module EncCounter(
    input [1:0] Enc,
    input Enc_I,
    input Clk,
    input Clr,
    output [17:0] Count
    );

   parameter S1 = 2'b01;
   parameter S2 = 2'b10;
	reg [1:0] state = S1;
	reg [17:0] EncCount;
	reg EncClk = 0;
	reg UP_DOWN = 0;
	reg [1:0] EncOld;
	assign Count = EncCount;
	
	always @(posedge EncClk or posedge Clr) begin
		if (Clr)
			EncCount <= 17'h00000;
		else if (UP_DOWN)
			EncCount <= EncCount + 1'b1;
		else
			EncCount <= EncCount - 1'b1;
	end

	always @(posedge Clk)
		case (state)
			S1: begin
				EncClk<=0;
				if (Enc==EncOld)
					state<=S1;
				else begin
					state<=S2;
					UP_DOWN <= ~(EncOld[0]^Enc[1]);
				end
			end
			S2: begin
				EncClk<=1;
				EncOld<=Enc;
				state<=S1;
			end
			default:
				state<=S1;
		endcase
endmodule
