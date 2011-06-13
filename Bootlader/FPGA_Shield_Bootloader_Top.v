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
    output LED_RED,
    output LED_GREEN
    );

reg PowerOnButtonState=0;
reg ButtonStateLatched=0;

wire MISO_int;
wire TRIGGER;
wire [7:0] cmd;
wire [7:0] spiAddr;
wire [31:0] spiData;
wire [5:0] outStrobe;
reg MHzClk;
reg LED_GREEN_int;
reg LED_RED_int;
reg LED_GREEN_int_ena;
reg LED_RED_int_ena;
reg SPItrig=0;
reg [5:0] MclkDiv_Count;
reg [15:0] redLedShift=16'b0000000000000000;
reg [15:0] greenLedShift=16'b1010000000000000;
reg [20:0] ledCnt;
assign TRIGGER = !PowerOnButtonState|SPItrig;
assign LED_GREEN=(greenLedShift[0]&!LED_GREEN_int_ena)|(LED_GREEN_int&LED_GREEN_int_ena);
assign LED_RED=(redLedShift[0]&!LED_RED_int_ena)|(LED_RED_int&LED_RED_int_ena);
assign MISO = MISO_int;

always @(posedge CLK) begin
    if (outStrobe[1]) begin //At this point, both a command and operand have been received
        case (cmd)
            8'h01: begin //LED Control
                {LED_GREEN_int_ena,LED_RED_int_ena} <= spiAddr[1:0];
                {LED_GREEN_int,LED_RED_int} <= spiAddr[3:2];
            end
            8'h02: begin //Multiboot Control
                SPItrig=spiAddr[0];
            end
            default: begin
            end
        endcase
    end
end

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
	.MOSI(MOSI),
	.CSB(SS),
	.CLK(SCLK)
);

SPI_Slave SS1(
    .CLK(CLK),
    .MISO(),
    .MOSI(MOSI),
    .SCLK(SCLK),
    .CS(SS),
    .OUT0(cmd),
    .OUT1(spiAddr),
    .OUT2(spiData[31:24]),
    .OUT3(spiData[23:16]),
    .OUT4(spiData[15:8]),
    .OUT5(spiData[7:0]),
    .OUTSTROBE(outStrobe),
    .IN(0)
    );
	 
always @(posedge CLK) begin
  if (MclkDiv_Count==50) begin
    MclkDiv_Count <= 6'h00;
	 MHzClk <= !MHzClk;
  end
  else
    MclkDiv_Count <= MclkDiv_Count+1;
end

PULLDOWN PD3(.O (SCLK));
multiboot_trigger mbt(.trigger(TRIGGER),.clk(MHzClk));

always @(posedge CLK) begin
    if (ledCnt==1562499) begin // 1/16th of a second
        ledCnt <= 21'h00;
        redLedShift[15:1]<=redLedShift[14:0];
        redLedShift[0]<=redLedShift[15];
        greenLedShift[15:1]<=greenLedShift[14:0];
        greenLedShift[0]<=greenLedShift[15];
    end
    else
        ledCnt <= ledCnt+1;
end
endmodule
