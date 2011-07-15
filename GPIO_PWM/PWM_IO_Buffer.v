module PWM_IO_Buffer (
    input [7:0] Output,
    input [7:0] PWM,
    input [15:0] Mode,
    inout [7:0] IO
);

// local wires and regs


assign IO[0] = (Mode[1]) ? (Mode[0]?~PWM[0]:PWM[0]):(Mode[0]?Output[0]:1'bz);
assign IO[1] = (Mode[3]) ? (Mode[2]?~PWM[1]:PWM[1]):(Mode[2]?Output[1]:1'bz);
assign IO[2] = (Mode[5]) ? (Mode[4]?~PWM[2]:PWM[2]):(Mode[4]?Output[2]:1'bz);
assign IO[3] = (Mode[7]) ? (Mode[6]?~PWM[3]:PWM[3]):(Mode[6]?Output[3]:1'bz);
assign IO[4] = (Mode[9]) ? (Mode[8]?~PWM[4]:PWM[4]):(Mode[8]?Output[4]:1'bz);
assign IO[5] = (Mode[11]) ? (Mode[10]?~PWM[5]:PWM[5]):(Mode[10]?Output[5]:1'bz);
assign IO[6] = (Mode[13]) ? (Mode[12]?~PWM[6]:PWM[6]):(Mode[12]?Output[6]:1'bz);
assign IO[7] = (Mode[15]) ? (Mode[14]?~PWM[7]:PWM[7]):(Mode[14]?Output[7]:1'bz);
assign Input = IO;
endmodule
