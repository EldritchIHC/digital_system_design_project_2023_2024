`include "core_defines.vh"
module comb_stage_fetch
    #(
      parameter ADDRESS_SIZE = 10,
      parameter DATA_SIZE = 32 
     )
    (
    input wire i_clk,
    input wire i_rst_n,
    input wire i_sys_halt,
    input wire [15:0] i_instruction,
    input wire i_program_counter_load,
    input wire i_program_counter_stop,
    input wire [ADDRESS_SIZE - 1:0] i_program_counter,
    output wire [ADDRESS_SIZE - 1:0] o_program_counter,
    output wire [15:0] o_instruction
    );
    /*Program Counter*/
    reg [ADDRESS_SIZE - 1:0] r_program_counter;
    always@(posedge i_clk, negedge i_rst_n)
    begin
        if(~i_rst_n)
            r_program_counter <= 0;
        else if(i_sys_halt)
            r_program_counter <= r_program_counter;
        else case( { i_program_counter_load, i_program_counter_stop} )
                2'b00: r_program_counter <= r_program_counter + 1;//PC increment
                2'b01: r_program_counter <= r_program_counter;//PC stop 
                2'b10: r_program_counter <= i_program_counter;//PC load
                2'b11: r_program_counter <= r_program_counter;//PC stop
            endcase
    end
    /*Combinational logic for FETCH*/
    assign o_program_counter = r_program_counter;
    assign o_instruction = i_instruction;
endmodule
