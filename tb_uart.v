
module tb_uart_transmit();
    reg tb_clk;
    reg tb_reset_n;
    reg tb_write;
    reg tb_read;
    reg tb_rx;
    wire tb_tx;
    reg  [7:0] tb_write_data;
    wire [7:0] tb_read_data;
    wire tb_write_data_full;
    wire tb_interface_idle;
    reg [7:0] tb_data_to_transmit [0:18];
    integer idx = 0;
`include "uart_tasks.v"
  top_wrapper DUT
       (
        .i_clk(tb_clk),
        .i_reset_n(tb_reset_n),
        .i_read(tb_read),
        .o_read_data(tb_read_data),
        .o_write_data_full(tb_write_data_full),
        .o_interface_idle(tb_interface_idle),
        .i_write(tb_write),
        .i_write_data(tb_write_data),
        .i_rx(tb_rx),
        .o_tx(tb_tx)
        );
        
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
    tb_data_to_transmit[0] = 8'hAA;
    tb_data_to_transmit[1] = 8'h55;
    tb_data_to_transmit[2] = 8'hCC;
    tb_data_to_transmit[3] = 8'hDD;
    tb_data_to_transmit[4] = 8'hAA;
    tb_data_to_transmit[5] = 8'h55;
    tb_data_to_transmit[6] = 8'hCC;
    tb_data_to_transmit[7] = 8'hDD;
    tb_data_to_transmit[8] = 8'hAA;
    tb_data_to_transmit[9] = 8'h55;
    tb_data_to_transmit[10] = 8'hCC;
    tb_data_to_transmit[11] = 8'hDD;
    tb_data_to_transmit[12] = 8'hAA;
    tb_data_to_transmit[13] = 8'h55;
    tb_data_to_transmit[14] = 8'hCC;
    tb_data_to_transmit[15] = 8'hDD;
    tb_data_to_transmit[16] = 8'hAA;
    tb_data_to_transmit[17] = 8'h55;
    tb_data_to_transmit[18] = 8'hCC;
    tb_rx = 1;
    tb_read = 0;
    tb_write_data = 8'h00;
    tb_write =0;
    #25;
    
    for(idx = 0; idx < 18; idx = idx + 1)
    begin
        tb_write = 1;
        tb_write_data = tb_data_to_transmit[idx];
        #64;
        tb_write = 0;
        #64;
    end
        
        /*
        while( idx < 18)
        begin
            if(tb_interface_idle)
            begin
                tb_write = 1;
                tb_write_data = tb_data_to_transmit[idx];
                #12;
                tb_write = 0;
                #12;
                idx = idx + 1;
            end         
        end  
        */
    #15_000_000;
    
    $stop();
end
endmodule
