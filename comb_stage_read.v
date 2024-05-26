`include "core_defines.vh"
module comb_stage_read
    #(
      parameter ADDRESS_SIZE = 10,
      parameter DATA_SIZE = 32  
     )
    (
    input wire [15:0] i_instruction,
    input wire signed [DATA_SIZE - 1:0] i_operand1,
    input wire signed [DATA_SIZE - 1:0] i_operand2,
    output wire [1:0] o_instruction_type,
    output reg [`ALU_LEN - 1:0] o_alu_instruction,
    output reg [`BRL_LEN - 1:0] o_brl_instruction,
    output reg [`MEM_LEN - 1:0] o_mem_instruction,
    output reg [`CTRL_LEN - 1:0] o_ctrl_instruction,
    output reg [5:0] o_value,
    output reg [7:0] o_constant,
    output reg signed [5:0] o_offset,
    output reg [2:0] o_cond,
    output reg [2:0] o_source1,
    output reg [2:0] o_source2,
    output reg [2:0] o_destination,
    output wire signed [DATA_SIZE - 1:0] o_operand1,
    output wire signed [DATA_SIZE - 1:0] o_operand2,
    output wire [15:0] o_instruction
    );
    /*Instruction decoder*/
    always@(*)  
    begin
       
       o_alu_instruction = 0;
       o_brl_instruction = 0;
       o_mem_instruction = 0;
       o_ctrl_instruction = 0;
       o_value = 0;
       o_constant = 0;
       o_offset = 0;
       o_cond = 0;
       o_source1 = 0; 
       o_source2 = 0;
       o_destination = 0;
       /*Decode by instruction group*/
       case(i_instruction[15:14])
       /*=======================================================*/
        `ALU_GROUP:
            begin             
                o_alu_instruction = i_instruction[15:9];
                o_destination = i_instruction[8:6];//operand0
                o_source1 = i_instruction[5:3];
                o_source2 = i_instruction[2:0]; 
            end//ALU
        /*=======================================================*/
        `BRL_GROUP:
            begin
                o_brl_instruction = i_instruction[15:9];
                o_destination = i_instruction[8:6];//Operand0 as destination
                o_source1 = 0;//de verificat
                o_source2 = i_instruction[8:6];//Operand0 as a source
                o_value = i_instruction[5:0];              
            end//BRL
        /*=======================================================*/
        `MEM_GROUP:
            begin
                o_mem_instruction = i_instruction[15:11];
                o_destination = i_instruction[10:8];//Operand0 as destination
                o_source2 = i_instruction[10:8];//Operand0 as a source
                o_source1 = i_instruction[2:0];
                o_constant = i_instruction[7:0];              
            end//MEM
        /*=======================================================*/
        `CTRL_GROUP:
            begin
                o_ctrl_instruction = i_instruction[15:12];
                o_destination = 0;
                o_source2 = i_instruction[8:6];//Operand0 as a source
                o_source1 = i_instruction[2:0];//operand 0 for JMP
                o_offset = i_instruction[5:0];
                o_cond  = i_instruction[11:9];                
            end//CTRL
  
        default: 
            begin
                o_source1 = 0;
                o_source2 = 0;
            end
        
        endcase//Instruction
    end
    assign o_operand1 = i_operand1;
    assign o_operand2 = i_operand2;
    assign o_instruction_type = i_instruction[15:14]; 
    assign o_instruction = i_instruction;
endmodule
