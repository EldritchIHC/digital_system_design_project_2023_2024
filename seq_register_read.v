`include "core_defines.vh"
module seq_register_read
    #(
      parameter ADDRESS_SIZE = 10,
      parameter DATA_SIZE = 32  
     )
    (
    input wire i_clk,
    input wire i_rst_n,
    input wire i_flush,
    input wire i_sys_halt,
    input wire [15:0] i_instruction,
    input wire  [1:0] i_instruction_type,
    input wire  [`ALU_LEN - 1:0] i_alu_instruction,
    input wire  [`BRL_LEN - 1:0] i_brl_instruction,
    input wire  [`MEM_LEN - 1:0] i_mem_instruction,
    input wire  [`CTRL_LEN - 1:0] i_ctrl_instruction,
    input wire  [5:0] i_value,
    input wire  [7:0] i_constant,
    input wire signed [5:0] i_offset,
    input wire  [2:0] i_cond,
    input wire  [2:0] i_destination,
    input wire signed [DATA_SIZE - 1:0] i_operand1,
    input wire signed [DATA_SIZE - 1:0] i_operand2,
    input wire i_read_operand1,
    input wire i_read_operand2,

    output reg [1:0] o_instruction_type,
    output reg [`ALU_LEN - 1:0] o_alu_instruction,
    output reg [`BRL_LEN - 1:0] o_brl_instruction,
    output reg [`MEM_LEN - 1:0] o_mem_instruction,
    output reg [`CTRL_LEN - 1:0] o_ctrl_instruction,
    output reg [5:0] o_value,
    output reg [7:0] o_constant,
    output reg signed [5:0] o_offset,
    output reg [2:0] o_cond,
    output reg [2:0] o_destination,
    output reg signed [DATA_SIZE - 1:0] o_operand1,
    output reg signed [DATA_SIZE - 1:0] o_operand2,
    output reg [15:0] o_instruction,
    output reg o_read_operand1,
    output reg o_read_operand2
    );
    /*READ stage register*/
    always@(posedge i_clk, negedge i_rst_n)
    begin
        if(~i_rst_n)
        begin
            o_operand1 <= 0;
            o_operand2 <= 0;
            o_instruction_type <= 0;
            o_alu_instruction <= 0;
            o_brl_instruction <= 0;
            o_mem_instruction <= 0;
            o_ctrl_instruction <= 0;
            o_value <= 0;
            o_constant <= 0;
            o_offset <= 0;
            o_cond <= 0;
            o_destination <= 0;
            o_operand1 <= 0;
            o_operand2 <= 0;
            o_instruction <= 0;
            o_read_operand1 <= 0;
            o_read_operand2 <= 0;
        end
        else if(i_sys_halt)
            begin
                o_operand1 <= o_operand1;
                o_operand2 <= o_operand2;
                o_instruction_type <= o_instruction_type;
                o_alu_instruction <= o_alu_instruction;
                o_brl_instruction <= o_brl_instruction;
                o_mem_instruction <= o_mem_instruction;
                o_ctrl_instruction <= o_ctrl_instruction;
                o_value <= o_value;
                o_constant <= o_constant;
                o_offset <= o_offset;
                o_cond <= o_cond;
                o_destination <= o_destination;
                o_operand1 <= o_operand1;
                o_operand2 <= o_operand2;
                o_instruction <= o_instruction;
                o_read_operand1 <= o_read_operand1;
                o_read_operand2 <= o_read_operand2;
            end
            else
            begin 
                if(i_flush)
                        begin        
                            o_operand1 <= 0;
                            o_operand2 <= 0;
                            o_instruction_type <= 0;
                            o_alu_instruction <= 0;
                            o_brl_instruction <= 0;
                            o_mem_instruction <= 0;
                            o_ctrl_instruction <= 0;
                            o_value <= 0;
                            o_constant <= 0;
                            o_offset <= 0;
                            o_cond <= 0;
                            o_destination <= 0;
                            o_operand1 <= 0;
                            o_operand2 <= 0;
                            o_instruction <= 0;
                            o_read_operand1 <= 0;
                            o_read_operand2 <= 0;
                        end
                    else
                        begin         
                            o_operand1 <= i_operand1;
                            o_operand2 <= i_operand2;
                            o_instruction_type <= i_instruction_type;
                            o_alu_instruction <= i_alu_instruction;
                            o_brl_instruction <= i_brl_instruction;
                            o_mem_instruction <= i_mem_instruction;
                            o_ctrl_instruction <= i_ctrl_instruction;
                            o_value <= i_value;
                            o_constant <= i_constant;
                            o_offset <= i_offset;
                            o_cond <= i_cond;
                            o_destination <= i_destination;
                            o_operand1 <= i_operand1;
                            o_operand2 <= i_operand2;
                            o_instruction <= i_instruction;
                            o_read_operand1 <= i_read_operand1;
                            o_read_operand2 <= i_read_operand2;
                        end           
        end
     end
endmodule
