module tb_protocol_handler();
    reg  tb_clk;
    reg  tb_reset_n;
    reg  tb_rx;
    wire tb_tx;
    //DMEM
    wire [9:0] tb_o_dmem_address;
    wire [31:0] tb_i_dmem_data;
    wire [31:0] tb_o_dmem_data;   
    wire tb_o_dmem_read;
    wire tb_o_dmem_write;
    //PMEM
    wire [15:0] tb_o_pmem_data;    
    wire [9:0] tb_o_pmem_address;
    wire tb_o_pmem_write;
    //Control Signals
    wire tb_cpu_reset_n;
    wire tb_cpu_halt;
    wire tb_cpu_start;
    
    reg [7:0] tb_commands [0:63] ;
   `include "uart_tasks.v"  
   `include "core_defines.vh" 
   `include "PROTOCOL_HANDLER_DEFINES.vh"
    protocol_handler DUT(
        .i_clk(tb_clk),
        .i_reset_n(tb_reset_n),
        //DMEM
        .o_dmem_address(tb_o_dmem_address),//To MEM
        .i_dmem_data(tb_i_dmem_data),//To MEM        
        .o_dmem_data(tb_o_dmem_data),//To MEM
        .o_dmem_read(tb_o_dmem_read),
        .o_dmem_write(tb_o_dmem_write),
        //PMEM
        .o_pmem_address(tb_o_pmem_address),//To MEM
        .o_pmem_data(tb_o_pmem_data),//To MEM
        .o_pmem_write(tb_o_pmem_write),
        //Control Signals
        .o_cpu_reset_n(tb_cpu_reset_n),
        .o_cpu_halt(tb_cpu_halt),
        .o_cpu_start(tb_cpu_start),
        .i_rx(tb_rx),
        .o_tx(tb_tx)
    );
         
    program_memory PMEM(
        .i_clk(tb_clk),
        .i_write_address(tb_o_pmem_address),
        .i_read_address(8'd0),
        .i_write(tb_o_pmem_write),
        .i_data(tb_o_pmem_data),
        .o_data()
    ); 
    
    data_memory DMEM(
    .i_clk(tb_clk),
    .i_write_address1(8'd0),//CPU Port
    .i_write_address2(tb_o_dmem_address),//Debugger Port
    .i_read_address1(8'd0),//CPU Port
    .i_read_address2(tb_o_dmem_read),//Debugger Port
    .i_write1(0),//CPU Port
    .i_write2(tb_o_dmem_write),//Debugger Port
    .i_data1(32'd0),//CPU Port
    .i_data2(tb_o_dmem_data),//Debugger Port
    .o_data1(),//CPU Port
    .o_data2(tb_i_dmem_data)//Debugger Port
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
//    DMEM.r_memory[0] = 32'hCCAA_5533;
//    DMEM.r_memory[1] = 32'hCCAA_5533;
//    DMEM.r_memory[2] = 32'hCCAA_5533;
//    DMEM.r_memory[3] = 32'hCCAA_5533;
//    DMEM.r_memory[4] = 32'hCCAA_5533;
//    DMEM.r_memory[5] = 32'hCCAA_5533;
//    DMEM.r_memory[6] = 32'hCCAA_5533;
//    DMEM.r_memory[7] = 32'hCCAA_5533;
    /*Send 4 packets to DMEM*/
//    tb_commands[0] = `WRITE_CMD; 
//    /*Address*/
//    tb_commands[1] = 8'h03;
//    tb_commands[2] = 8'h55;
//    /*Length*/
//    tb_commands[3] = 8'h00;
//    tb_commands[4] = 8'h04;
//    /*Data*/
//    /*Packet1*/
//    tb_commands[5] = 8'h12;
//    tb_commands[6] = 8'h34;
//    tb_commands[7] = 8'h56;
//    tb_commands[8] = 8'h78;
//    /*Packet2*/
//    tb_commands[9]  = 8'h9A;
//    tb_commands[10] = 8'hBC;
//    tb_commands[11] = 8'hDE;
//    tb_commands[12] = 8'hF1;
//    /*Packet3*/
//    tb_commands[13] = 8'h23;
//    tb_commands[14] = 8'h45;
//    tb_commands[15] = 8'h67;
//    tb_commands[16] = 8'h89;
//    /*Packet4*/
//    tb_commands[17] = 8'hAB;
//    tb_commands[18] = 8'hCD;
//    tb_commands[19] = 8'hEF;
//    tb_commands[20] = 8'h12;
//    #50; 
//    /*Send 1 packet to DMEM, 2 to PMEM*/
//    tb_commands[0] = `WRITE_CMD; 
//    /*Address*/
//    tb_commands[1] = 8'h03;//DMEM
//    tb_commands[2] = 8'h55;
//    /*Length*/
//    tb_commands[3] = 8'h00;
//    tb_commands[4] = 8'h01;
//    /*Data*/
//    /*Packet1*/
//    tb_commands[5] = 8'h12;
//    tb_commands[6] = 8'h34;
//    tb_commands[7] = 8'h56;
//    tb_commands[8] = 8'h78;
//    tb_commands[9] = 8'h00;
//    tb_commands[10] = 8'h00;
//    tb_commands[11] = 8'h00;
//    tb_commands[12] = 8'h00;
//    tb_commands[13] = 8'h00;
//    tb_commands[14] = `WRITE_CMD; 
//    /*Address*/
//    tb_commands[15] = 8'h06;//PMEM
//    tb_commands[16] = 8'h55;
//    /*Length*/
//    tb_commands[17] = 8'h00;
//    tb_commands[18] = 8'h02;
//    /*Packet1*/
//    tb_commands[19] = 8'h9A;
//    tb_commands[20] = 8'hBC;
//    tb_commands[21] = 8'hDE;
//    tb_commands[22] = 8'hF1;
//    #50; 
//    /*Send 2 packets to DMEM, 2 to PMEM*/
//    tb_commands[0] = `WRITE_CMD; 
//    /*Address*/
//    tb_commands[1] = 8'h03;//DMEM
//    tb_commands[2] = 8'h00;
//    /*Length*/
//    tb_commands[3] = 8'h00;
//    tb_commands[4] = 8'h02;
//    /*Data*/
//    /*Packet1*/
//    tb_commands[5] = 8'h12;
//    tb_commands[6] = 8'h34;
//    tb_commands[7] = 8'h56;
//    tb_commands[8] = 8'h78;
//    /*Packet2*/
//    tb_commands[9] = 8'h9A;
//    tb_commands[10]= 8'hBC;
//    tb_commands[11]= 8'hDE;
//    tb_commands[12]= 8'hF0;
    
