`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:50:37 10/30/2008 
// Design Name: 
// Module Name:    PID_Position 
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
module PID_Position(
	input Clk,				//Clock
	input [17:0] Pos,		//Commanded Position
	input [17:0] Enc,		//Encoder Count
	input [11:0] PC,		//Proportional Coefficient
	input [11:0] IC,		//Integral Coefficient
	input [11:0] DC,		//Derivative Coefficient
	output [17:0] PE,		//Proportional Error Output
	output [23:0] IE,		//Integral Error Output
	output [23:0] DE,		//Derivative Error Output
	output [17:0] PT,		//Proportional Term Output
	output [23:0] IT,		//Integral Term Output
	output [23:0] DT,		//Derivative Term Output
	input [15:0] ILIM,	//Integrator Limit
	output [15:0] Out		//Output to Motor Drive
	);
	 
	reg [3:0] state;		//System State
	reg [17:0] PrevPos;	//Previous Position
	reg [17:0] PEI;		//Proportional Error
	reg [23:0] IEI;		//Integral Error
	reg [23:0] DEI;		//Derivative Error
	reg [17:0] PTI;		//Proportional Term
	reg [23:0] ITI;		//Integral Term
	reg [23:0] DTI;		//Derivative Term
	reg [17:0] MA;			//Multiplier A Term
	reg [17:0] MB;			//Multiplier B Term
	reg [35:0] MP;			//Multiplier Product
	reg [35:0] AA;			//Adder A Term
	reg [35:0] AB;			//Adder B Term
	reg [36:0] AS;			//Adder Sum
	reg [15:0] OutI;		//Adder Sum
	reg Add_Sub;			//Add/Subtract Flag
	reg [15:0] Count;		//Clock scaling counter register
	reg SClk;				//Scaled clock
	
	assign PE=PEI;
	assign IE=IEI;
	assign DE=DEI;
	assign PT=PTI;
	assign IT=ITI;
	assign DT=DTI;
	assign Out=OutI;
	
	always @(MA,MB)
		MP<=MA*MB;	//Our Multiplier
		
	always @(AA,AB)	//Our Adder/Subtractor
		if (Add_Sub==1) AS<=AA+AB;
		else AS<=AA-AB;
	 
	always @(posedge Clk) 
		if (Count == 16'd5000) begin
			Count <= 16'd0;
			SClk <= ~SClk;
		end
		else Count <= Count+1;


	 always @(posedge Clk)
		case (state)
			4'd1:	//Wait for start
				if (SClk==1) begin
					AA<=Pos;
					AB<=Enc;
					Add_Sub<=0;	//Set up adder to calculate the positional error
					state<=4'd2;
				end
				else state<=4'd1;
			4'd2: begin
				PEI<=AS;
				MA<=AS;	//extract the proportional error and send it to the multiplier
				MB<=PC;	//along with the proportional coefficient
				state<=4'd3;
			end
			4'd3: begin
				PTI<=MP[27:10];	//extract the proportional result
				AA<=MP[27:10];		//Why not?
				AB<=16'h1337;		//set ourselves up for a bogus "Out"
				Add_Sub<=1;
				state<=4'd4;
			end
			4'd4: begin
				OutI<=AS;	//extract the true output
				state<=4'd5;
			end
			4'd5:
				if (SClk==0) state<=4'd1;
				else state<=4'd5;
			default:
				state<=4'd1;
		endcase

endmodule
