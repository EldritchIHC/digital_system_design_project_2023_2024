`include "core_defines.vh"
module comb_stage_execute
    #(
      parameter ADDRESS_SIZE = 10,
      parameter DATA_SIZE = 32  
     )
    (
    input wire [15:0] i_instruction, 
    input wire  [1:0] i_instruction_type,
    input wire  [`ALU_LEN - 1:0] i_alu_instruction,
    input wire  [`BRL_LEN - 1:0] i_brl_instruction,
    input wire  [`MEM_LEN - 1:0] i_mem_instruction,
    input wire  [`CTRL_LEN - 1:0] i_ctrl_instruction,
    input wire  [ADDRESS_SIZE - 1:0] i_program_counter,
    input wire  [5:0] i_value,
    input wire  [7:0] i_constant,
    input wire signed [5:0] i_offset,
    input wire  [2:0] i_cond,
    input wire  [2:0] i_destination,
    input wire signed [DATA_SIZE - 1:0] i_operand1,
    input wire signed [DATA_SIZE - 1:0] i_operand2,
    
    output reg  o_data_source,//0 - ALU result 1 - data memory
    output reg  [ADDRESS_SIZE - 1:0] o_address,
    output reg  [DATA_SIZE - 1:0] o_data,
    output reg  o_read,
    output reg  o_write,
    output reg  [ADDRESS_SIZE - 1:0] o_program_counter,
    output reg  o_program_counter_load,
    output reg  o_program_counter_stop,
    output wire  [2:0] o_destination,
    output reg signed [DATA_SIZE - 1:0] o_result,
    output reg o_register_file_write,
    output wire [15:0] o_instruction,
    output reg o_flush
    );
    /*Combinational logic for EXECUTE*/
    always@(*)  
    begin
       o_flush = 0;
       o_address = 0;
       o_data = 0;
       o_read = 0;
       o_write = 0;
       o_program_counter = 0;
       o_program_counter_load = 0;
       o_program_counter_stop = 0;
       o_result = 0;
       o_data_source = 0;
       o_register_file_write = 0;
       /*Decode by instruction group*/
       case(i_instruction_type)
       /*=======================================================*/
        `ALU_GROUP:
            begin
                case(i_alu_instruction)
                    `ADD:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = i_operand1 + i_operand2;
                        end
                    `ADDF:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = i_operand1 + i_operand2;
                        end
                    `SUB:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = i_operand1 - i_operand2;
                        end
                    `SUBF:
                        begin
                            o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = i_operand1 - i_operand2;
                        end
                    `AND:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = i_operand1 & i_operand2;
                        end
                    `OR:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = i_operand1 | i_operand2;
                        end
                    `XOR:
                        begin
                            o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = i_operand1 ^ i_operand2;
                        end
                    `NAND:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = ~( i_operand1 & i_operand2 );
                        end
                    `NOR:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = ~( i_operand1 | i_operand2 );
                        end
                    `NXOR:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = ~( i_operand1 ^ i_operand2 );
                        end
                    `HALT:
                        begin
                            o_program_counter_stop = 1;//Stop the Program Counter
                            #6;
                            $stop();
                        end
                    default: o_result = o_result ;// de verificat
                endcase//ALU
            end//ALU
        /*=======================================================*/
        `BRL_GROUP:
            begin
                case(i_brl_instruction)
                    `SHIFTR:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = i_operand2 >> i_value;
                        end
                    `SHIFTRA:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = i_operand2 >>> i_value;
                        end
                    `SHIFTL:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 1;
                           o_result = i_operand2 << i_value;
                        end
                    default: o_result = o_result ;// de verificat
                endcase//BRL
            end//BRL
        /*=======================================================*/
        `MEM_GROUP:
            begin
                case(i_mem_instruction)
                    `LOAD:
                        begin
                           o_data_source = 1;
                           o_register_file_write = 1;                       
                           o_read = 1'b1;//Read from the Data Memory
                           o_write = 1'b0;
                           o_address = i_operand1[ADDRESS_SIZE - 1:0];//Only the last 10 bits of the register are used
                           //Data in written in the WRITE stage                                          
                        end
                    `LOADC:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 1;                         
                           o_result = { i_operand2[DATA_SIZE - 1:8], i_constant };//Result for loadc is loaded to regs in WRITE
                        end
                    `STORE:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 0;
                           o_read = 1'b0;
                           o_write = 1'b1;//Write to the Data Memory
                           o_address = i_operand2[ADDRESS_SIZE - 1:0];//Only the last 10 bits of the register are used
                           o_data = i_operand1;
                        end
                    `NOP:
                        begin
                            o_data_source = 0;
                            o_register_file_write = 0;
                            o_result = o_result;
                        end
                    default: o_result = o_result;
                endcase//MEM 
            end//MEM
        /*=======================================================*/
        `CTRL_GROUP:
            begin
                case(i_ctrl_instruction)
                    `JMP:
                        begin
                           o_flush = 1;
                           o_data_source = 0;
                           o_register_file_write = 0;
                           o_program_counter_load = 1;
                           o_program_counter = i_operand1;
                        end
                    `JMPR:
                        begin
                           o_flush = 1;
                           o_data_source = 0;
                           o_register_file_write = 0;
                           o_program_counter_load = 1;
                           o_program_counter = $signed(i_program_counter) + i_offset;
                        end 
                    `JMPcond:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 0;
                           //o_program_counter_load = 1;
                           case(i_cond)
                              `N: if(i_operand2[DATA_SIZE - 1] == 1'b1)//Verify MSB if it is negative
                                    begin
                                        o_program_counter = i_operand1;
                                        o_program_counter_load = 1;
                                        o_flush = 1;
                                    end
                                  else
                                    o_program_counter = o_program_counter;//de verificat                                                           
                              `NN: if(i_operand2[DATA_SIZE - 1] != 1'b1)//Verify MSB if it is negative
                                     begin
                                        o_program_counter = i_operand1;
                                        o_program_counter_load = 1;
                                        o_flush = 1;
                                     end
                                   else
                                     o_program_counter = o_program_counter;//de verificat  
                              `Z: if(i_operand2 == 0)//Verify if the number is equal to zero
                                    begin
                                        o_program_counter = i_operand1;
                                        o_program_counter_load = 1;
                                        o_flush = 1;
                                     end
                                   else
                                     o_program_counter = o_program_counter; 
                              `NZ: if(i_operand2 != 0)//Verify if the number isn't zero
                                    begin
                                        o_program_counter = i_operand1;
                                        o_program_counter_load = 1;
                                        o_flush = 1;
                                     end
                                   else
                                     o_program_counter = o_program_counter;
                              default: o_result = o_result;
                           endcase
                        end  
                    `JMPRcond:
                        begin
                           o_data_source = 0;
                           o_register_file_write = 0;
                           //o_program_counter_load = 1;
                           case(i_cond)
                              `N: if(i_operand2[DATA_SIZE - 1] == 1'b1)
                                    begin
                                        o_program_counter = $signed(i_program_counter) + i_offset;
                                        o_program_counter_load = 1;
                                        o_flush = 1;
                                    end
                                  else
                                    o_program_counter = o_program_counter; 
                              `NN: if(i_operand2[DATA_SIZE - 1] != 1'b1)
                                    begin
                                        o_program_counter = $signed(i_program_counter) + i_offset;
                                        o_program_counter_load = 1;
                                        o_flush = 1;
                                    end
                                  else
                                    o_program_counter = o_program_counter; 
                              `Z: if(i_operand2 == 0)
                                    begin
                                        o_program_counter = $signed(i_program_counter) + i_offset;
                                        o_program_counter_load = 1;
                                        o_flush = 1;
                                    end
                                  else
                                    o_program_counter = o_program_counter; 
                             `NZ: if(i_operand2 != 0)
                                    begin
                                        o_program_counter = $signed(i_program_counter) + i_offset;
                                        o_program_counter_load = 1;
                                        o_flush = 1;
                                    end
                                  else
                                    o_program_counter = o_program_counter; 
                              default: o_result = o_result;
                           endcase
                        end
                    default: o_result = o_result;
                endcase//CTRL
            end//CTRL
        endcase//Instruction
    end//ALU
    assign o_destination = i_destination;
    assign o_instruction = i_instruction;
endmodule