//    tb_commands[13] = 8'h00;
    
//    tb_commands[14] = `WRITE_CMD; 
//    /*Address*/
//    tb_commands[15] = 8'h07;//PMEM
//    tb_commands[16] = 8'h00;
//    /*Length*/
//    tb_commands[17] = 8'h00;
//    tb_commands[18] = 8'h02;
//    /*Packet1*/
//    tb_commands[19] = 8'h9A;
//    tb_commands[20] = 8'hBC;
//    tb_commands[21] = 8'hDE;
//    tb_commands[22] = 8'hF1;
//    #50;

//    /*Read 1 packet from DMEM*/
//    tb_commands[0] = `READ_CMD; 
//    /*Address*/
//    tb_commands[1] = 8'h00;//DMEM
//    tb_commands[2] = 8'h00;
//    /*Length*/
//    tb_commands[3] = 8'h00;
//    tb_commands[4] = 8'h08; 
//    #50; 
    
//    /*Write 2 packets in DMEM and read the same packets*/
//    tb_commands[0] = `WRITE_CMD; 
//    /*Address*/
//    tb_commands[1] = 8'h00;//DMEM
//    tb_commands[2] = 8'h00;
//    /*Length*/
//    tb_commands[3] = 8'h00;
//    tb_commands[4] = 8'h02;
//    /*Data*/
//    /*Packet1*/
//    tb_commands[5] = 8'hAA;
//    tb_commands[6] = 8'hCC;
//    tb_commands[7] = 8'h55;
//    tb_commands[8] = 8'h33;
//    /*Packet2*/
//    tb_commands[9] = 8'hAA;
//    tb_commands[10]= 8'hCC;
//    tb_commands[11]= 8'h55;
//    tb_commands[12]= 8'h33; 
    
//    tb_commands[13] = 8'h00;
    
//    tb_commands[14] = `READ_CMD; 
//    /*Address*/
//    tb_commands[15] = 8'h00;//DMEM
//    tb_commands[16] = 8'h00;
//    /*Length*/
//    tb_commands[17] = 8'h00;
//    tb_commands[18] = 8'h02; 
    
    
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
    tb_commands[23] = {`STORE, `R4};//17)
    tb_commands[24] = {5'b00000, `R3};//18)
    tb_commands[25] = 8'hFF;//19) HALT
    tb_commands[26] = 8'hFF;//20)
    
    tb_commands[27] = 8'h00;
    tb_commands[28] = 8'h00;
    tb_commands[29] = `START_CMD;
    
    #50; 
    
    for(command_idx = 0; command_idx < 31; command_idx = command_idx + 1)
        for(transmit_idx = 0; transmit_idx < 11; transmit_idx = transmit_idx + 1 )
            uart_send(transmit_idx, tb_commands[command_idx], tb_rx);
            
    #1000;
    $stop();
end
endmodule
