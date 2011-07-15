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
module TAPWM (
    input Clk,
    input RAMWrite,
	 input AddrStrobe,
	 input DataStrobe,
    input [31:0] Terminate,
    input [7:0] Addr,
    input Run,
    input [31:0] DataIn,
    output [31:0] DataOut,
    output [31:0] PWM
);

reg [31:0] PWM_i;
reg [31:0] PWM_buf;

reg [31:0]R[31:0]; //Rising edge register, 32 bits, array of 32
reg [31:0]F[31:0]; //Falling edge register, 32 bits, array of 32
reg [31:0]P[31:0]; //Period register, 32 bits, array of 32
reg [37:0]Accumulator=0;
wire [31:0]TRsum;
wire [31:0]TFsum;
wire [31:0]TPsum;
wire [4:0]Channel;
wire [31:0]Count;
wire Phase;
wire DFS_Clk;
reg Init;

wire TR_SEL;
wire [31:0]TR_douta;
reg RAM_clkb;
wire [31:0]TR_doutb;
wire TF_SEL;
wire [31:0]TF_douta;
wire [31:0]TF_doutb;
wire TP_SEL;
wire [31:0]TP_douta;
wire [31:0]TP_doutb;
wire Tcnt;
wire Clka;

assign PWM=PWM_i;
//assign PWM[31:18]=PWM_i[31:18];
//assign PWM[17]=(RAMWrite&TF_SEL);
//assign PWM[16:0]=PWM_i[16:0];

assign TRsum=Count+TR_doutb;
assign TFsum=Count+TF_doutb;
assign TPsum=Count+TP_doutb;
assign Clka = AddrStrobe|DataStrobe;
assign Count = Accumulator[37:6];
assign Channel = Accumulator[5:1];
assign Phase = Accumulator[0];
assign Tcnt = ((Count==Terminate)&(Terminate!=32'h00000000))?1:0;

Clock_Block CB1(
    .Clk_In(Clk),
    .Multiplied_Clk_Out(DFS_Clk)
    );
	 
blk_mem_gen_v4_3 TR_RAM(
	.clka(Clka),
	.wea(RAMWrite&TR_SEL),
	.addra(Addr[7:2]),
	.dina(DataIn),
	.douta(TR_douta),
	.clkb(RAM_clkb),
	.web(0),
	.addrb(Channel),
	.dinb(32'h00000000),
	.doutb(TR_doutb));

blk_mem_gen_v4_3 TF_RAM(
	.clka(Clka),
	.wea(RAMWrite&TF_SEL),
	.addra(Addr[7:2]),
	.dina(DataIn),
	.douta(TF_douta),
	.clkb(RAM_clkb),
	.web(0),
	.addrb(Channel),
	.dinb(32'h00000000),
	.doutb(TF_doutb));

blk_mem_gen_v4_3 TP_RAM(
	.clka(Clka),
	.wea(RAMWrite&TP_SEL),
	.addra(Addr[7:2]),
	.dina(DataIn),
	.douta(TP_douta),
	.clkb(RAM_clkb),
	.web(0),
	.addrb(Channel),
	.dinb(32'h00000000),
	.doutb(TP_doutb));

assign DataOut = TR_SEL?TR_douta:TF_SEL?TF_douta:TP_SEL?TP_douta:32'h00000000;
assign TR_SEL=(~Addr[1]&~Addr[0]);
assign TF_SEL=(~Addr[1]&Addr[0]);
assign TP_SEL=(Addr[1]&~Addr[0]);

always @(posedge DFS_Clk) begin
    if (Run) begin
        if ({Channel,Phase}==7'h3F) begin
            if (Init==1) begin
					 Accumulator<=0;
					 Init<=0;
            end
				else if (Tcnt) begin
				    Accumulator<=Accumulator;
            end
				else begin
                Accumulator <= Accumulator+1;
            end
        end
		  else begin
		      Accumulator <= Accumulator+1;        
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
                RAM_clkb<=1;
            end
            else begin
                RAM_clkb<=0;
                R[Channel]<=TRsum;
                F[Channel]<=TFsum;
                P[Channel]<=TPsum;
                if ((TRsum==Count)&~Init) begin
                    PWM_buf[Channel]<=1;
                end
                else if ((TFsum==Count)&~Init) begin
                    PWM_buf[Channel]<=0;
                end
            end
        end
        if ((R[Channel]==Count)&~Init) begin
            PWM_buf[Channel]<=1;
        end
        else if ((F[Channel]==Count)&~Init) begin
            PWM_buf[Channel]<=0;
        end
    end
	 else begin
		  PWM_buf<=32'h00000000;
	 end
end
    
always @(posedge DFS_Clk) begin
    if (Run) begin
        if ({Channel,Phase}==7'h3F) begin
            PWM_i<=PWM_buf;
        end
    end
    else begin
        PWM_i<=32'h00000000;
    end
end
endmodule
