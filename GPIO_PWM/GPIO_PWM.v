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
module GPIO_PWM (
    input Clk_In,
    input MOSI,
    output MISO,
    inout SCLK,
    input CS,
	 input Button,
    output LED_Green,
    output LED_Red,
    inout [7:0] Port0,
    inout [7:0] Port1,
    inout [7:0] Port2,
    inout [7:0] Port3,
    inout [7:0] Port4,
    inout [7:0] Port5,
    inout [7:0] Port6,
    inout [7:0] Port7
);

reg LED_Red_Int;
reg LED_Green_Int;

reg Run;
wire [7:0] Cmd;
wire [7:0] Addr;
wire [7:0] Data0;
wire [7:0] Data1;
wire [7:0] Data2;
wire [7:0] Data3;
wire [5:0] OutStrobe;
wire [31:0] PWM;
reg [31:0] SPIIn;
reg [1:0] Mode[63:0];
wire [7:0] Port_i[7:0];
reg [63:0] Out;
wire [7:0] In[7:0];
reg [31:0] Terminate;
reg RAMRead;
reg RAMWrite;
wire [31:0]DataOut;

assign Port0=Port_i[0];
assign Port1=Port_i[1];
assign Port2=Port_i[2];
assign Port3=Port_i[3];
assign Port4=Port_i[4];
assign Port5=Port_i[5];
assign Port6=Port_i[6];
assign Port7=Port_i[7];

PWM_IO_Buffer IOB0(.Output(Out[7:0]),.PWM(PWM[7:0]),.Mode({Mode[7],Mode[6],Mode[5],Mode[4],Mode[3],Mode[2],Mode[1],Mode[0]}),.IO(Port_i[0]));
PWM_IO_Buffer IOB1(.Output(Out[15:8]),.PWM(PWM[15:8]),.Mode({Mode[15],Mode[14],Mode[13],Mode[12],Mode[11],Mode[10],Mode[9],Mode[8]}),.IO(Port_i[1]));
PWM_IO_Buffer IOB2(.Output(Out[23:16]),.PWM(PWM[23:16]),.Mode({Mode[23],Mode[22],Mode[21],Mode[20],Mode[19],Mode[18],Mode[17],Mode[16]}),.IO(Port_i[2]));
PWM_IO_Buffer IOB3(.Output(Out[31:24]),.PWM(PWM[31:24]),.Mode({Mode[31],Mode[30],Mode[29],Mode[28],Mode[27],Mode[26],Mode[25],Mode[24]}),.IO(Port_i[3]));
IO_Buffer IOB4(.Output(Out[39:32]),.Mode({Mode[39],Mode[38],Mode[37],Mode[36],Mode[35],Mode[34],Mode[33],Mode[32]}),.IO(Port_i[4]));
IO_Buffer IOB5(.Output(Out[47:40]),.Mode({Mode[47],Mode[46],Mode[45],Mode[44],Mode[43],Mode[42],Mode[41],Mode[40]}),.IO(Port_i[5]));
IO_Buffer IOB6(.Output(Out[55:48]),.Mode({Mode[55],Mode[54],Mode[53],Mode[52],Mode[51],Mode[50],Mode[49],Mode[48]}),.IO(Port_i[6]));
IO_Buffer IOB7(.Output(Out[63:56]),.Mode({Mode[63],Mode[62],Mode[61],Mode[60],Mode[59],Mode[58],Mode[57],Mode[56]}),.IO(Port_i[7]));

assign LED_Green = LED_Green_Int;
assign LED_Red = LED_Red_Int;
assign AddrStrobe = OutStrobe[1];
assign DataStrobe = OutStrobe[5];

SPI_Slave SS1(
    .CLK(Clk),
    .MISO(MISO),
    .MOSI(MOSI),
    .SCLK(SCLK),
    .CS(CS),
    .OUT0(Cmd),
    .OUT1(Addr),
    .OUT2(Data0),
    .OUT3(Data1),
    .OUT4(Data2),
    .OUT5(Data3),
    .OUTSTROBE(OutStrobe),
    .IN(SPIIn)
    );

TAPWM PWM1(
    .Clk(Clk),
    .Addr(Addr),
    .RAMWrite(RAMWrite),
	 .AddrStrobe(AddrStrobe),
	 .DataStrobe(DataStrobe),
    .Terminate(Terminate),
    .Run(Run),
    .DataIn({Data0,Data1,Data2,Data3}),
    .DataOut(DataOut),
    .PWM(PWM)
);

BUFG  CLK_BUFG_INST_1 (.I(Clk_In), 
                      .O(Clk));
							 
//The following are two-byte commands, of the form COMMAND, OPERAND or COMMAND, ADDRESS
always @(posedge Clk) begin
    if (AddrStrobe) begin //At this point, both a command and operand have been received
        case (Cmd)
            8'h00: begin //Read register
                RAMRead <= 1;
            end
            8'h02: begin //Set/clear green LED
                LED_Green_Int <= Addr[0];
            end
            8'h03: begin //Set/clear red LED
                LED_Red_Int <= Addr[0];
            end
            8'h04: begin //Read button state
                SPIIn <= Button;
            end
            8'h05: begin //Start/stop PWM
                Run <= Addr[0];
            end
				//8'06 Set Terminate Count, handled separately
            8'h07: begin //Read Terminate count
                SPIIn <= Terminate;
            end
            8'h08: begin //Set pin = input
				    Mode[Addr[5:0]]<=2'b00;
            end
            8'h09: begin //Set pin = output
				    Mode[Addr[5:0]]<=2'b01;
            end
            8'h0A: begin //Set pin = ~PWM
				    Mode[Addr[5:0]]<=2'b10;
            end
            8'h0B: begin //Set pin = PWM
				    Mode[Addr[5:0]]<=2'b11;
            end
            8'h0C: begin
                SPIIn <= Mode[Addr[5:0]];
            end
            8'h11: begin
                SPIIn<=Out[31:0];
            end
            8'h12: begin
                SPIIn<=Out[63:32];
            end
            8'h13: begin
                SPIIn<={Port_i[3],Port_i[2],Port_i[1],Port_i[0]};
            end
            8'h14: begin
                SPIIn<={Port_i[7],Port_i[6],Port_i[5],Port_i[4]};
            end
            8'hFF: begin
                SPIIn<=32'h00010001;
            end
            default: begin
            end
        endcase
    end
	 else begin
	     if (RAMRead) begin
		      RAMRead<=0;
				SPIIn<=DataOut;
        end
    end
end

always @(posedge Clk) begin
    if (OutStrobe[4]) begin
        if (Cmd==8'h01) begin
		      RAMWrite<=1;
        end
    end
    else if (CS) begin
	     RAMWrite<=0;
    end
end

//The following are six-byte commands, of the form COMMAND, ADDRESS, DATA (4 bytes)
always @(posedge Clk) begin
    if (DataStrobe) begin //At this point, all 4 bytes have been received
        case (Cmd)
            8'h06: begin
                Terminate<={Data0,Data1,Data2,Data3};
            end
            8'h0D: begin
                Out[31:0]<={Data0,Data1,Data2,Data3};
            end
            8'h0E: begin
                Out[63:32]<={Data0,Data1,Data2,Data3};
            end
            default: begin
            end
        endcase
    end
end
PULLDOWN PD3(.O (SCLK));
endmodule
