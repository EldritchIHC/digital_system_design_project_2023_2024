/*Simple RISC ISA Defines*/
/* In order to disable implicit declaration of wires */
//`default_nettype none
/* Registers */
`define R0 3'b000
`define R1 3'b001
`define R2 3'b010
`define R3 3'b011
`define R4 3'b100
`define R5 3'b101
`define R6 3'b110
`define R7 3'b111
/*=============================================*/
/* Instruction Set */

/* Arithmetic and Logic Group*/
`define ALU_GROUP 2'b11
`define ALU_LEN 7
/* Arithmetic Instructions */
`define ADD      7'b1100_000
`define ADDF     7'b1100_100
`define SUB      7'b1101_000
`define SUBF     7'b1101_100
/* Logic Instructions */
`define AND      7'b1110_000
`define OR       7'b1110_010
`define XOR      7'b1110_100
`define NAND     7'b1111_000
`define NOR      7'b1111_010
`define NXOR     7'b1111_100
/*=============================================*/
/* Barrel Shifter Group*/
`define BRL_GROUP 2'b01
`define BRL_LEN 7
/* Shift Instructions */
`define SHIFTR   7'b0100_000
`define SHIFTRA  7'b0101_000
`define SHIFTL   7'b0110_000
/*=============================================*/
/* Memory Group*/
`define MEM_GROUP 2'b00
`define MEM_LEN 5
/* Memory Instructions */
`define LOAD     5'b00110
`define LOADC    5'b00010
`define STORE    5'b00100
/*=============================================*/
/* Control Group*/
`define CTRL_GROUP 2'b10
`define CTRL_LEN 4
/* Control Functions */
`define JMP      4'b1010
`define JMPR     4'b1000
`define JMPcond  4'b1011
`define JMPRcond 4'b1001
/* Jump Conditions */
`define N  3'b000
`define NN 3'b001
`define Z  3'b010
`define NZ 3'b011
/*=============================================*/
/* Special Group*/
`define SPEC_LEN 16
/* Special Instructions */
`define NOP      5'b00000
`define HALT     7'b1111_111
/*=============================================*/