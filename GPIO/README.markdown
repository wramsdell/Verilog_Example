Prototype Engineering, LLC Netduino FPGA Shield GPIO Example
============================================================

This is the source package for the Prototype Engineering FPGA shield Green Flashing LED example.

Overview
--------

This example core implements GPIO functionality in the FPGA shield.  
All 64 GPIO pins on the shield are available as either input or output, allocated on a pin-by-pin basis.  
Control is realized through an I2C interface to the Netduino, and these are the only two Netduino pins used.  
Sample Netduino C# code is included in the Netduino_Example repository under "GPIO".  

Implementation Details
----------------------
Each of the FPGA's 64 GPIO has the following bits allocated to it:  

Data (write): reflects the state of the pin when output is enabled, 0 for low, 1 for high.  
OE (write): sets the output enable for the pin.  When this bit is low, the pin acts as an input, when it's high, the pin is an output.  
Input (read): reflects the state of the pin.  If OE is high, this will be identical to the pin's "Data" setting.  If OE is low, this will be the level presented to the pin.  

In addition, the red and green LEDs may also be controlled via register write.  They each have a single bit allocated, "data".  If the LED's data bit is set to 0, the LED is off.  If it's set to 1, the LED is on.

The GPIO and LED bits are logically grouped in register space by the pin's location in the port map; see FPGA shield documentation for port assignment.  The register assignment is as follows:

Write registers:  
    Register address      Function  
    0x00                  PORT0 data, PORT0_0 = register LSB, PORT0_1 = register bit 1...PORT0_7 = register MSB.  
    0x01                  PORT1 data, arrangement as PORT0  
    0x02                  PORT2 data, arrangement as PORT0  
    0x03                  PORT3 data, arrangement as PORT0  
    0x04                  PORT4 data, arrangement as PORT0  
    0x05                  PORT5 data, arrangement as PORT0  
    0x06                  PORT6 data, arrangement as PORT0  
    0x07                  PORT7 data, arrangement as PORT0  
    0x08                  PORT0 OE, PORT0_0 = register LSB, PORT0_1 = register bit 1...PORT0_7 = register MSB  
    0x09                  PORT1 OE, arrangement as PORT0  
    0x0A                  PORT2 OE, arrangement as PORT0  
    0x0B                  PORT3 OE, arrangement as PORT0  
    0x0C                  PORT4 OE, arrangement as PORT0  
    0x0D                  PORT5 OE, arrangement as PORT0  
    0x0E                  PORT6 OE, arrangement as PORT0  
    0x0F                  PORT7 OE, arrangement as PORT0  
    0x10                  LED register, red LED = register LSB, green LED = register bit 1  

Read registers:  
    Register address      Function  
    0x00                  PORT0 input, PORT0_0 = register LSB, PORT0_1 = register bit 1...PORT0_7 = register MSB.  
    0x01                  PORT1 input, arrangement as PORT0  
    0x02                  PORT2 input, arrangement as PORT0  
    0x03                  PORT3 input, arrangement as PORT0  
    0x04                  PORT4 input, arrangement as PORT0  
    0x05                  PORT5 input, arrangement as PORT0  
    0x06                  PORT6 input, arrangement as PORT0  
    0x07                  PORT7 input, arrangement as PORT0  

This core is resident on the Netduino I2C bus at address 0x3C.  All register writes and reads are two bytes each, and of the form "Register Address", "Data".

Examples:
---------
##Pin Write -- sets pin 0 of port 0 high

    //Initialize I2C port
    int I2CClockRateKhz = 400;
    ushort I2CAddress = 0x3c;
    I2CDevice FPGA = new I2CDevice(new I2CDevice.Configuration(I2CAddress, I2CClockRateKhz));

    //Set PORT0_0 OE to output
    byte[] buffer = new byte[2];
    buffer[0] = 0x08; //Address of PORT0's OE register
    buffer[1] = 0x01; //Pin 0 OE = high, output
    var transaction = new I2CDevice.I2CTransaction[]
    {
        I2CDevice.CreateWriteTransaction(buffer)
    };
    FPGA.Execute(transaction, 1000); //Execute the write, timeout after 1000ms
    
    //Set PORT0_0 data high
    buffer[0] = 0x00; //Address of PORT0's data register
    buffer[1] = 0x01; //Pin 0 data = high
    transaction = new I2CDevice.I2CTransaction[]
    {
        I2CDevice.CreateWriteTransaction(buffer)
    };
    FPGA.Execute(transaction, 1000); //Execute the write, timeout after 1000ms

##Pin read -- Reads the state of PORT0_0

    //Initialize I2C port
    int I2CClockRateKhz = 400;
    ushort I2CAddress = 0x3c;
    I2CDevice FPGA = new I2CDevice(new I2CDevice.Configuration(I2CAddress, I2CClockRateKhz));

    //Set PORT0_0 OE to output
    byte[] buffer = new byte[2];
    buffer[0] = 0x08; //Address of PORT0's OE register
    buffer[1] = 0x00; //Pin 0 OE = low, input
    var transaction = new I2CDevice.I2CTransaction[]
    {
        I2CDevice.CreateWriteTransaction(buffer)
    };
    FPGA.Execute(transaction, 1000); //Execute the write, timeout after 1000ms
    
    //Read PORT0
    byte Port = 0x00; //read register for PORT0 data is 0x00
    byte[] ReadBuffer = new byte[1];
    var transaction = new I2CDevice.I2CTransaction[]
    {
        I2CDevice.CreateWriteTransaction(Port),
        I2CDevice.CreateReadTransaction(ReadBuffer)
    };
    FPGA.Execute(transaction, I2CTimeout);
    byte Result = ReadBuffer[0] & 0x01; //Mask out all but PORT0_0