`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:19:22 10/23/2008 
// Design Name: 
// Module Name:    Top_Level 
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

module Top_Level(
    input Clock,
    output [7:0] LED,
    output [0:7] Sevseg,
    output [3:0] Sevseg_Anode,
	 output M0,
	 output M1,
    input [3:0] Button,
    input [1:0] Enc,
    input Encoder_I
    );

	reg [15:0] Disp;
	wire [17:0] EncCount;
	assign LED[0]=Encoder_I;
	assign LED[2:1]=Enc;
	assign LED[7:6]=EncCount[17:16];
	wire Clr;
	wire [17:0] PE;
	wire [23:0] IE;
	wire [23:0] DE;
	wire [17:0] PT;
	wire [23:0] IT;
	wire [23:0] DT;
	wire [15:0] Out;
	
	parameter PC=12'h200;
	parameter IC=12'h000;
	parameter DC=12'h000;
	parameter ILIM=16'h0000;
	parameter Pos=18'h090BE;
	
	assign M0 = Button[0] ? 0 : 1'bZ;
	assign M1 = Button[1] ? 0 : 1'bZ;
	
//	assign Clr=Button[0];
			
	always @(Button,EncCount,PE,PT,PC)
		case (Button[3:2])
			2'd0: Disp<=EncCount;
			2'd1: Disp<=PE;
			2'd2: Disp<=PT;
			2'd3: Disp<=Out;
			default: Disp<=EncCount;
		endcase
		
	FourDigDisp D1 (Disp,Clock,Sevseg,Sevseg_Anode);
	EncCounter E1 (Enc,Encoder_I,Clock,Clr,EncCount);
	
	PID_Position PID1 (
		.Clk(Clock),	//Clock
		.Pos(Pos),	//Commanded Position
		.Enc(EncCount),	//Encoder Count
		.PC(PC),	//Proportional Coefficient
		.IC(IC),	//Integral Coefficient
		.DC(DC),	//Derivative Coefficient
		.PE(PE),	//Proportional Error Output
		.IE(IE),	//Integral Error Output
		.DE(DE),	//Derivative Error Output
		.PT(PT),	//Proportional Term Output
		.IT(IT),	//Integral Term Output
		.DT(DT),	//Derivative Term Output
		.ILIM(ILIM),	//Integrator Limit
		.Out(Out)	//Output to Motor Drive
	);

endmodule
