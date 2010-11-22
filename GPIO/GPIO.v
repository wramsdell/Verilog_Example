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
module GPIO (
  Clk,
  SDA,
  SCL,
  LED_Green,
  LED_Red,
  Port0,
  Port1,
  Port2,
  Port3,
  Port4,
  Port5,
  Port6,
  Port7
);
input Clk;
inout SDA;
input SCL;
output LED_Green;
output LED_Red;
inout [7:0] Port0;
inout [7:0] Port1;
inout [7:0] Port2;
inout [7:0] Port3;
inout [7:0] Port4;
inout [7:0] Port5;
inout [7:0] Port6;
inout [7:0] Port7;

wire [7:0] I2C_Out;
wire [7:0] I2C_In;
wire [7:0] I2C_Addr;
wire I2C_WEn;
wire [7:0] Input[7:0];
reg [7:0] Output[7:0];
reg [7:0] OE[7:0];
wire [7:0] IO[7:0];
reg LED_Red_int;
reg LED_Green_int;

assign LED_Green=LED_Green_int;
assign LED_Red=LED_Red_int;
assign Port0=IO[0];
assign Port1=IO[1];
assign Port2=IO[2];
assign Port3=IO[3];
assign Port4=IO[4];
assign Port5=IO[5];
assign Port6=IO[6];
assign Port7=IO[7];

OctalTristateIO OTIO0(.Input(Input[0]),.Output(Output[0]),.OE(OE[0]),.IO(IO[0]));
OctalTristateIO OTIO1(.Input(Input[1]),.Output(Output[1]),.OE(OE[1]),.IO(IO[1]));
OctalTristateIO OTIO2(.Input(Input[2]),.Output(Output[2]),.OE(OE[2]),.IO(IO[2]));
OctalTristateIO OTIO3(.Input(Input[3]),.Output(Output[3]),.OE(OE[3]),.IO(IO[3]));
OctalTristateIO OTIO4(.Input(Input[4]),.Output(Output[4]),.OE(OE[4]),.IO(IO[4]));
OctalTristateIO OTIO5(.Input(Input[5]),.Output(Output[5]),.OE(OE[5]),.IO(IO[5]));
OctalTristateIO OTIO6(.Input(Input[6]),.Output(Output[6]),.OE(OE[6]),.IO(IO[6]));
OctalTristateIO OTIO7(.Input(Input[7]),.Output(Output[7]),.OE(OE[7]),.IO(IO[7]));

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
      8'h00: Output[0] <= I2C_Out;  
      8'h01: Output[1] <= I2C_Out;  
      8'h02: Output[2] <= I2C_Out;  
      8'h03: Output[3] <= I2C_Out;  
      8'h04: Output[4] <= I2C_Out;  
      8'h05: Output[5] <= I2C_Out;  
      8'h06: Output[6] <= I2C_Out;  
      8'h07: Output[7] <= I2C_Out;
      8'h08: OE[0] <= I2C_Out;
      8'h09: OE[1] <= I2C_Out;
      8'h0A: OE[2] <= I2C_Out;
      8'h0B: OE[3] <= I2C_Out;
      8'h0C: OE[4] <= I2C_Out;
      8'h0D: OE[5] <= I2C_Out;
      8'h0E: OE[6] <= I2C_Out;
      8'h0F: OE[7] <= I2C_Out;
      8'h10: begin
			LED_Red_int <= I2C_Out[0];
			LED_Green_int <= I2C_Out[1];
		end
    endcase
  end
end

assign I2C_In = Input[I2C_Addr];
endmodule
