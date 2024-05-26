`include "core_defines.vh"
module comb_data_dependency_block
#(
      parameter ADDRESS_SIZE = 10,
      parameter DATA_SIZE = 32  
     )
    (    
    input wire [15:0] i_instruction_read,
    input wire [15:0] i_instruction_execute,
    input wire [15:0] i_instruction_write,
    
    input wire [DATA_SIZE-1:0] i_result_execute,
    input wire [DATA_SIZE-1:0] i_result_write,
    input wire [DATA_SIZE-1:0] i_operand1,
    input wire [DATA_SIZE-1:0] i_operand2,
    output wire [DATA_SIZE-1:0] o_operand1,
    output wire [DATA_SIZE-1:0] o_operand2,
    output reg o_read_operand1,
    output reg o_read_operand2
    
    );
    wire w_forward_operand1_execute_war;
    wire w_forward_operand2_execute_war;
    wire w_forward_operand1_write_war;
    wire w_forward_operand2_write_war;
    wire w_forward_operand1_execute_raw;
    wire w_forward_operand2_execute_raw;
    wire w_forward_operand1_write_raw;
    wire w_forward_operand2_write_raw;
    /*The block that verifies the WAR dependecies*/
    comb_data_dependency_block_war
    #(
      .ADDRESS_SIZE(ADDRESS_SIZE),
      .DATA_SIZE(DATA_SIZE)  
     )WAR_BLOCK
    (    
        .i_instruction_read(i_instruction_read),
        .i_instruction_execute(i_instruction_execute),
        .i_instruction_write(i_instruction_write),
        .o_forward_operand1_execute(w_forward_operand1_execute_war),
        .o_forward_operand2_execute(w_forward_operand2_execute_war),
        .o_forward_operand1_write(w_forward_operand1_write_war),
        .o_forward_operand2_write(w_forward_operand2_write_war)
    );
    /*The block that verifies the RAW dependecies*/
        comb_data_dependency_block_raw
    #(
      .ADDRESS_SIZE(ADDRESS_SIZE),
      .DATA_SIZE(DATA_SIZE)  
     )RAW_BLOCK
    (    
        .i_instruction_read(i_instruction_read),
        .i_instruction_execute(i_instruction_execute),
        .i_instruction_write(i_instruction_write),
        .o_forward_operand1_execute(w_forward_operand1_execute_raw),
        .o_forward_operand2_execute(w_forward_operand2_execute_raw),
        .o_forward_operand1_write(w_forward_operand1_write_raw),
        .o_forward_operand2_write(w_forward_operand2_write_raw)
    );

    /*Generating the mux signal to overwrite the operand in the next stage*/
    always@(*)
    begin
    o_read_operand1 = 0;
    if( (i_instruction_execute[15:11] == `LOAD) && w_forward_operand1_execute_war )
        o_read_operand1 = 1;
    else
        o_read_operand1 = 0;
    end
    /*Generating the mux signal to overlwrite the operand in the next stage*/
    always@(*)
    begin
    o_read_operand2 = 0;
    if( (i_instruction_execute[15:11] == `LOAD) && w_forward_operand2_execute_war )
        o_read_operand2 = 1;
    else
        o_read_operand2 = 0;
    end
    assign o_operand1 = (w_forward_operand1_execute_war) ? i_result_execute :
    (w_forward_operand1_write_war) ? i_result_write : i_operand1;
    assign o_operand2 = (w_forward_operand2_execute_war) ? i_result_execute :
    (w_forward_operand2_write_war) ? i_result_write : i_operand2;
endmodule
