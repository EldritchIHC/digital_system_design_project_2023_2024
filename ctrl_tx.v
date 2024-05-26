module ctrl_tx(
      input wire clk,
      input wire reset_n,
      input wire [7:0] data,
      input wire       send,
      /*Address channel*/
      output wire [3:0] awaddr, 
      output wire       awvalid,
      input wire        awready,
      /*Data channel*/
      output wire [31:0] wdata,
      output wire        wvalid,
      input wire    wready,
      /*Response*/
      output wire bready
);

reg state;
always @(posedge clk)
begin
    if(~reset_n)
        state <= 0;
    else 
        begin
            case(state)
                0:begin
                    if(send)
                        state <= 1;
                end
                1:begin
                    if(awready & wready)
                      state <= 0;  
                end
            endcase
        end  
end

assign awaddr  = ( state ) ? 4'd4 : 4'd0;
assign wdata   = ( state ) ? { 24'd0, data } :32'd0;
assign awvalid = ( state ) ? 1'b1 : 1'b0;
assign wvalid  = ( state ) ? 1'b1 : 1'b0;
assign bready  = 1'b1;
endmodule