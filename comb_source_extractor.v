`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.12.2023 18:01:55
// Design Name: 
// Module Name: comb_source_extractor
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
module comb_source_extractor(
    input wire [15:0] i_instruction,
    output reg o_source1_flag,
    output reg o_source2_flag,
    output reg [2:0] o_source1,
    output reg [2:0] o_source2
    );
    
    always@(*)
    begin
    o_source1_flag = 0;
    o_source2_flag = 0;
    o_source1 = 0;
    o_source2 = 0;
        case(i_instruction[15:14])
            `ALU_GROUP:
            begin
                if(i_instruction[15:9] == `HALT)
                    begin
                        o_source1_flag = 1'b0;
                        o_source2_flag = 1'b0;
                        o_source1 = 3'd0;
                        o_source2 = 3'd0;
                    end
                else
                    begin
                        o_source1_flag = 1'b1;
                        o_source2_flag = 1'b1;
                        o_source1 = i_instruction[5:3];
                        o_source2 = i_instruction[2:0];
                    end
            end
            `BRL_GROUP:
            begin
                o_source2_flag = 1'b1;
                o_source1_flag = 1'b0;
                o_source2 = i_instruction[8:6];
                o_source1 = 3'd0;
            end
            `MEM_GROUP:
            begin
                case(i_instruction[15:11])
                `LOADC:
                     begin
                       o_source1_flag = 1'b0; 
                       o_source2_flag = 1'b1;
                       o_source1 = 3'd0;
                       o_source2 = i_instruction[10:8];
                    end
                `LOAD:
                     begin
                       o_source1_flag = 1'b1; 
                       o_source2_flag = 1'b0;
                       o_source1 = i_instruction[2:0];
                       o_source2 = 3'd0;
                    end
                `STORE:
                     begin
                       o_source1_flag = 1'b1; 
                       o_source2_flag = 1'b1;
                       o_source1 = i_instruction[2:0];
                       o_source2 = i_instruction[10:8];
                    end
                default:
                    begin
                       o_source1_flag = 1'b0; 
                       o_source2_flag = 1'b0;
                       o_source1 = 3'd0;
                       o_source2 = 3'd0;
                    end
                endcase
            end
            `CTRL_GROUP:
            begin
                case(i_instruction[15:12])
                `JMP:
                     begin
                       o_source1_flag = 1'b1; 
                       o_source2_flag = 1'b0;
                       o_source1 = i_instruction[2:0];
                       o_source2 = 3'd0;
                    end
                `JMPR:
                     begin
                       o_source1_flag = 1'b0; 
                       o_source2_flag = 1'b0;
                       o_source1 = 3'd0;
                       o_source2 = 3'd0;
                    end
                `JMPcond:
                     begin
                       o_source1_flag = 1'b1; 
                       o_source2_flag = 1'b1;
                       o_source1 = i_instruction[2:0];
                       o_source2 = i_instruction[8:6];
                    end
                `JMPRcond:
                     begin
                       o_source1_flag = 1'b0; 
                       o_source2_flag = 1'b1;
                       o_source1 = 3'd0;
                       o_source2 = i_instruction[8:6];
                    end
                default:
                    begin
                       o_source1_flag = 1'b0; 
                       o_source2_flag = 1'b0;
                       o_source1 = 3'd0;
                       o_source2 = 3'd0;
                    end
                endcase
            end
        endcase
    end
endmodule
