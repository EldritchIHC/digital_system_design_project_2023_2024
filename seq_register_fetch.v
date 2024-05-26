`include "core_defines.vh"
module seq_register_fetch
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
    output reg [15:0] o_instruction
    );
    /*Instruction register*/
    always@(posedge i_clk, negedge i_rst_n)
    begin   
        if(~i_rst_n)
            o_instruction <= 0;
        else
            if(i_sys_halt)
                o_instruction <= o_instruction;
            else
            begin
                if(i_flush) 
                    o_instruction <= 0;
                else 
                    o_instruction <= i_instruction;
            end            
    end
endmodule
