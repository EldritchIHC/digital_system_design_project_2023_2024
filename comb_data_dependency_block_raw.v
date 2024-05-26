`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2023 16:00:39
// Design Name: 
// Module Name: comb_data_dependecy_block
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

`include "core_defines.vh"
module comb_data_dependency_block_raw
    #(
      parameter ADDRESS_SIZE = 10,
      parameter DATA_SIZE = 32  
     )
    (    
    input wire [15:0] i_instruction_read,
    input wire [15:0] i_instruction_execute,
    input wire [15:0] i_instruction_write,
    /*
    input wire [DATA_SIZE-1:0] i_result_execute,
    input wire [DATA_SIZE-1:0] i_result_write,
    input wire [DATA_SIZE-1:0] i_operand1,
    input wire [DATA_SIZE-1:0] i_operand2,
    output reg [DATA_SIZE-1:0] o_operand1,
    output reg [DATA_SIZE-1:0] o_operand2
    */
    output reg o_forward_operand1_execute,
    output reg o_forward_operand2_execute,
    output reg o_forward_operand1_write,
    output reg o_forward_operand2_write
    );
    wire w_source1_flag_read;
    wire w_source2_flag_read;
    wire w_source1_flag_execute;
    wire w_source2_flag_execute;
    wire w_source1_flag_write;
    wire w_source2_flag_write;
    wire [2:0] w_source1_read;
    wire [2:0] w_source2_read;
    wire [2:0] w_source1_execute;
    wire [2:0] w_source2_execute;
    wire [2:0] w_source1_write;
    wire [2:0] w_source2_write;
    reg r_mux_operand1_execute;
    reg r_mux_operand2_execute;
    reg r_mux_operand1_write;
    reg r_mux_operand2_write;
    /*Extract the sources during the READ stage*/
    comb_source_extractor SOURCE_EXTRACTOR_READ(
        .i_instruction(i_instruction_read),
        .o_source1_flag(w_source1_flag_read),
        .o_source2_flag(w_source2_flag_read),
        .o_source1(w_source1_read),
        .o_source2(w_source2_read)
        );
        /*Extract the source of the EXECUTE stage*/
    comb_source_extractor SOURCE_EXTRACTOR_EXECUTE(
        .i_instruction(i_instruction_execute),
        .o_source1_flag(w_source1_flag_execute),
        .o_source2_flag(w_source2_flag_execute),
        .o_source1(w_source1_execute),
        .o_source2(w_source2_execute)
        );
        /*Extract the source of the WRITE stage*/
    comb_source_extractor SOURCE_EXTRACTOR_WRITE(
        .i_instruction(i_instruction_write),
        .o_source1_flag(w_source1_flag_write),
        .o_source2_flag(w_source2_flag_write),
        .o_source1(w_source1_write),
        .o_source2(w_source2_write)
        );   
     /*READ - EXECUTE data forwarding select*/
     always@(*)
     begin
     r_mux_operand1_execute = 0;
     r_mux_operand2_execute = 0;
     if( (w_source1_flag_read || w_source2_flag_read) && (w_source1_execute || w_source2_execute) )
        begin
            if(w_source1_read == w_source1_execute)
                r_mux_operand1_execute = 1'b1;
            else 
                r_mux_operand1_execute = 0;
                
            if(w_source2_read == w_source2_execute)
                r_mux_operand2_execute = 1'b1;
            else
                r_mux_operand2_execute = 0;
                
            if(w_source1_read == w_source2_execute)
                r_mux_operand1_execute = 1'b1;
            else 
                r_mux_operand1_execute = 0;
                
            if(w_source2_read == w_source1_execute)
                r_mux_operand2_execute = 1'b1;
            else
                r_mux_operand2_execute = 0;
        end  
     end
      /*READ - WRITE data forwarding select*/
     always@(*)
     begin
     r_mux_operand1_write = 0;
     r_mux_operand2_write = 0;
     if( (w_source1_flag_read || w_source2_flag_read) && (w_source1_write || w_source2_write) )
        begin
            if(w_source1_read == w_source1_write)
                r_mux_operand1_write = 1'b1;
            else 
                r_mux_operand1_write = 0;
                
            if(w_source2_read == w_source2_write)
                r_mux_operand2_write = 1'b1;
            else
                r_mux_operand2_write = 0;
                
            if(w_source1_read == w_source2_write)
                r_mux_operand1_write = 1'b1;
            else 
                r_mux_operand1_write = 0;
                
            if(w_source2_read == w_source1_write)
                r_mux_operand2_write = 1'b1;
            else
                r_mux_operand2_write = 0;
        end  
     end
     /*Operand MUX logic*/
     always@(*) 
     begin
     //o_operand1 = i_operand1;
     //o_operand2 = i_operand2;
     o_forward_operand1_execute = 0;
     o_forward_operand2_execute = 0;
     o_forward_operand1_write = 0;
     o_forward_operand2_write = 0;
     case({r_mux_operand1_execute,r_mux_operand2_execute,r_mux_operand1_write,r_mux_operand2_write})
         4'b1000://8
            begin
                o_forward_operand1_execute = 1;
                o_forward_operand2_execute = 0;
                o_forward_operand1_write = 0;
                o_forward_operand2_write = 0;
            end
         4'b0100://4
            begin
                o_forward_operand1_execute = 0;
                o_forward_operand2_execute = 1;
                o_forward_operand1_write = 0;
                o_forward_operand2_write = 0;
            end
         4'b0010://2
            begin
                o_forward_operand1_execute = 0;
                o_forward_operand2_execute = 0;
                o_forward_operand1_write = 1;
                o_forward_operand2_write = 0;
            end
         4'b0001://1
            begin
                o_forward_operand1_execute = 0;
                o_forward_operand2_execute = 0;
                o_forward_operand1_write = 0;
                o_forward_operand2_write = 1;
            end
            /*Conflict cases*/
        4'b1010://10
            begin
                o_forward_operand1_execute = 1;
                o_forward_operand2_execute = 0;
                o_forward_operand1_write = 0;
                o_forward_operand2_write = 0;
            end
         4'b0101://5
            begin
                o_forward_operand1_execute = 0;
                o_forward_operand2_execute = 1;
                o_forward_operand1_write = 0;
                o_forward_operand2_write = 0;
            end
            /*Same source*/
         4'b1100://12
            begin
                o_forward_operand1_execute = 1;
                o_forward_operand2_execute = 1;
                o_forward_operand1_write = 0;
                o_forward_operand2_write = 0;
            end
         4'b0011://3
            begin
                o_forward_operand1_execute = 0;
                o_forward_operand2_execute = 0;
                o_forward_operand1_write = 1;
                o_forward_operand2_write = 1;
            end
        4'b0000://0
            begin
                o_forward_operand1_execute = 0;
                o_forward_operand2_execute = 0;
                o_forward_operand1_write = 0;
                o_forward_operand2_write = 0;
            end
        4'b0110://6
            begin
                o_forward_operand1_execute = 0;
                o_forward_operand2_execute = 1;
                o_forward_operand1_write = 1;
                o_forward_operand2_write = 0;
            end
        4'b0111://7
            begin
                o_forward_operand1_execute = 0;
                o_forward_operand2_execute = 1;
                o_forward_operand1_write = 1;
                o_forward_operand2_write = 0;
            end
        4'b1001://9
            begin
                //o_operand1 = i_result_execute;
                //o_operand2 = i_result_write;
                o_forward_operand1_execute = 1;
                o_forward_operand2_execute = 0;
                o_forward_operand1_write = 0;
                o_forward_operand2_write = 1;
            end
        4'b1011://11
            begin
                //o_operand1 = i_result_execute;
                //o_operand2 = i_result_write;
                o_forward_operand1_execute = 1;
                o_forward_operand2_execute = 0;
                o_forward_operand1_write = 0;
                o_forward_operand2_write = 1;
            end
        4'b1101://13
            begin
                //o_operand1 = i_result_execute;
                //o_operand2 = i_result_execute;
                o_forward_operand1_execute = 1;
                o_forward_operand2_execute = 1;
                o_forward_operand1_write = 0;
                o_forward_operand2_write = 0;
            end
        4'b1110://14
            begin
                //o_operand1 = i_result_execute;
                //o_operand2 = i_result_execute;
                o_forward_operand1_execute = 1;
                o_forward_operand2_execute = 1;
                o_forward_operand1_write = 0;
                o_forward_operand2_write = 0;
            end
       4'b1111://15
            begin
                //o_operand1 = i_result_execute;
                //o_operand2 = i_result_execute;
                o_forward_operand1_execute = 1;
                o_forward_operand2_execute = 1;
                o_forward_operand1_write = 0;
                o_forward_operand2_write = 0;
            end
     endcase
     end 

     
endmodule
