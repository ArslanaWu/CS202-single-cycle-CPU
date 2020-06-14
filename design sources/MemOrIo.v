`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/12 23:02:34
// Design Name: 
// Module Name: MemOrIo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MemOrIo(caddress,memread, memwrite, ioread, iowrite,
mread_data, ioread_data, wdata, rdata, write_data, address, LEDCtrl, SwitchCtrl);
    input[31:0] caddress; // from alu_result in executs32
    input memread; // read memory, from control32
    input memwrite; // write memory, from control32
    input ioread; // read IO, from control32
    input iowrite; // write IO, from control32
    input[31:0] mread_data; // data from memory
    input[15:0] ioread_data; // data from io,16 bits
    input[31:0] wdata; // the data from idecode32
    output reg[31:0] rdata; // data from memory or IO
    output reg[31:0] write_data; // data to memory or I/O
    output reg [31:0] address; // address to memory
    output reg LEDCtrl; // LED CS
    output reg SwitchCtrl; // Switch CS
 
    always @*
    begin
        address = caddress;
    // It may be read from memory or read from io. The data read from io is the lower 16bit of rdata.
        rdata = (ioread == 1)? {16'b0, ioread_data[15:0]}: mread_data;
        LEDCtrl = (iowrite||ioread);
        SwitchCtrl=(iowrite||ioread);
    end

    always @* begin
        if ((memwrite==1)||(iowrite==1)) //The write operation data to io is written to the lower 16 bits of cwrite_data, and the high 16 bits is 0.
            write_data = wdata;
        else
            write_data = 32'hZZZZZZZZ;
    end
endmodule
