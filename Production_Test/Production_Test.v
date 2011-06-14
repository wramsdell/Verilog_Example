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
module Production_Test (
    input Clk,
    input Button,
    output LED_Green,
    output LED_Red,
    output [13:0] Duino,
    output DuinoTWCK,
    output DuinoTWD,
    output [7:0] Port0,
    output [7:0] Port1,
    output [7:0] Port2,
    output [7:0] Port3,
    output [7:0] Port4,
    output [7:0] Port5,
    output [7:0] Port6,
    output [7:0] Port7
    
);

reg [79:0] testReg=80'h00000000000000000001;
reg [79:0] outReg;
reg [15:0] Count;
reg ledState;

assign {DuinoTWCK,DuinoTWD,Duino,Port7,Port6,Port5,Port4,Port3,Port2,Port1,Port0}=outReg;
assign LED_Green=ledState;
assign LED_Red=!ledState;

always @(posedge Clk) begin
    if (!Button) begin
        if (Count==0) begin
            testReg[79:1]<=testReg[78:0];
            testReg[0]<=testReg[79];
        end
        if (Count==24999) begin //1ms
            outReg<=testReg;
            Count<=Count+1;
        end
        else if (Count==49999) begin //2ms
            outReg<=80'h00000000000000000000;
            Count<=0;
            if (testReg[79]==1) begin
                ledState<=!ledState;
            end
        end
        else begin
            Count<=Count+1;
        end
    end
end
endmodule
