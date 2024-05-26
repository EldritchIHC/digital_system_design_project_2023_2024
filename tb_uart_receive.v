
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2024 19:29:01
// Design Name: 
// Module Name: tb_uart
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


module tb_uart_receive();
    reg tb_clk;
    reg tb_reset_n;
    //reg tb_send;
    reg tb_write;
    reg tb_read;
    reg tb_rx;
    wire tb_tx;
    //reg  [7:0] tb_data;
    reg  [7:0] tb_write_data;
    wire [7:0] tb_read_data;
    wire tb_read_data_ready;
    wire tb_write_data_full;
 `include "uart_tasks.v"
 integer transmit_idx;   
  top_wrapper DUT
       (
        .i_clk(tb_clk),
        .i_reset_n(tb_reset_n),
        .i_read(tb_read),
        .o_read_data(tb_read_data),
        .o_read_data_ready(tb_read_data_ready),
        .o_write_data_full(tb_write_data_full),
        .i_write(tb_write),
        .i_write_data(tb_write_data),
        .i_rx(tb_rx),
        .o_tx(tb_tx)
        );
 /*      
   uart_transmitter_module TX
   (
    .clk(tb_clk),
    .data(tb_data),
    .reset_n(tb_reset_n),
    .send(tb_send),
    .tx(tb_rx)
    );
 */      
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
    tb_write = 0;
    tb_rx = 1'b1;
    tb_read = 0;
    tb_write_data = 8'h00;
    #25;
    for(transmit_idx = 0; transmit_idx < 11; transmit_idx = transmit_idx + 1)
        uart_send(transmit_idx, 8'hA5, tb_rx);
    #25;
    tb_read = 1;
    #12;
    tb_read = 0;
    #50;
    tb_write_data = 8'h55;
    #20;
    tb_write = 1;
    #12;
    tb_write = 0;
    #1_500_000;
    $stop();
end
endmodule
