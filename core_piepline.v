`timescale 1ns / 1ps
`include "core_defines.vh"
module core_pipeline
    #(
      parameter ADDRESS_SIZE = 10,
      parameter DATA_SIZE = 32  
     )
    (
    input wire i_clk,
    input wire i_rst_n,
    input wire i_sys_stop,
    input wire i_sys_start,
    input wire signed [DATA_SIZE - 1:0] i_data,
    input wire [15:0] i_instruction,
    output wire o_read,
    output wire o_write,
    output wire [ADDRESS_SIZE - 1:0] o_address,
    output wire signed [DATA_SIZE - 1:0]o_data,
    output wire [ADDRESS_SIZE - 1:0] o_program_counter
    );
    /*FETCH comb to reg wires*/
    wire [15:0] w_instruction1;
    /*FETCH reg to READ comb wires */
    wire [15:0] w_instruction2;
    /*READ comb to reg wires*/
    wire [15:0] w_instruction3;
    wire [1:0] w_instruction_type1;
    wire [`ALU_LEN - 1:0] w_alu_instruction1;
    wire [`BRL_LEN - 1:0] w_brl_instruction1;
    wire [`MEM_LEN - 1:0] w_mem_instruction1;
    wire [`CTRL_LEN - 1:0] w_ctrl_instruction1;
    wire [5:0] w_value1;
    wire [7:0] w_constant1;
    wire signed [5:0] w_offset1;
    wire [2:0] w_cond1;
    wire [2:0] w_source11;
    wire [2:0] w_source21;
    wire [2:0] w_destination1;
    wire signed [DATA_SIZE - 1:0] w_operand11;
    wire signed [DATA_SIZE - 1:0] w_operand21;
    /*READ reg to EXECUTE comb wires*/
    wire [15:0] w_instruction4;
    wire [1:0] w_instruction_type2;
    wire [`ALU_LEN - 1:0] w_alu_instruction2;
    wire [`BRL_LEN - 1:0] w_brl_instruction2;
    wire [`MEM_LEN - 1:0] w_mem_instruction2;
    wire [`CTRL_LEN - 1:0] w_ctrl_instruction2;
    wire [5:0] w_value2;
    wire [7:0] w_constant2;
    wire signed [5:0] w_offset2;
    wire [2:0] w_cond2;
    wire [2:0] w_destination2;
    wire signed [DATA_SIZE - 1:0] w_operand12;
    wire signed [DATA_SIZE - 1:0] w_operand22;
    
    /*FETCH program counter wires to EXECUTE*/
    wire w_program_counter_load1;
    wire w_program_counter_stop1;
    wire [ADDRESS_SIZE - 1:0] w_program_counter1;//from EXECUTE
    wire [ADDRESS_SIZE - 1:0] w_program_counter2;//to EXECUTE
    /*EXECUTE comb to reg wires*/
    wire [15:0] w_instruction5;
    wire w_data_source1;
    wire [2:0] w_destination3;
    wire signed [DATA_SIZE - 1:0] w_result1;
    wire w_register_file_write1;
    /*EXECUTE reg wires to WRITE comb wires*/
    wire [15:0] w_instruction6;
    wire w_data_source2;
    wire [2:0] w_destination4;
    wire signed [DATA_SIZE - 1:0] w_result2;
    wire w_register_file_write2;
    wire w_flush1;
    /*WRITE comb to register file wires*/
    wire [2:0] w_destination5;
    wire signed [DATA_SIZE - 1:0] w_result3;
    wire w_register_file_write3;
    /*register file to dependecy block wires*/
    wire signed [DATA_SIZE - 1:0] w_operand13;
    wire signed [DATA_SIZE - 1:0] w_operand23;
    /*dependecy block to READ comb wires*/
    wire signed [DATA_SIZE - 1:0] w_operand14;
    wire signed [DATA_SIZE - 1:0] w_operand24;
    /*MUX the data from memory over the operand*/
    wire w_read_operand11;
    wire w_read_operand21;
    wire w_read_operand12;
    wire w_read_operand22;
    wire signed [DATA_SIZE - 1:0] w_read_operand1;
    wire signed [DATA_SIZE - 1:0] w_read_operand2;
    reg r_sys_halt;
    //wire r_sys_halt;
    //assign r_sys_halt = 1;
    
    always@(posedge i_clk)
    begin
        if(i_sys_stop)
            r_sys_halt <= 1;
        else if(i_sys_start)
            r_sys_halt <= 0;
    end
    
    /*FETCH*/
    comb_stage_fetch 
    #(
      .ADDRESS_SIZE(ADDRESS_SIZE),
      .DATA_SIZE(DATA_SIZE) 
     )FETCH_COMB
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_sys_halt(r_sys_halt),
        .i_instruction(i_instruction),
        .i_program_counter_load(w_program_counter_load1),
        .i_program_counter_stop(w_program_counter_stop1),
        .i_program_counter(w_program_counter2),
        .o_program_counter(w_program_counter1),
        .o_instruction(w_instruction1)
    );
    
    seq_register_fetch
    #(
      .ADDRESS_SIZE(ADDRESS_SIZE),
      .DATA_SIZE(DATA_SIZE) 
     )FETCH_REG
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_flush(w_flush1),
        .i_sys_halt(r_sys_halt),
        .i_instruction(w_instruction1),
        .o_instruction(w_instruction2)
    );
    /*READ*/
    comb_stage_read
    #(
      .ADDRESS_SIZE(ADDRESS_SIZE),
      .DATA_SIZE(DATA_SIZE) 
     )READ_COMB
    (
        .i_instruction(w_instruction2),
        .i_operand1(w_operand14),
        .i_operand2(w_operand24),
        .o_instruction_type(w_instruction_type1),
        .o_alu_instruction(w_alu_instruction1),
        .o_brl_instruction(w_brl_instruction1),
        .o_mem_instruction(w_mem_instruction1),
        .o_ctrl_instruction(w_ctrl_instruction1),
        .o_value(w_value1),
        .o_constant(w_constant1),
        .o_offset(w_offset1),
        .o_cond(w_cond1),
        .o_source1(w_source11),
        .o_source2(w_source21),
        .o_destination(w_destination1),
        .o_operand1(w_operand11),
        .o_operand2(w_operand21),
        .o_instruction(w_instruction3)
    );
    
    seq_register_read
    #(
      .ADDRESS_SIZE(ADDRESS_SIZE),
      .DATA_SIZE(DATA_SIZE) 
     )READ_REG
    (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_flush(w_flush1),
        .i_sys_halt(r_sys_halt),
        .i_instruction(w_instruction3),
        .i_instruction_type(w_instruction_type1),
        .i_alu_instruction(w_alu_instruction1),
        .i_brl_instruction(w_brl_instruction1),
        .i_mem_instruction(w_mem_instruction1),
        .i_ctrl_instruction(w_ctrl_instruction1),
        .i_value(w_value1),
        .i_constant(w_constant1),
        .i_offset(w_offset1),
        .i_cond(w_cond1),
        .i_destination(w_destination1),
        .i_operand1(w_operand11),
        .i_operand2(w_operand21),
        .i_read_operand1(w_read_operand11),
        .i_read_operand2(w_read_operand21),
    
        .o_instruction_type(w_instruction_type2),
        .o_alu_instruction(w_alu_instruction2),
        .o_brl_instruction(w_brl_instruction2),
        .o_mem_instruction(w_mem_instruction2),
        .o_ctrl_instruction(w_ctrl_instruction2),
        .o_value(w_value2),
        .o_constant(w_constant2),
        .o_offset(w_offset2),
        .o_cond(w_cond2),
        .o_destination(w_destination2),
        .o_operand1(w_operand12),
        .o_operand2(w_operand22),
        .o_instruction(w_instruction4),
        .o_read_operand1(w_read_operand12),
        .o_read_operand2(w_read_operand22)
    );
    
    /*RAW Data dependency control block*/
    comb_data_dependency_block 
    #(
      .ADDRESS_SIZE(ADDRESS_SIZE),
      .DATA_SIZE(DATA_SIZE)
      )DATA_CONTROL
       (
        .i_instruction_read(w_instruction2),
        .i_instruction_execute(w_instruction4),
        .i_instruction_write(w_instruction6),
        .i_result_execute(w_result1),
        .i_result_write(w_result3),
        .i_operand1(w_operand13),
        .i_operand2(w_operand23),
        .o_operand1(w_operand14),
        .o_operand2(w_operand24),
        .o_read_operand1(w_read_operand11),
        .o_read_operand2(w_read_operand21)
    );
    assign w_read_operand1 = (w_read_operand12)? i_data : w_operand12;
    assign w_read_operand2 = (w_read_operand22)? i_data : w_operand22;
    /*EXECUTE*/
    comb_stage_execute
    #(
      .ADDRESS_SIZE(ADDRESS_SIZE),
      .DATA_SIZE(DATA_SIZE) 
     )EXECUTE_COMB
    ( 
        .i_instruction(w_instruction4),
        .i_instruction_type(w_instruction_type2),
        .i_alu_instruction(w_alu_instruction2),
        .i_brl_instruction(w_brl_instruction2),
        .i_mem_instruction(w_mem_instruction2),
        .i_ctrl_instruction(w_ctrl_instruction2),
        .i_program_counter(w_program_counter1),
        .i_value(w_value2),
        .i_constant(w_constant2),
        .i_offset(w_offset2),
        .i_cond(w_cond2),
        .i_destination(w_destination2),
        .i_operand1(w_read_operand1),
        .i_operand2(w_read_operand2),
        
        .o_data_source(w_data_source1),//0 - ALU result 1 - data memory
        .o_address(o_address),
        .o_data(o_data),
        .o_read(o_read),
        .o_write(o_write),
        .o_program_counter(w_program_counter2),
        .o_program_counter_load(w_program_counter_load1),
        .o_program_counter_stop(w_program_counter_stop1),
        .o_destination(w_destination3),
        .o_result(w_result1),
        .o_register_file_write(w_register_file_write1),
        .o_instruction(w_instruction5),
        .o_flush(w_flush1)
    );
    
    seq_register_execute
    #(
      .ADDRESS_SIZE(ADDRESS_SIZE),
      .DATA_SIZE(DATA_SIZE) 
     )EXECUTE_REG
    (    
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_sys_halt(r_sys_halt),
        .i_instruction(w_instruction5),
        .i_data_source(w_data_source1),
        .i_destination(w_destination3),
        .i_result(w_result1),
        .i_register_file_write(w_register_file_write1),
        
        .o_data_source(w_data_source2),
        .o_destination(w_destination4),
        .o_result(w_result2),
        .o_register_file_write(w_register_file_write2),
        .o_instruction(w_instruction6)

    );
    /*WRITE*/
    comb_stage_write
    #(
      .ADDRESS_SIZE(ADDRESS_SIZE),
      .DATA_SIZE(DATA_SIZE) 
     )WRITE_COMB
    (    
        .i_data_source(w_data_source2),
        .i_destination(w_destination4),
        .i_result(w_result2),
        .i_register_file_write(w_register_file_write2),
        .i_data(i_data),
    
        .o_destination(w_destination5),
        .o_result(w_result3),
        .o_register_file_write(w_register_file_write3)
    );
    /*REGISTER FILE*/
    seq_register_file
    #(
      .ADDRESS_SIZE(ADDRESS_SIZE),
      .DATA_SIZE(DATA_SIZE)  
     )REG_FILE
     (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_source1(w_source11),
        .i_source2(w_source21),
        .i_destination(w_destination5),
        .i_result(w_result3),
        .i_register_file_write(w_register_file_write3),
        .o_operand1(w_operand13),
        .o_operand2(w_operand23)
     );
     assign o_program_counter = w_program_counter1; 
     
endmodule
