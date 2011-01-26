`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:32:02 10/07/2010 
// Design Name: 
// Module Name:    FPGA_Shield_Top 
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
module PWM (
  Clk,
  SDA,
  SCL,
  LED_Green,
  LED_Red,
  Port0
);
input Clk;
inout SDA;
input SCL;
output LED_Green;
output LED_Red;
output [7:0] Port0;

wire [7:0] I2C_Out;
wire [7:0] I2C_In;
wire [7:0] I2C_Addr;
wire I2C_WEn;
reg UsClk;
reg [4:0] MclkDiv_Count;
reg [14:0] PWM_Count;
reg LED_Red_int;
reg LED_Green_int;
reg [15:0] PWM[7:0];
reg [7:0] Port0_int;


assign LED_Green=LED_Green_int;
assign LED_Red=LED_Red_int;
assign Port0=Port0_int;

i2cSlave u_i2cSlave(
  .clk(Clk),
  .rst(0),
  .sda(SDA),
  .scl(SCL),
  .Out(I2C_Out),
  .In(I2C_In),
  .Addr(I2C_Addr),
  .WEn(I2C_WEn)
);

always @(posedge Clk) begin
  if (I2C_WEn == 1'b1) begin
    case (I2C_Addr)
      8'h00: PWM[0][7:0] <= I2C_Out;  
      8'h01: PWM[0][15:8] <= I2C_Out;  
      8'h02: PWM[1][7:0] <= I2C_Out;  
      8'h03: PWM[1][15:8] <= I2C_Out;  
      8'h04: PWM[2][7:0] <= I2C_Out;  
      8'h05: PWM[2][15:8] <= I2C_Out;  
      8'h06: PWM[3][7:0] <= I2C_Out;  
      8'h07: PWM[3][15:8] <= I2C_Out;  
      8'h08: PWM[4][7:0] <= I2C_Out;  
      8'h09: PWM[4][15:8] <= I2C_Out;  
      8'h0A: PWM[5][7:0] <= I2C_Out;  
      8'h0B: PWM[5][15:8] <= I2C_Out;  
      8'h0C: PWM[6][7:0] <= I2C_Out;  
      8'h0D: PWM[6][15:8] <= I2C_Out;  
      8'h0E: PWM[7][7:0] <= I2C_Out;  
      8'h0F: PWM[7][15:8] <= I2C_Out;  
      8'h10: begin
			LED_Red_int <= I2C_Out[0];
			LED_Green_int <= I2C_Out[1];
		end
    endcase
  end
end

assign I2C_In = (I2C_Addr[0]==0)?PWM[I2C_Addr[7:1]][7:0]:PWM[I2C_Addr[7:1]][15:8];

// Setup the 1us counter
always @(posedge Clk) begin
  if (MclkDiv_Count==25) begin
    MclkDiv_Count <= 5'h00;
	 UsClk <= !UsClk;
  end
  else
    MclkDiv_Count <= MclkDiv_Count+1;
end

// Setup the 20ms counter
always @(posedge UsClk) begin
  if (PWM_Count==20000) begin
    PWM_Count <= 14'h00;
	 Port0_int<=8'hFF;
  end
  else
    PWM_Count <= PWM_Count+1;
	 if (PWM[0][14:0]==PWM_Count) Port0_int[0]<=0;  
	 if (PWM[1][14:0]==PWM_Count) Port0_int[1]<=0;  
	 if (PWM[2][14:0]==PWM_Count) Port0_int[2]<=0;  
	 if (PWM[3][14:0]==PWM_Count) Port0_int[3]<=0;  
	 if (PWM[4][14:0]==PWM_Count) Port0_int[4]<=0;  
	 if (PWM[5][14:0]==PWM_Count) Port0_int[5]<=0;  
	 if (PWM[6][14:0]==PWM_Count) Port0_int[6]<=0;  
	 if (PWM[7][14:0]==PWM_Count) Port0_int[7]<=0;  
end
endmodule