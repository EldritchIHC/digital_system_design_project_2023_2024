`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.12.2023 18:28:43
// Design Name: 
// Module Name: comb_destination_extractor
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
module comb_destination_extractor(
    input wire [15:0] i_instruction,
    output reg o_destination_flag,
    output reg [2:0] o_destination
    );
    
    always@(*)
    begin
    o_destination_flag = 1'b0;
    o_destination = 0;
        case(i_instruction[15:14])
            `ALU_GROUP:
            begin
                if(i_instruction[15:9] == `HALT)
                    begin
                        o_destination_flag = 1'b0;
                        o_destination = 3'd0;
                    end
                else
                    begin
                        o_destination_flag = 1'b1;
                        o_destination = i_instruction[8:6];
                    end
            end
            `BRL_GROUP:
            begin
                o_destination_flag = 1'b1;
                o_destination = i_instruction[8:6];
            end
            `MEM_GROUP:
            begin
                if( (i_instruction[15:11] == `STORE) || (i_instruction[15:11] == `NOP) )
                    begin
                        o_destination_flag = 1'b0;
                        o_destination = 3'd0;
                    end
                else
                    begin
                        o_destination_flag = 1'b1;
                        o_destination = i_instruction[10:8];
                    end                
            end
            `CTRL_GROUP:
            begin
                o_destination_flag = 1'b0;
                o_destination = 3'd0;
            end
        endcase
    end
endmodule
