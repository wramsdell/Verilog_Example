module IO_Buffer (
    input [7:0] Output,
    input [15:0] Mode,
    inout [7:0] IO
);

// local wires and regs


assign IO[0] = (Mode[0]) ? Output[0]:1'bz;
assign IO[1] = (Mode[2]) ? Output[1]:1'bz;
assign IO[2] = (Mode[4]) ? Output[2]:1'bz;
assign IO[3] = (Mode[6]) ? Output[3]:1'bz;
assign IO[4] = (Mode[8]) ? Output[4]:1'bz;
assign IO[5] = (Mode[10]) ? Output[5]:1'bz;
assign IO[6] = (Mode[12]) ? Output[6]:1'bz;
assign IO[7] = (Mode[14]) ? Output[7]:1'bz;
assign Input = IO;
endmodule
