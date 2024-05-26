task automatic uart_send 
(   
    input integer idx,
    input [7:0] i_data,
    output o_tx
);
localparam F_CLK = 100_000_000;
localparam F_BAUDRATE = 9600;
localparam  clk_ticks = 10 * ( F_CLK / F_BAUDRATE );
if( (idx % 11) < 1)
    begin
        #(clk_ticks + 10);
        o_tx = 1'b0;
        //$display("The loop index is %0d, the modulo is %0d, the transmitted bit is 0(start bit), at time %0t", idx, (idx%11), $time);
    end
else if( (idx % 11)  < 9)
    begin
        #clk_ticks;
        o_tx = i_data[ (idx % 11) - 1 ];
        //$display("The loop index is %0d, the modulo is %0d, the transmitted bit is %b(data bit), at time %0t", idx, (idx%11), i_data[ (idx % 11) - 1 ], $time);
        if( ((idx % 11) - 1)  == 0)$display("LSB bit");
        if( ((idx % 11) - 1)  == 7)$display("MSB bit");
    end
else
    begin
        #clk_ticks;
        o_tx = 1'b1; 
        //$display("The loop index is %0d, the modulo is %0d, the transmitted bit is 1(stop bit), at time %0t", idx, (idx%11), $time);
    end       
endtask


