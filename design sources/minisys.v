`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/28 22:59:00
// Design Name: 
// Module Name: minisys
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


module minisys_sc(
    input clk,
    input rst,
    output[23:0] led,
    input[23:0] switch
    );
    
    wire[21:0] Alu_resultHigh;
    wire MemorIOtoReg;//lw
    wire MemRead;
    wire MemWrite;
    wire IORead;
    wire IOWrite;

    wire[31:0] read_data;
    wire[31:0] write_data;
    
    wire[31:0] Read_data_1; // from decoder
    wire[31:0] Read_data_2; // from decoder
    wire[31:0] Sign_extend; // from decoder 
         
    wire[1:0] ALUOp; // from controller { (R_format || I_format) , (Branch || nBranch) }
    wire ALUSrc;// from controller, 1 means the 2nd operand is an immedite (except beq??bne??    
    wire I_format;// from controller??1 means I-Type instruction except beq, bne, LW, SW  
    wire Zero; // 1 means the ALUreslut is zero               
    wire Jrn; // from controller, 1 means this is a jr instruction
    wire Sftmd;// from controller, 1 means this is a shift instruction
    wire [31:0] ALU_Result; //  the ALU calculation result
    wire [31:0] Add_Result; //  the calculated address
    
    wire[31:0] Instruction;
    wire Jal;
    wire RegWrite;//enable write
    
    wire RegDst;//choose write register source
    wire[31:0] opcplus4;
    
    wire[31:0] PC_plus_4_out; // (pc+4) to ALU which is used by branch type instruction
    wire[31:0]  Add_result; // from ALU module??the calculated address
    wire Branch; // from controller, while Branch is 1,it means current instruction is beq
    wire nBranch; // from controller, while nBranch is 1,it means current instruction is bnq
    wire Jmp; // from controller, while Jmp 1,it means current instruction is jump    

    wire [31:0] rdata; // data from memory or IO
    wire [31:0] wdata; // data to memory or I/O
    wire [31:0] address; // address to memory
    wire LEDCtrl; // LED CS
    wire SwitchCtrl; // Switch CS
    
    wire [15:0] switchrdata;         // data(16bit) to memorio
    
    wire[15:0] ioread_data; 
    
    
    wire clock;
    cpuclk cpuclk(.clk_in1(clk),.clk_out1(clock));
    
    control32 control(Instruction[31:26], ALU_Result[31:10], Instruction[5:0],
    Jrn, RegDst, ALUSrc, MemorIOtoReg, RegWrite, MemRead, MemWrite, 
    IORead, IOWrite, Branch, nBranch, Jmp, Jal, I_format, Sftmd, ALUOp);
    
    Ifetc32 ifetch(Instruction, PC_plus_4_out, Add_Result,
    Read_data_1, Branch, nBranch, Jmp, Jal, Jrn, Zero, clock, rst, opcplus4);
    
    Idecode32 decoder(Read_data_1, Read_data_2, Instruction, rdata, 
    ALU_Result, Jal, RegWrite, MemorIOtoReg, 
    RegDst, Sign_extend, clock, rst, opcplus4);
    
    Executs32 execut(Read_data_1, Read_data_2, Sign_extend, Instruction[5:0], 
    Instruction[31:26], ALUOp, Instruction[10:6], ALUSrc,I_format, Zero, 
    Jrn, Sftmd, ALU_Result, Add_Result, PC_plus_4_out);
    
    dmemory32 dmem(read_data, address, write_data, MemWrite, clock);
    
    MemOrIo memorio(ALU_Result, MemRead, MemWrite, IORead, IOWrite, 
    read_data, ioread_data, Read_data_2, rdata, write_data, address,
    LEDCtrl, SwitchCtrl);

    switchs switchh(clock, rst, SwitchCtrl, address[1:0], 
    IORead, switchrdata, switch);
    
    ioread ioresd(rst, IORead, SwitchCtrl, switchrdata, ioread_data);
    
    leds ledd(clock, rst, IOWrite, LEDCtrl, address[1:0], 
    write_data[15:0], led);
    
endmodule
