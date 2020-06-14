`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/16 21:46:29
// Design Name: 
// Module Name: Ifetc32
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


module Ifetc32(
    output[31:0] Instruction, // the instruction fetched from this module
    output[31:0] PC_plus_4_out, // (pc+4) to ALU which is used by branch type instruction
    input[31:0]  Add_result, // from ALU module£¬the calculated address
    input[31:0]  Read_data_1, // from decoder£¬the address of instruction used by jr instruction
    input Branch, // from controller, while Branch is 1,it means current instruction is beq
    input nBranch, // from controller, while nBranch is 1,it means current instruction is bnq
    input Jmp, // from controller, while Jmp 1,it means current instruction is jump
    input Jal, // from controller, while Jal is 1,it means current instruction is jal
    input Jrn, // from controller, while jrn is 1,it means current instruction is jr
    input Zero, // from ALU, while Zero is 1, it means the ALUresult is zero    
    input clock,reset, // Clock and reset   
    output reg [31:0] opcplus4 // (pc+4) to  decoder which is used by jal instruction
    );
    
    reg[31:0] PC;
    reg[31:0] next_PC;
    
    prgrom instmem(        
        .clka(clock),// input wire clka        
        .addra(PC[15:2]),// input wire [13 : 0] addra        
        .douta(Instruction) // output wire [31 : 0] douta    
    );
    
    
    wire[31:0] PC_plus_4;
    assign PC_plus_4 = PC + 3'b100;
    assign PC_plus_4_out = PC_plus_4[31:2];
    
    always @* 
    begin
        if(Branch && Zero) next_PC = Add_result;
        else if(Branch && !Zero) next_PC = PC_plus_4[31:2];
        else if(nBranch && Zero) next_PC = PC_plus_4[31:2];
        else if(nBranch && !Zero) next_PC = Add_result;
        else if(Jrn) next_PC = Read_data_1;
        else next_PC = PC_plus_4[31:2];
        
        if(Jal) opcplus4 = PC_plus_4[31:2];
    end
    
    always @(negedge clock) 
    begin
        if(reset) PC <= 32'h00000000;   
        else begin           
            //if(Jal) opcplus4 <= PC_plus_4[31:2];
            
            if(Jmp || Jal) PC <= {PC[31:28], Instruction[25:0], 2'b00};
            else PC <= next_PC << 2;
        end
    end
 
endmodule
