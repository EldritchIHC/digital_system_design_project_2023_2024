module tb_system();
    reg  tb_clk;
    reg  tb_reset_n;
    reg  tb_rx;
    wire tb_tx;
        
    reg [7:0] tb_commands [0:63] ;
   `include "uart_tasks.v" 
   `include "core_defines.vh" 

       
    system_wrapper DUT(
        .i_clk(tb_clk),
        .i_reset_n(tb_reset_n),
        .i_rx(tb_rx),
        .o_tx(tb_tx)
    );
              
integer transmit_idx = 0;
integer command_idx = 0;   

 
initial begin
    tb_clk = 0;
    forever #5 tb_clk =~tb_clk;
end 

initial begin  
    tb_reset_n = 1;
    #11;
    tb_reset_n = 0;
    #10;
    tb_reset_n = 1;
end

initial begin
    tb_rx = 1'b1;
    /*Halt Test*/
    /*
    tb_commands[0] = `HALT_CMD;
    tb_commands[1] = `RESET_CMD;
    tb_commands[2] = `WRITE_CMD;
    tb_commands[3] = 8'h04;//Write in PMEM, address 00
    tb_commands[4] = 8'h00;
    tb_commands[5] = 8'h00;//Length of 2
    tb_commands[6] = 8'h02;
    tb_commands[7] = 8'h00;//NOP
    tb_commands[8] = 8'h00;
    tb_commands[9] = 8'hFF;   //HALT
    tb_commands[10] = 8'hFF; 
    tb_commands[11] = 8'h00;
    tb_commands[12] = `START_CMD;
    */
    /*Emulated multiplication*/ 
    
    tb_commands[0]  = `HALT_CMD;
    tb_commands[1]  = `RESET_CMD;
    tb_commands[2]  = `WRITE_CMD;
    tb_commands[3]  = 8'h04;//Write in PMEM, address 00
    tb_commands[4]  = 8'h00;
    tb_commands[5]  = 8'h00;//Length of 10
    tb_commands[6]  = 8'h0A;
    tb_commands[7]  = {`LOADC, `R0};//1)LOADC
    tb_commands[8]  = 8'h03;//2)R0 <-0x03
    tb_commands[9]  = {`LOADC, `R1};//3)LOADC
    tb_commands[10]  = 8'h05;//4)R1 <-0x05
    tb_commands[11] = {`LOADC, `R2};//5)LOADC
    tb_commands[12] = 8'h01;//6)R2 <-0x01
    tb_commands[13] = {`LOADC, `R3};//7)LOADC
    tb_commands[14] = 8'h00;//8)R2 <-0x00
    tb_commands[15] = {`LOADC, `R4};//9)LOADC
    tb_commands[16] = 8'h05;//10)R4 <-0x05
    tb_commands[17] = {`ADD, 1'b0};//11)R3<- R3 + R1 R3 = R3 + 5  
    tb_commands[18] = { 2'b11,`R3,`R1 };//12)
    tb_commands[19] = {`SUB, 1'b0};//13)//R0 <- R0 - 1  R0-- 
    tb_commands[20] = { 2'b00,`R0,`R2 };//14)
    tb_commands[21] = {`JMPRcond, `NZ,1'b0};//15)//Jump to address 4 if R4 == 0
    tb_commands[22] = {2'b00, 6'b111011};//16)
    tb_commands[23] = {`STORE, `R4};//17)// M[R4] <- R3
    tb_commands[24] = {5'b00000, `R3};//18)
    tb_commands[25] = 8'hFF;//19) HALT
    tb_commands[26] = 8'hFF;//20)
    tb_commands[27]  = `RESET_CMD;
    tb_commands[28] = `START_CMD;
    tb_commands[29] = `READ_CMD;
    tb_commands[30] = 8'h00;//Address
    tb_commands[31] = 8'h05;
    tb_commands[32] = 8'h00;//Length
    tb_commands[33] = 8'h01;
    
    /*Sum using data from memory*/
    /*
    tb_commands[0]  = `HALT_CMD;
    tb_commands[1]  = `RESET_CMD;
    tb_commands[2]  = `WRITE_CMD;
    tb_commands[3]  = 8'h00;//Write in PMEM, address 00
    tb_commands[4]  = 8'h01;
    tb_commands[5]  = 8'h00;//Length of 2
    tb_commands[6]  = 8'h02;
    tb_commands[7]  = 8'h00;//Data 1
    tb_commands[8]  = 8'h00;
    tb_commands[9]  = 8'h00;
    tb_commands[10]  = 8'h0B;
    tb_commands[11]  = 8'h00;//Data 2
    tb_commands[12]  = 8'h00;
    tb_commands[13]  = 8'h00;
    tb_commands[14]  = 8'h0C;
    tb_commands[15]  = 8'h00;//Pause
    tb_commands[16]  = `WRITE_CMD;
    tb_commands[17]  = 8'h04;//Write in PMEM, address 00
    tb_commands[18]  = 8'h00;
    tb_commands[19]  = 8'h00;//Length of 8
    tb_commands[20]  = 8'h08;
    tb_commands[21]  = {`LOADC, `R0};//1)LOADC
    tb_commands[22]  = 8'h01;//R0 <-0x01
    tb_commands[23]  = {`LOAD, `R1};
    tb_commands[24]  = {5'd0, `R0};
    tb_commands[25]  = {`LOADC, `R2};//1)LOADC
    tb_commands[26]  = 8'h02;//R2 <-0x02
    tb_commands[27]  = {`LOAD, `R3};
    tb_commands[28]  = {5'd0, `R2};
    tb_commands[29]  = {`LOADC, `R5};//1)LOADC
    tb_commands[30]  = 8'h03;//R5 <-0x03
    tb_commands[31] = {`ADD, 1'b1};//R4<- R1 + R3   
    tb_commands[32] = { 2'b00,`R1,`R3 };
    tb_commands[33] = {`STORE, `R5};// M[R5] <- R4
    tb_commands[34] = {5'b00000, `R4};
    tb_commands[35] = 8'hFF;//HALT
    tb_commands[36] = 8'hFF;
    tb_commands[37]  = 8'h00;//Pause
    tb_commands[38]  = `RESET_CMD;
    tb_commands[39]  = 8'h00;//Pause
    tb_commands[40] = `START_CMD;
    tb_commands[41]  = 8'h00;//Pause
    tb_commands[42] = `READ_CMD;
    tb_commands[43] = 8'h00;//Address
    tb_commands[44] = 8'h01;
    tb_commands[45] = 8'h00;//Length
    tb_commands[46] = 8'h03;
    */
    #50;    
    for(command_idx = 0; command_idx < 47; command_idx = command_idx + 1)
        for(transmit_idx = 0; transmit_idx < 11; transmit_idx = transmit_idx + 1 )
            uart_send(transmit_idx, tb_commands[command_idx], tb_rx);
            
    #1000;
    $stop();

end
endmodule