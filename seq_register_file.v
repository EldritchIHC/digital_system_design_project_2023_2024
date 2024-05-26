`include "core_defines.vh"
module seq_register_file
    #(
      parameter ADDRESS_SIZE = 10,
      parameter DATA_SIZE = 32  
     )
     (
    input wire i_clk,
    input wire i_rst_n,
    //input wire i_sys_halt,
    input wire [2:0] i_source1,
    input wire [2:0] i_source2,
    input wire [2:0] i_destination,
    input wire [DATA_SIZE - 1:0] i_result,
    input wire i_register_file_write,
    output wire [DATA_SIZE - 1:0] o_operand1,
    output wire [DATA_SIZE - 1:0] o_operand2
     );
     /*  Core Registers R0 - R7 */
    reg signed [DATA_SIZE - 1 : 0] r_register_file [0:7];
    
    /*Synchronous write*/
    always@(posedge i_clk, negedge i_rst_n)
    begin
        if(~i_rst_n)
            begin               
                r_register_file[`R0] <= 0;
                r_register_file[`R1] <= 0;
                r_register_file[`R2] <= 0;
                r_register_file[`R3] <= 0;
                r_register_file[`R4] <= 0;
                r_register_file[`R5] <= 0;
                r_register_file[`R6] <= 0;
                r_register_file[`R7] <= 0;                          
            end
        else if(i_register_file_write) 
                r_register_file[i_destination] <= i_result;      
   end
   /*Asynchronous read*/ 
   assign o_operand1 = r_register_file[i_source1];
   assign o_operand2 = r_register_file[i_source2];
     
 endmodule 
