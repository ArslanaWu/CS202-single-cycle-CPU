`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/16 20:38:14
// Design Name: 
// Module Name: Idecode32
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


module Idecode32(
    output reg[31:0] read_data_1,
    output reg[31:0] read_data_2,
    input[31:0] Instruction,
    input[31:0] read_data,//write data from data memory
    input[31:0] ALU_result,//write data from alu
    input Jal,
    input RegWrite,//enable write
    input MemtoReg,//choose write data source
    input RegDst,//choose write register source
    output reg[31:0] Sign_extend,
    input clock,
    input reset,
    input[31:0] opcplus4    
    );
    
    reg [31:0] registers[31:0];
    
    reg[4:0] write_register_address;//R,$rd or I,$rt
    reg[31:0] write_data;
           
    always @*
    begin
        read_data_1 = registers[Instruction[25:21]];
        read_data_2 = registers[Instruction[20:16]];
        Sign_extend[15:0] = Instruction[15:0];
        if(Instruction[15] == 1'b1) Sign_extend[31:16] = 16'hFFFF;
        else Sign_extend[31:16] = 16'h0000;
        
        
        if(RegDst) write_register_address = Instruction[15:11];
        else write_register_address = Instruction[20:16];
        
        if(MemtoReg) write_data = read_data;
        else write_data = ALU_result;
        
        if(Jal) registers[31] = opcplus4;
    end
    
    integer i;
    always @(posedge clock)
    begin
        if(reset)begin for(i = 0; i < 32; i = i + 1) registers[i] <= 32'h00000000; end
        else if(RegWrite && write_register_address != 0)
            registers[write_register_address] <= write_data;
    end
    
endmodule
