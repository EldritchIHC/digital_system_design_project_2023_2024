`include "core_defines.vh"
module comb_stage_write
    #(
      parameter ADDRESS_SIZE = 10,
      parameter DATA_SIZE = 32  
     )
    (    
    input wire i_data_source,
    input wire [2:0] i_destination,
    input wire signed [DATA_SIZE - 1:0] i_result,
    input wire i_register_file_write,
    input wire signed [DATA_SIZE - 1:0]i_data,

    output wire  [2:0] o_destination,
    output wire signed [DATA_SIZE - 1:0] o_result,
    output wire o_register_file_write
    );
    /*Combinational logic for WRITE*/    
    assign o_result = ( i_data_source ) ? i_data : i_result;
    assign o_register_file_write = i_register_file_write;
    assign o_destination = i_destination;
endmodule