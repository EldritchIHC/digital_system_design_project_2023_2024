`include "UARTLITE_DEFINES.vh"
module axi_interface(
    input  wire i_clk,
    input  wire i_reset_n,
    input  wire i_read,//Assert to start a read
    input  wire i_write,//Assert to start a write
    input  wire [7:0] i_write_data,//Data to be sent through the UART
    output wire [7:0] o_read_data,//Data recieved after the read sequence
    /*Read Address*/
    output wire [3:0] o_araddr,
    output wire       o_arvalid,
    input  wire       i_arready,
    /*Read Data*/
    input  wire [31:0] i_rdata,
    input  wire        i_rvalid,
    output wire        o_rready,
    /*Write Address*/
    output wire [3:0] o_awaddr,
    output wire       o_awvalid,
    input  wire       i_awready,
    /*Write Data*/
    output wire [31:0] o_wdata,
    output wire        o_wvalid,
    input  wire        i_wready,
    /*Write Response*/
    output wire        o_bready
    );
    reg [2:0] r_state ;
    reg [7:0] r_data;
    localparam START   = 3'd0,//Reset state
               WAIT    = 3'd1,//Wait for the read or write signal
               WRITE   = 3'd2,//Write sequence
               READ1   = 3'd3,//Send the address of the STAT REG
               READ2   = 3'd4,//Recieve the data of the STAT REG
               READ3   = 3'd5,//Send the address of the RX_FIFO REG
               READ4   = 3'd6;//Recieve the data of the RF_FIFO REG            
    always@(posedge i_clk)
    begin
        if(~i_reset_n)
            begin
                r_state <= START;
                r_data  <= 0;
            end
        else
            begin
                case(r_state)
                    START:
                        begin
                           r_state <= WAIT; 
                        end
                    WAIT:
                        begin
                            if(i_read)
                                r_state <= READ1;
                            else if(i_write)
                                r_state <= WRITE;
                            else
                                r_state <= WAIT;
                        end
                    WRITE:
                        begin
                            if(i_awready & i_wready)//The UART can write
                                r_state <= WAIT;
                        end
                    READ1:
                        begin
                            if(i_arready)//Message the slave that I am driving a valid address on the bus
                                r_state <= READ2;
                        end 
                    READ2:
                        begin
                            if(i_rvalid)//The slave messages back that it has driven a valid data from my address
                                begin
                                    if(i_rdata[0])//There is data in the RX FIFO?
                                        r_state <= READ3;
                                    else
                                        r_state <= WAIT;
                                end
                        end
                    READ3:
                        begin
                            if(i_arready)//Message the slave that I am driving a valid address on the bus
                                r_state <= READ4;//The slave send me the data in the FIFO
                        end
                    READ4:
                        begin
                            if(i_rvalid)//The slave messages back that it has driven a valid data from my address
                                begin
                                    r_state <= WAIT;
                                    r_data  <= i_rdata[7:0];
                                end
                        end
                    default: r_state <= 0;
                endcase
            end
    end
    assign o_bready = 1'b1;//verify
    /*Write phase*/
    assign o_awaddr  = ( r_state == WRITE ) ? `TX_FIFO : 4'd0;//In config state send the control reg address
    assign o_wdata   = ( r_state == WRITE ) ? { 24'd0, i_write_data } : 32'd0;
    assign o_awvalid = ( r_state == WRITE ) ? 1'b1 : 1'b0;
    assign o_wvalid  = ( r_state == WRITE ) ? 1'b1 : 1'b0;
    /*Read phase*/
    assign o_arvalid = ( r_state == READ1 ) | ( r_state == READ3 ); //The read address is valid
    assign o_rready  = ( r_state == READ2 ) | ( r_state == READ4 );
    assign o_araddr  = ( r_state == READ1 ) ? `STAT_REG :  //Firstly read the STAT REG to check if there is data in the RX FIFO
                       ( r_state == READ3 ) ? `RX_FIFO : 
                                            4'd0;                                       
   assign o_read_data = r_data; 
                      
endmodule
