// Module to initiate a MultiBoot reconfiguration of a Spartan-3A, Spartan-3AN or
// Spartan-3A DSP device.
//
// To initiate a MultiBoot reconfiguration drive the 'trigger' input High for at
// least one rising edge of 'clk' which should be connected to a free running clock.
//
//
// IMPORTANT - The configuration image of the design in which this module is included
//             must be generated with the 'next_config_addr:aaaaaa' option where
//             'aaaaaa' represents the 24-bit address of the MultiBoot target image
//             as a 6-character hexadecimal number.
//
//
// Correct synthesis of this macro should result in an efficient implementation
// containing 9 SRL16E shift registers and result in a total size of 10 slices.
//
//    Number of ICAP_SPARTAN3As: 1
//    Number of occupied Slices: 10
//       Number of Slice Flip Flops: 13
//       Total Number of 4 input LUTs: 10
//          Number used as logic: 1
//          Number used as Shift registers: 9
//
//
//
// Nick Sawyer - Xilinx Ltd.
//
// 24th June 2008
//
//
//
////////////////////////////////////////////////////////////////////////////////////
//
// NOTICE:
//
// Copyright Xilinx, Inc. 2008.   This code may be contain portions patented by other
// third parties.  By providing this core as one possible implementation of a standard,
// Xilinx is making no representation that the provided implementation of this standard
// is free from any claims of infringement by any third party.  Xilinx expressly
// disclaims any warranty with respect to the adequacy of the implementation, including
// but not limited to any warranty or representation that the implementation is free
// from claims of any third party.  Furthermore, Xilinx is providing this core as a
// courtesy to you and suggests that you contact all third parties to obtain the
// necessary rights to use this implementation.
//
////////////////////////////////////////////////////////////////////////////////////
//
//
`timescale 1 ps / 1ps

module multiboot_trigger (
input	trigger,
input	clk);

//
////////////////////////////////////////////////////////////////////////////////////
//
// Signals used to control ICAP
////////////////////////////////////////////////////////////////////////////////////
//
wire  	[7:0]	icap_i         ; //
wire  		icap_ce        ; // : std_logic := 1'b1;
wire  		icap_write     ; // : std_logic := 1'b1;
reg  		icap_clk       ; // : std_logic := 1'b0;
reg  		icap_next_en   ; // : std_logic := 1'b0;
reg  		icap_prepare   ; // : std_logic := 1'b0;
reg  	[7:0]	icap_byte0     = 16'h00 ; //Preamble of two clock cycles
reg  	[7:0]	icap_byte1     = 16'h00 ;
reg  	[7:0]	icap_byte2     = 16'hAA ; //Start of initiation sequence 'SYNC WORD' = AA 99
reg  	[7:0]	icap_byte3     = 16'h99 ;
reg  	[7:0]	icap_byte4     = 16'h32 ; //Write 'GENERAL1' = 32 61
reg  	[7:0]	icap_byte5     = 16'h61 ;
reg  	[7:0]	icap_byte6     = 16'h00 ; //Second Image Address (low word) = 00 00
reg  	[7:0]	icap_byte7     = 16'h00 ;
reg  	[7:0]	icap_byte8     = 16'h32 ; //Write 'GENERAL2' = 32 81
reg  	[7:0]	icap_byte9     = 16'h81 ;
reg  	[7:0]	icap_byte10    = 16'h00 ; //Second Image Address (high word) = 00 02
reg  	[7:0]	icap_byte11    = 16'h02 ;
reg  	[7:0]	icap_byte12    = 16'h30 ; //'Type 1 Write CMD' = 30 A1
reg  	[7:0]	icap_byte13    = 16'hA1 ;
reg  	[7:0]	icap_byte14    = 16'h00 ; //'REBOOT' command = 00 0E
reg  	[7:0]	icap_byte15    = 16'hEE ;
reg  	[7:0]	icap_byte16    = 16'h20 ; //'No Op' = 20 00
reg  	[7:0]	icap_byte17    = 16'h00 ;
reg  	[7:0]	icap_byte18    = 16'h00 ; //Postamble of two clock cycles
reg  	[7:0]	icap_byte19    = 16'h00 ;
reg  	[11:0]	icap_write_en  = 12'b110000000011 ;   //active low write enable
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Start of circuit description
//

  //
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Instantiate the ICAP primitive
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  // Note that the 8-bit data ports 'i' and 'o' of the ICAP primitive are defined in such a way that bit0 is the
  // most significant bit (MSB) and bit7 is the least significant bit (LSB). Also note that 'write' and 'ce' are
  // active Low controls.
  //
  // Please refer to UG332 'Spartan-3 Generation Configuration User Guide for more details.
  //

ICAP_SPARTAN3A  config_port(
	.I	(icap_i),
 	.O 	(),
 	.CE	(icap_ce),
 	.WRITE	(icap_write),
 	.BUSY 	(),
 	.CLK 	(icap_clk));

  //
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // ICAP MultiBoot sequence controller
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //

always @ (posedge clk)
  begin

      //
      // Start the trigger sequence by driving 'icap_trigger' High for one or more clock cycles.
      // This starts the state machine which generates a clock pulse to the ICAP port once every
      // three cycles of the system clock.
      //

      if ((trigger == 1'b1 && icap_clk == 1'b0 && icap_prepare == 1'b0) || icap_next_en == 1'b1) begin
        icap_prepare <= 1'b1;
      end else begin
        icap_prepare <= 1'b0;
      end

      if (icap_prepare == 1'b1) begin
        icap_clk <= 1'b1;
      end else begin
        icap_clk <= 1'b0;
      end

      if (icap_clk == 1'b1) begin
        icap_next_en <= 1'b1;
      end else begin
        icap_next_en <= 1'b0;
      end

      //
      // After each clock pulse the data sequence and write enable applied to the ICAP port is
      // advanced by one position. The clock pulse is centred within the data window making the
      // timing violations practically impossible.
      //

      if (icap_next_en == 1'b1) begin
        icap_byte0 <= icap_byte1;
        icap_byte1 <= icap_byte2;
        icap_byte2 <= icap_byte3;
        icap_byte3 <= icap_byte4;
        icap_byte4 <= icap_byte5;
        icap_byte5 <= icap_byte6;
        icap_byte6 <= icap_byte7;
        icap_byte7 <= icap_byte8;
        icap_byte8 <= icap_byte9;
        icap_byte9 <= icap_byte10;
        icap_byte10 <= icap_byte11;
        icap_byte11 <= icap_byte12;
        icap_byte12 <= icap_byte13;
        icap_byte13 <= icap_byte14;
        icap_byte14 <= icap_byte15;
        icap_byte15 <= icap_byte16;
        icap_byte16 <= icap_byte17;
        icap_byte17 <= icap_byte18;
        icap_byte18 <= icap_byte19;
        icap_byte19 <= icap_byte0;
        icap_write_en <= {icap_write_en[0], icap_write_en[11:1]};
      end

  end

  //
  // The 8-bit data ports 'i' and 'o' of the ICAP primitive are defined in such a way that bit0 is the
  // most significant bit (MSB) and bit7 is the least significant bit (LSB). The signal vectors in this
  // design have been defined to enable a more natural look and feel and therefore the bit order needs
  // to be reversed when connecting to the 'i' port. There are less verbose ways to describe this in
  // VHDL but the following coding style is to emphasize this bit reversed connection.
  //

  assign icap_i[0] = icap_byte0[7];     //Ensure order of bits are reversed
  assign icap_i[1] = icap_byte0[6];
  assign icap_i[2] = icap_byte0[5];
  assign icap_i[3] = icap_byte0[4];
  assign icap_i[4] = icap_byte0[3];
  assign icap_i[5] = icap_byte0[2];
  assign icap_i[6] = icap_byte0[1];
  assign icap_i[7] = icap_byte0[0];

  assign icap_write = icap_write_en[0];
  assign icap_ce = icap_write_en[0];

  //
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// END OF FILE multiboot_trigger.vhd
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

