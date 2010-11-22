module OctalTristateIO (
  Input,
  Output,
  OE,
  IO
);

// local wires and regs
input [7:0] Output;
input [7:0] OE;
inout [7:0] IO;
output [7:0] Input;

assign IO[0] = (OE[0] == 1'b1) ? Output[0] : 1'bz;
assign IO[1] = (OE[1] == 1'b1) ? Output[1] : 1'bz;
assign IO[2] = (OE[2] == 1'b1) ? Output[2] : 1'bz;
assign IO[3] = (OE[3] == 1'b1) ? Output[3] : 1'bz;
assign IO[4] = (OE[4] == 1'b1) ? Output[4] : 1'bz;
assign IO[5] = (OE[5] == 1'b1) ? Output[5] : 1'bz;
assign IO[6] = (OE[6] == 1'b1) ? Output[6] : 1'bz;
assign IO[7] = (OE[7] == 1'b1) ? Output[7] : 1'bz;
assign Input = IO;
endmodule
