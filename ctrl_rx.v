module ctrl_rx(
      input wire clk,
      input wire reset_n,      
      /*Address channel*/
      output wire [3:0]  araddr, 
      output wire        arvalid,
      input  wire        arready,
      /*Data*/
      input  wire [31:0] rdata,
      input  wire        rvalid,
      output  wire       rready,
      /*User*/
      output reg [7:0]   data
    );
    
reg [2:0] state;

always @(posedge clk)
begin
    if(~reset_n)
        begin
            state <= 0;
            data <= 0;
        end
    else 
        begin
            case(state)
                0:begin
                    state <= 1;
                end
                1: begin
                    if(arready)
                        state <= 2;
                end
                2:begin
                    if(rvalid)
                        begin
                            if(rdata[0]) //rx data valid din registrul stat_reg
                                state <= 3;
                            else
                                state <= 0;
                        end
                end
                3:begin
                    if(arready) //astep adres read ready de la uart
                        state <= 4;//adresa de citire este valida, adresa de citire este 0, citesc din RX fifo
                end
                4:begin
                    if(rvalid)//astept sa imi trimita uartul toate datele, datele de citit s-au trimis=> valid
                        begin
                            state <= 0;
                            data <= rdata[7:0];
                        end
                end
                default: state <= 0;
        endcase
    end 
end  
assign arvalid = (state == 1) | (state == 3);//addres read valid in starea 1 si 3
assign rready  = (state == 2) | (state == 4);
assign  araddr  = (state == 1) ? 4'd8 : (state == 3) ? 4'd0 : 4'd0;// in starea 1 adresa de citire este 8,
                                                                  // in satrea 3 adresa de citire este 0
endmodule
