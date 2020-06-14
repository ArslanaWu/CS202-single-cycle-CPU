`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/17 00:30:35
// Design Name: 
// Module Name: Executs32
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


module Executs32(
     input[31:0] Read_data_1, // from decoder
     input[31:0] Read_data_2, // from decoder
     input[31:0] Sign_extend, // from decoder 
        
     input[5:0] Function_opcode,  // from ifetch, instructions[5:0]    
     input[5:0] Exe_opcode, // from ifetch, instruction[31:26]   
          
     input[1:0] ALUOp, // from controller { (R_format || I_format) , (Branch || nBranch) }
     input[4:0] Shamt, // from ifetch, instruction[10:6]    
     
     input ALUSrc,// from controller, 1 means the 2nd operand is an immedite (except beq£¬bne£©    
     input I_format,// from controller£¬1 means I-Type instruction except beq, bne, LW, SW  
     output reg Zero, // 1 means the ALUreslut is zero               
     input Jrn, // from controller, 1 means this is a jr instruction
     input Sftmd,// from controller, 1 means this is a shift instruction
     output reg [31:0] ALU_Result, //  the ALU calculation result
     output reg [31:0] Add_Result, //  the calculated address
     input[31:0]  PC_plus_4 //  from ifetch module            
    );
    
    wire[31:0] Ainput;
    wire[31:0] Binput;
    assign Ainput = Read_data_1;
    assign Binput = (ALUSrc == 0) ? Read_data_2 : Sign_extend; 
    
    wire[2:0] ALU_ctl;
    wire[5:0] Exe_code;
    assign Exe_code = (I_format==0) ? Function_opcode : {3'b000,Exe_opcode[2:0]}; 
    assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1]; 
    assign ALU_ctl[1] = ((!Exe_code[2]) | (!ALUOp[1]));
    assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];
    
    reg[31:0] ALU_output_mux;
    always @(ALU_ctl or Ainput or Binput) begin
    case(ALU_ctl)
        3'b000: ALU_output_mux = Ainput & Binput;
        3'b001: ALU_output_mux = Ainput | Binput;
        3'b010: ALU_output_mux = Ainput + Binput;/////
        3'b011: ALU_output_mux = Ainput + Binput;
        3'b100: ALU_output_mux = Ainput ^ Binput;
        3'b101: ALU_output_mux = {Binput, 16'h0000};///~(Ainput | Binput);
        3'b110: ALU_output_mux = Ainput - Binput;
        3'b111: ALU_output_mux = Ainput - Binput;
        default: ALU_output_mux = 32'h00000000;
    endcase
    end
    
    reg[31:0] Sinput;
    integer s;
    always @* begin
    if(Sftmd)
        case(Function_opcode[2:0])
            3'b000: Sinput = Binput << Shamt;
            3'b010: Sinput = Binput >> Shamt;
            3'b100: Sinput = Binput << Read_data_1[4:0];
            3'b110: Sinput = Binput >> Read_data_1[4:0];
            3'b011: Sinput = $signed(Binput) >>> Shamt;
            3'b111: Sinput = $signed(Binput) >>> Read_data_1[4:0];
            default: Sinput = Binput;
        endcase
    else Sinput = Binput;
    end
    
    always @* 
    begin 
        //set type operation 
       if(((ALU_ctl==3'b111) && (Exe_code[3]==1))||((ALU_ctl[2:1]==2'b11) && (I_format==1)))
           ALU_Result = (Ainput < Binput)? 32'b1 : 32'b0;
       //lui operation        
       else if((ALU_ctl==3'b101) && (I_format==1)) 
           ALU_Result[31:0]={Binput[15:0],{16{1'b0}}};    
       //shift operation        
       else if(Sftmd==1) 
           ALU_Result = Sinput;  
       //other types of operation in ALU         
       else  
           ALU_Result = ALU_output_mux[31:0];
       
       Add_Result = Sign_extend + PC_plus_4;
    end
    
    always @(ALU_Result)
    begin
        if (ALU_Result == 0) Zero = 1;
        else Zero = 0;
    end
    
    
endmodule
