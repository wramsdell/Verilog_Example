`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:46:52 10/11/2010 
// Design Name: 
// Module Name:    FPGA_Shield_Bootloader_Top 
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
module FPGA_Shield_Bootloader_Top(
    input CLK,
    input BUTTON,
    input MOSI,
    output MISO,
    inout SCLK,
    input SS,
	 inout LED_RED_IN,
	 inout LED_GREEN_IN,
    output LED_RED,
    output LED_GREEN
    );

reg PowerOnButtonState;
reg ButtonStateLatched=0;

wire MOSI_int;
wire MISO_int;
wire SCLK_int;
wire SS_int;
wire TRIGGER;
reg MHzClk;
reg [5:0] MclkDiv_Count;

assign TRIGGER = !PowerOnButtonState;
assign LED_GREEN=LED_GREEN_IN;
assign LED_RED=LED_RED_IN;
assign MOSI_int = MOSI;
assign MISO = MISO_int;
assign SCLK_int = SCLK;
assign SS_int = SS;

always @(posedge CLK) begin
  if (ButtonStateLatched==0) begin
      PowerOnButtonState<=BUTTON;
		ButtonStateLatched<=1;
  end
end

SPI_ACCESS #(
.SIM_DEVICE("3S50AN")
) SPI_ACCESS_inst (
	.MISO(MISO_int),
	.MOSI(MOSI_int),
	.CSB(SS_int),
	.CLK(SCLK_int)
);

always @(posedge CLK) begin
  if (MclkDiv_Count==50) begin
    MclkDiv_Count <= 6'h00;
	 MHzClk <= !MHzClk;
  end
  else
    MclkDiv_Count <= MclkDiv_Count+1;
end

PULLDOWN PD1(.O (LED_RED_IN));
PULLDOWN PD2(.O (LED_GREEN_IN));
PULLDOWN PD3(.O (SCLK));
multiboot_trigger mbt(.trigger(TRIGGER),.clk(MHzClk));
endmodule
