`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/16 20:48:24
// Design Name: 
// Module Name: control32
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


module control32(
    input[5:0] Opcode,
    input[21:0] Alu_resultHigh,
    input[5:0] Function_opcode,
    
    output Jrn,//jr
    output RegDST,//R_type
    output ALUSrc,//lw,sw,addi
    output MemorIOtoReg,//lw
    output RegWrite,//lw,R_type,jal,addi,not jr
    output MemRead,
    output MemWrite,
    output IORead,
    output IOWrite,
    output Branch,//beq
    output nBranch,//bne
    output Jmp,//j
    output Jal,//jal
    output I_format,//I_type,not beq,bne,lw,sw
    output Sftmd,//sll and srl
    output[1:0] ALUOp
    );
    wire R_format, isLw, isSw, isAddi, isOri;
    
    assign R_format = (Opcode == 6'h00) ? 1'b1 : 1'b0;
    assign isLw = (Opcode == 6'h23) ? 1'b1 : 1'b0;
    assign isSw = (Opcode == 6'h2b) ? 1'b1 : 1'b0;
    assign isOri = (Opcode == 6'h0d) ? 1'b1 : 1'b0;
    assign isAddi = (Opcode == 6'h08) ? 1'b1 : 1'b0;
    
    assign Branch = (Opcode == 6'h04) ? 1'b1 : 1'b0;
    assign nBranch = (Opcode == 6'h05) ? 1'b1 : 1'b0;
    assign Jmp = (Opcode == 6'h02) ? 1'b1 : 1'b0;
    assign Jal = (Opcode == 6'h03) ? 1'b1 : 1'b0;
    assign Jrn = (R_format && Function_opcode == 6'h08) ? 1'b1 : 1'b0;
    
    assign RegDST = R_format;
    assign ALUSrc = (isLw || isSw || isAddi || isOri || Opcode == 6'h0F) ? 1'b1 : 1'b0;
    assign MemorIOtoReg = isLw;
    assign RegWrite = (isLw || (R_format && !Jrn) || Jal || isAddi || isOri || Opcode == 6'h0F) ? 1'b1 : 1'b0;
    
    assign MemRead = (isLw && Alu_resultHigh[21:0] != 22'H3FFFFF) ? 1'b1 : 1'b0;
    assign MemWrite = (isSw && Alu_resultHigh[21:0] != 22'H3FFFFF) ? 1'b1 : 1'b0;
    assign IORead = (isLw && Alu_resultHigh[21:0] == 22'H3FFFFF) ? 1'b1 : 1'b0;
    assign IOWrite = (isSw && Alu_resultHigh[21:0] == 22'H3FFFFF) ? 1'b1 : 1'b0;
    
    assign I_format = (!R_format && !Branch && !nBranch 
                       && !isLw && !isSw && !Jmp && !Jal) ? 1'b1 : 1'b0;
    
    assign Sftmd = (R_format && (Function_opcode == 6'h00 || Function_opcode == 6'h02 || Function_opcode == 6'h03
    ||Function_opcode == 6'h03||Function_opcode == 6'h06||Function_opcode == 6'h07)) ? 1'b1 : 1'b0;
    assign ALUOp = {(R_format || I_format),(Branch || nBranch)};
endmodule
