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
module Super_PWM (
    input Clk,
    input MOSI,
    output MISO,
    input SCLK,
    input CS,
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

reg [63:0] Port_i;
reg [63:0] Port_buf;
reg LED_Red_Int;
reg LED_Green_Int;

reg [31:0]R[63:0]; //Rising edge register, 32 bits, array of 64
reg [31:0]F[63:0]; //Falling edge register, 32 bits, array of 64
reg [31:0]P[63:0]; //Period register, 32 bits, array of 64
reg [31:0]Terminate=0; //Master clock terminal count
reg [38:0]Accumulator=0;
wire [31:0]TRsum;
wire [31:0]TFsum;
wire [31:0]TPsum;
wire [5:0]Channel;
wire [31:0]Count;
wire Phase;
reg Run;
wire DFS_Clk;
wire DFS_Clk_180;
wire Buf_Clk;
wire [7:0] Cmd;
wire [7:0] Addr;
wire [7:0] Data0;
wire [7:0] Data1;
wire [7:0] Data2;
wire [7:0] Data3;
wire [5:0] OutStrobe;
wire AddrStrobe; //Pulses when both a command and address (or operand) have been received
wire DataStrobe; //Pulses when all 6 bytes (command, address, 4 data bytes) have been received
reg RAMRead; //Goes high after command and address are valid if it's a read command, valid through end of SPI transaction
reg RAMWrite; //Goes high after command and address are valid if it's a write command, valid through end of SPI transaction
reg [31:0] SPIIn;
reg Init;

wire TR_clka;
reg TR_WE;
wire [31:0]TR_douta;
reg TR_clkb;
wire [31:0]TR_doutb;
wire TF_clka;
reg TF_WE;
wire [31:0]TF_douta;
reg TF_clkb;
wire [31:0]TF_doutb;
wire TP_clka;
reg TP_WE;
wire [31:0]TP_douta;
reg TP_clkb;
wire [31:0]TP_doutb;

assign Port0=Port_i[7:0];
assign Port1=Port_i[15:8];
assign Port2=Port_i[23:16];
assign Port3=Port_i[31:24];
assign Port4=Port_i[39:32];
assign Port5=Port_i[47:40];
assign Port6=Port_i[55:48];
assign Port7=Port_i[63:56];

assign TRsum=Count+TR_doutb;
assign TFsum=Count+TF_doutb;
assign TPsum=Count+TP_doutb;
//assign TRsum=Count+32'h00000000;
//assign TFsum=Count+32'h00000001;
//assign TPsum=Count+32'h00000002;
assign Count = Accumulator[38:7];
assign Channel[5:0] = Accumulator[6:1];
assign Phase = Accumulator[0];
assign TR_clka = AddrStrobe|(DataStrobe&TR_WE);
assign TF_clka = AddrStrobe|(DataStrobe&TF_WE);
assign TP_clka = AddrStrobe|(DataStrobe&TP_WE);
assign LED_Green = LED_Green_Int;
assign LED_Red = LED_Red_Int;
assign AddrStrobe = OutStrobe[1];
assign DataStrobe = OutStrobe[5];

SPI_Slave SS1(
    .CLK(Buf_Clk),
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
    
Clock_Block CB1(
    .Clk_In(Clk),
    .Buffered_Clk_Out(Buf_Clk),
    .Multiplied_Clk_Out(DFS_Clk),
    .Multiplied_Clk_Out_180(DFS_Clk_180)
    );
	 
blk_mem_gen_v4_3 TR_RAM(
	.clka(TR_clka),
	.wea(RAMWrite&TR_WE),
	.addra(Addr[7:2]),
	.dina({Data0,Data1,Data2,Data3}),
	.douta(TR_douta),
	.clkb(TR_clkb),
	.web(4'h0),
	.addrb(Channel),
	.dinb(32'h00000000),
	.doutb(TR_doutb));

blk_mem_gen_v4_3 TF_RAM(
	.clka(TF_clka),
	.wea(RAMWrite&TF_WE),
	.addra(Addr[7:2]),
	.dina({Data0,Data1,Data2,Data3}),
	.douta(TF_douta),
	.clkb(TF_clkb),
	.web(4'h0),
	.addrb(Channel),
	.dinb(32'h00000000),
	.doutb(TF_doutb));

blk_mem_gen_v4_3 TP_RAM(
	.clka(TP_clka),
	.wea(RAMWrite&TP_WE),
	.addra(Addr[7:2]),
	.dina({Data0,Data1,Data2,Data3}),
	.douta(TP_douta),
	.clkb(TP_clkb),
	.web(4'h0),
	.addrb(Channel),
	.dinb(32'h00000000),
	.doutb(TP_doutb));

always @(*) begin
    case (Addr[1:0])
    2'h0: SPIIn = TR_douta;
    2'h1: SPIIn = TF_douta;
    2'h2: SPIIn = TP_douta;
    2'h3: SPIIn = 32'h00000000;
    endcase
end

always @(posedge Buf_Clk) begin
    if (OutStrobe[1]) begin //At this point, both a command and operand have been received
        case (Cmd)
            8'h00: begin //Read register
                RAMRead <= 1;
            end
            8'h01: begin //Write register
                RAMWrite <= 1;
            end
            8'h02: begin //Start/stop PWM
                Run <= Addr[0];
            end
            8'h03: begin //Set/clear green LED
                LED_Green_Int <= Addr[0];
            end
            8'h04: begin //Set/clear red LED
                LED_Red_Int <= Addr[0];
            end
            default: begin
            end
        endcase
    end
    else begin
        if (CS) begin
            RAMRead <= 0;
            RAMWrite <= 0;
        end
    end
end

always @(posedge Buf_Clk) begin
    if (OutStrobe[5]&(Cmd==8'h05)) begin //Kludge to write "Terminate"
        Terminate<={Data0,Data1,Data2,Data3};
    end
end

always @(posedge Buf_Clk) begin
    if (OutStrobe[4]) begin
    case (Addr[1:0])
        2'b00: begin
            TR_WE<=1;
            TF_WE<=0;
            TP_WE<=0;
        end
        2'b01: begin
            TR_WE<=0;
            TF_WE<=1;
            TP_WE<=0;
        end
        2'b10: begin
            TR_WE<=0;
            TF_WE<=0;
            TP_WE<=1;
        end
        default: begin
            TR_WE<=0;
            TF_WE<=0;
            TP_WE<=0;
        end
    endcase
    end
    else if (OutStrobe[5]) begin
        TR_WE<=0;
        TF_WE<=0;
        TP_WE<=0;
    end
end

always @(posedge DFS_Clk) begin
    if (Run==1) begin
        if ((Terminate == 0)|(Accumulator[38:7] != Terminate)) begin
            Accumulator <= Accumulator+1;
            if (Init&(Accumulator[6:0]==7'h7F)) begin
                Accumulator<=0;
                Init<=0;
            end
        end
    end
    else begin
        Accumulator <= 0;
        Init<=1;
    end
end

always @(posedge DFS_Clk) begin
    if (Run) begin
        if ((P[Channel]==Count)|Init) begin
            if (~Phase) begin
                TR_clkb<=1;
                TF_clkb<=1;
                TP_clkb<=1;
            end
            else begin
                TR_clkb<=0;
                TF_clkb<=0;
                TP_clkb<=0;
                R[Channel]<=TRsum;
                F[Channel]<=TFsum;
                P[Channel]<=TPsum;
                if ((TRsum==Count)&~Init) begin
                    Port_buf[Channel]<=1;
                end
                else if ((TFsum==Count)&~Init) begin
                    Port_buf[Channel]<=0;
                end
            end
        end
        if ((R[Channel]==Count)&~Init) begin
            Port_buf[Channel]<=1;
        end
        else if ((F[Channel]==Count)&~Init) begin
            Port_buf[Channel]<=0;
        end
    end
end
    
always @(posedge DFS_Clk) begin
    if (Run) begin
        if (Accumulator[6:0]==7'h7F) begin
            Port_i<=Port_buf;
        end
    end
    else begin
        Port_i<=64'h0000000000000000;
    end
end
endmodule
