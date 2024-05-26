`include "core_defines.vh"
module seq_register_execute
    #(
      parameter ADDRESS_SIZE = 10,
      parameter DATA_SIZE = 32  
     )
    (
    input wire [15:0] i_instruction,    
    input wire i_clk,
    input wire i_rst_n,
    input wire i_sys_halt,
    input wire i_data_source,
    input wire [2:0] i_destination,
    input wire signed [DATA_SIZE - 1:0] i_result,
    input wire i_register_file_write,
    
    output reg o_data_source,
    output reg [2:0] o_destination,
    output reg signed [DATA_SIZE - 1:0] o_result,
    output reg o_register_file_write,
    output reg [15:0] o_instruction
    );
    /*EXECUTE stage register*/
    always@(posedge i_clk, negedge i_rst_n)
    begin
        if(~i_rst_n)
            begin
                o_destination <= 0;
                o_result <= 0;
                o_register_file_write <= 0;
                o_data_source <= 0;
                o_instruction <= 0;
            end
        else if(i_sys_halt)
                begin
                    o_destination <= o_destination;
                    o_result <= o_result;
                    o_register_file_write <= o_register_file_write;
                    o_data_source <= o_data_source;
                    o_instruction <= o_instruction;
                end
        else 
            begin
                o_destination <= i_destination;
                o_result <= i_result;
                o_register_file_write <= i_register_file_write;
                o_data_source <= i_data_source;
                o_instruction <= i_instruction;
            end           
    end
endmodule