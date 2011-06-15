`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:31:29 02/12/2011 
// Design Name: 
// Module Name:    SPI_SerDes 
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
module SPI_SerDes(
    input [7:0] IN,
    output [7:0] OUT,
    input MOSI,
    output MISO,
    input SCLK,
    input CS,
    input CLK,
    output STROBE
    );
    

reg SCLKRisingEdge; //Pulses for 1 CLK period when a CS-qualified rising edge is detected on SCLK
reg SCLKFallingEdge; //Pulses for 1 CLK period when a CS-qualified falling edge is detected on SCLK
reg SCLKLast; //Retains the state of SCLK on the last CLK rising edge
reg SCLKLast2; //Retains the state of SCLK on the last CLK rising edge
//reg MISOInt; //Internal MISO line
reg [2:0] BitCnt; //Count of which bit we're on
reg [1:0] InLatchCnt;
reg [7:0] DataReceived; //Shift register for received data
reg [7:0] OutInt; //Buffer to hold the module's output data
reg [7:0] InReg;
reg StrobeInt;
reg EOB;

//assign MISO = (CS==1) ? 1'bZ : MISOInt;
assign MISO = (CS==1) ? 1'bZ : InReg[7];
assign OUT = OutInt;
assign STROBE = StrobeInt;
//assign OUT = {4'b0000,SCLKLast,InLatchCnt};
//assign STROBE = SCLKRisingEdge;

//SCLK edge detector
//This block generates a pulse on SCLKRisingEdge given a CS-qualified rising edge of SCLK
always @(posedge CLK) begin
    SCLKLast<=SCLK;
    SCLKLast2<=SCLKLast;
    if (~SCLKLast2&SCLKLast&~CS) begin //SCLK rising edge
        SCLKRisingEdge<=1;
    end
    else begin
        SCLKRisingEdge<=0;
    end
end

//SCLK edge detector
//This block generates a pulse on SCLKFallingEdge given a CS-qualified falling edge of SCLK
always @(posedge CLK) begin
    if (SCLKLast2&~SCLKLast&~CS) begin //SCLK rising edge
        SCLKFallingEdge<=1;
    end
    else begin
        SCLKFallingEdge<=0;
    end
end

//Bit Counter
//This block keeps track of how many bits have been sent over MOSI
always @(posedge CLK) begin
    if (CS) begin //If CS is deasserted, reset the count
        BitCnt<=0;
    end
    else if (SCLKRisingEdge) begin //Otherwise increment
        BitCnt<=BitCnt+1;
    end
end

//MOSI Shift Register
//This block should synthesize as an SRL16, an efficient left-shift register.  It deserializes the incoming MOSI data.
always @(posedge CLK) begin
    if (SCLKRisingEdge) begin
        DataReceived = DataReceived<<1;
        DataReceived[0] = MOSI;
    end
end

//MISO Shift Register
//This block should synthesize as an SRL16, an efficient left-shift register.  It deserializes the incoming MOSI data.
always @(posedge CLK) begin
    if (SCLKFallingEdge) begin
        InReg = InReg<<1;
//        MISOInt <= InReg[7];
    end
    else if (InLatchCnt==2) begin
        InReg=IN;
    end
end

//This block generates the "End of Byte" pulse
always @(posedge CLK) begin
    if (SCLKRisingEdge&(BitCnt==7)) begin
        EOB<=1;
    end
    else begin
        EOB<=0;
    end
end

//This block latches the data into the output register when we have a full byte.
//Note "negedge".  The shift register makes its last move on "posedge", so DataReceived has had 1/2 clock to settle.
//With a 50 MHz clock, that's 10ns.
always @(negedge CLK) begin
    if (EOB) begin  //Trigger on a SCLK edge when we're at bit 7
        OutInt<=DataReceived;
    end
end

//This block drives the output data strobe.
//The output data strobe goes high 1/2 clock after the data is latched in "OutInt".
always @(posedge CLK) begin
    if (EOB) begin
        StrobeInt<=1;
    end
    else begin
        StrobeInt<=0;
    end
end

//This block creates a delay between when the last byte was strobed out, and when the input byte is latched.
always @(posedge CLK) begin
    if (EOB) begin
        InLatchCnt <=1;
    end
    else if (InLatchCnt == 1) begin
        if (SCLKFallingEdge) begin
            InLatchCnt <= 2;
        end
    end
    else if (InLatchCnt == 2) begin
        InLatchCnt <= 0;
    end
end

endmodule
