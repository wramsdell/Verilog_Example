`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:25:40 02/11/2011 
// Design Name: 
// Module Name:    Clock_Block 
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
module Clock_Block(
    input Clk_In,
    output Multiplied_Clk_Out
    );
	 
   wire CLK0_BUF_1;
   wire CLK0_BUF_2;
   wire CLKFB_IN_1;
   wire CLKFB_IN_2;
   wire GND_BIT;
	wire CLKFX_1;
   
   assign GND_BIT = 0;
	
BUFG  CLK0_BUFG_INST_1 (.I(CLK0_BUF_1), 
                      .O(CLKFB_IN_1));
BUFG  CLK0_BUFG_INST_2 (.I(CLK0_BUF_2), 
                      .O(CLKFB_IN_2));


//Generate 64 MHz clock
   DCM_SP #( .CLK_FEEDBACK("1X"), .CLKDV_DIVIDE(2.0), .CLKFX_DIVIDE(25), 
         .CLKFX_MULTIPLY(32), .CLKIN_DIVIDE_BY_2("FALSE"), 
         .CLKIN_PERIOD(20.000), .CLKOUT_PHASE_SHIFT("NONE"), 
         .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), .DFS_FREQUENCY_MODE("LOW"), 
         .DLL_FREQUENCY_MODE("LOW"), .DUTY_CYCLE_CORRECTION("TRUE"), 
         .FACTORY_JF(16'hC080), .PHASE_SHIFT(0), .STARTUP_WAIT("FALSE") ) 
         DCM_SP_INST1 (.CLKFB(CLKFB_IN_1), 
                       .CLKIN(Clk_In), 
                       .DSSEN(GND_BIT), 
                       .PSCLK(GND_BIT), 
                       .PSEN(GND_BIT), 
                       .PSINCDEC(GND_BIT), 
                       .RST(GND_BIT), 
                       .CLKDV(), 
                       .CLKFX(CLKFX_1), 
                       .CLKFX180(), 
                       .CLK0(CLK0_BUF_1), 
                       .CLK2X(), 
                       .CLK2X180(), 
                       .CLK90(), 
                       .CLK180(), 
                       .CLK270(), 
                       .LOCKED(), 
                       .PSDONE(), 
                       .STATUS());
							  
   DCM_SP #( .CLK_FEEDBACK("1X"), .CLKDV_DIVIDE(2.0), .CLKFX_DIVIDE(25), 
         .CLKFX_MULTIPLY(32), .CLKIN_DIVIDE_BY_2("FALSE"), 
         .CLKIN_PERIOD(20.000), .CLKOUT_PHASE_SHIFT("NONE"), 
         .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), .DFS_FREQUENCY_MODE("LOW"), 
         .DLL_FREQUENCY_MODE("LOW"), .DUTY_CYCLE_CORRECTION("TRUE"), 
         .FACTORY_JF(16'hC080), .PHASE_SHIFT(0), .STARTUP_WAIT("FALSE") ) 
         DCM_SP_INST2 (.CLKFB(CLKFB_IN_2), 
                       .CLKIN(CLKFX_1), 
                       .DSSEN(GND_BIT), 
                       .PSCLK(GND_BIT), 
                       .PSEN(GND_BIT), 
                       .PSINCDEC(GND_BIT), 
                       .RST(GND_BIT), 
                       .CLKDV(), 
                       .CLKFX(), 
                       .CLKFX180(), 
                       .CLK0(CLK0_BUF_2), 
                       .CLK2X(Multiplied_Clk_Out), 
                       .CLK2X180(), 
                       .CLK90(), 
                       .CLK180(), 
                       .CLK270(), 
                       .LOCKED(), 
                       .PSDONE(), 
                       .STATUS());
endmodule
