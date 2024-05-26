`include "UARTLITE_DEFINES.vh"
`include "PROTOCOL_HANDLER_DEFINES.vh"
module protocol_handler(
    input  wire i_clk,
    input  wire i_reset_n,
    /*Data Memory*/
    output wire [9:0]  o_dmem_address,//To MEM
    input  wire [31:0] i_dmem_data,//To MEM
    output reg  [31:0] o_dmem_data,//To MEM
    output reg o_dmem_read,//nu e necesar
    output reg o_dmem_write,
    /*Program Memory*/
    output wire [9:0]  o_pmem_address,//To MEM
    output reg  [15:0] o_pmem_data,//To MEM
    output reg o_pmem_write,
    /*CPU control signals*/
    output reg o_cpu_reset_n,
    output reg o_cpu_halt,
    output reg o_cpu_start,
    /*Uart signals*/
    input wire i_rx,
    output wire o_tx
    );
    reg r_read;
    reg r_write;
    reg [7:0] r_write_data;
    reg [7:0] r_write_data_next;
    wire [7:0] w_read_data;
    reg [4:0] r_state;
    reg [4:0] r_state_next;
    wire w_read_data_ready;
    wire w_write_data_full;
    wire w_interface_idle;
    /*Concatenated Address from the Address frames*/
    reg [9:0] r_address;
    reg [9:0] r_address_next;
    /*Cocatenated Transfer Length from the Length Frames*/
    reg [9:0] r_length;
    reg [9:0] r_length_next;
    /*Register used when Writing or Reading multiple Address spaces*/
    reg [9:0] r_address_counter;
    reg [9:0] r_address_counter_next;
    /*Register used to count for bytes, before packing them into 32-bit wide data*/
    reg [2:0] r_data_counter;
    reg [2:0] r_data_counter_next;
    reg r_mem_type;//0 - Data Memory, 1 - Program Memory
    reg r_mem_type_next;
    
    reg  [31:0] r_dmem_data_next;
    reg  [15:0] r_pmem_data_next;
    
    reg r_dmem_write_next;

    reg r_pmem_write_next;
    
    reg r_dmem_read_next;

    reg [31:0] r_dmem_data;
    
    /*States*/
    localparam START           = 5'd0,
               REQUEST_COMMAND = 5'd1,
               CHECK_COMMAND   = 5'd2,
               RESET_CPU       = 5'd3,
               START_CPU       = 5'd4,
               HALT_CPU        = 5'd5,
               /*Read States*/
               READ_START      = 5'd6,
               READ_ADD1       = 5'd7,
               READ_ADD2       = 5'd8,
               READ_LEN1       = 5'd9,
               READ_LEN2       = 5'd10,
               READ_DMEM1      = 5'd11,
               READ_DMEM2      = 5'd12,
               READ_DMEM3      = 5'd13,
               READ_DMEM4      = 5'd14,
               /*Write States*/
               WRITE_START     = 5'd15,
               WRITE_ADD1      = 5'd16,
               WRITE_ADD2      = 5'd17,
               WRITE_LEN1      = 5'd18,
               WRITE_LEN2      = 5'd19,
               WRITE_DMEM1     = 5'd20,
               WRITE_DMEM2     = 5'd21,     
               WRITE_PMEM1     = 5'd22,
               WRITE_PMEM2     = 5'd23;
                     
    top_wrapper AXI_INTERFACE(
            .i_clk(i_clk),
            .i_reset_n(i_reset_n),
            .i_read(r_read),
            .i_write(r_write),
            .i_write_data(r_write_data),
            .o_interface_idle(w_interface_idle),
            .o_read_data_ready(w_read_data_ready),
            .o_write_data_full(w_write_data_full),
            .o_read_data(w_read_data),
            .i_rx(i_rx),
            .o_tx(o_tx)
         );
    /*Protocol Handler State Machine*/
    /*Next State Logic*/
    always@(posedge i_clk)
    begin
        if(~i_reset_n)
            begin
                r_state <= START;
                r_address_counter <= 0;
                r_data_counter <= 2'b00;
                r_address <= 0;
                r_length <= 0;
                r_mem_type <= 0;
                o_dmem_data <= 0;
                o_pmem_data <= 0;
                o_dmem_write <= 0;
                o_pmem_write <= 0;
                o_dmem_read <= 0;
                r_dmem_data <= 0;
                r_write_data <= 0;
            end
        else
            begin
                case(r_state)
                START:
                    begin
                        /*Initial state*/
                        r_state <= REQUEST_COMMAND;
                    end
                REQUEST_COMMAND:   
                    begin
                        /*Wait for a complete byte(command), verify it in the next state*/
                        if(w_read_data_ready)
                            r_state <= CHECK_COMMAND;
                    end
                CHECK_COMMAND:
                    begin 
                        /*Based on the received command, go to a specific state*/              
                        case(w_read_data)
                            `RESET_CMD: r_state <= RESET_CPU;
                            `START_CMD: r_state <= START_CPU;
                            `HALT_CMD:  r_state <= HALT_CPU;
                            `READ_CMD:  r_state <= READ_START;
                            `WRITE_CMD: r_state <= WRITE_START;
                            default:    r_state <= REQUEST_COMMAND;
                        endcase                            
                    end
                RESET_CPU:
                    begin
                       /*Assert Outputs and go back to waiting for commands*/
                       r_state <= REQUEST_COMMAND;
                    end
                START_CPU:
                    begin
                       /*Assert Outputs and go back to waiting for commands*/
                       r_state <= REQUEST_COMMAND;
                    end
                HALT_CPU:
                    begin
                       /*Assert Outputs and go back to waiting for commands*/
                       r_state <= REQUEST_COMMAND;
                    end
                    /*Read States*/
                READ_START       :
                    begin
                        /*Wait for a complete byte(first 2 bits of the address)*/
                        if(w_read_data_ready)
                            r_state <= READ_ADD1;
                    end
                READ_ADD1       :
                    begin
                        /*Wait for a complete byte(remaining bits of the address)*/
                        if(w_read_data_ready)
                        begin
                            r_state <= READ_ADD2;
                            r_address <= r_address_next;
                        end
                    end
                READ_ADD2       :
                    begin
                        /*Wait for a complete byte(first 2 bits of the length)*/
                        if(w_read_data_ready)
                        begin
                            r_state <= READ_LEN1;
                            r_address <= r_address_next;
                        end
                    end
                READ_LEN1       :
                    begin
                        /*Wait for a complete byte(remaining bits of the length)*/
                        if(w_read_data_ready)
                        begin
                            r_state <= READ_LEN2;
                            r_length <= r_length_next;
                        end
                    end
                READ_LEN2       :
                    begin
                        r_address_counter <= r_address_counter_next;
                        //if(w_read_data_ready)
                        //begin
                            r_state <= READ_DMEM1;
                            r_length <= r_length_next;
                        //end
                    end            
                READ_DMEM1      :
                    begin
                        /*Wait for the complete data package to be sent*/
                        r_dmem_data <= i_dmem_data;//Read data from DMEM
                        r_data_counter    <= r_data_counter_next;
                        r_address_counter <= r_address_counter_next;
                        r_state <= READ_DMEM2;//switch state
                        
                    end
                READ_DMEM2      :
                    begin
                    /*Wait for the complete data package to be sent*/
                        r_data_counter    <= r_data_counter_next;//The counter is set to 0
                        r_address_counter <= r_address_counter_next;
                        r_write_data <= r_write_data_next;//Update data to be trasnmitted
                        o_dmem_read <= r_dmem_read_next;
                        if(w_interface_idle)//The AXI interface can receive data to be sent only when it is in IDLE state
                            r_state <= READ_DMEM3;//If the AXI interface is in the IDLE state, then go to the next state where data is sent to the interface
                        else
                            r_state <= READ_DMEM2;//If the AXI interface isn't in the IDLE state, then wait
                    end
                READ_DMEM3  :
                    begin
                        r_data_counter    <= r_data_counter_next;
                        r_address_counter <= r_address_counter_next;
                        r_write_data <= r_write_data_next;//Update data to be trasnmitted
                        r_state <= READ_DMEM4;
                    end
                READ_DMEM4:
                    begin
                        r_data_counter    <= r_data_counter_next;
                        r_address_counter <= r_address_counter_next;
                        r_write_data <= r_write_data_next;//Update data to be trasnmitted
                        r_state <= r_state_next;
                    end
                 /*Write States*/
                 WRITE_START      :
                    begin
                       /*Wait for a complete byte(first 2 bits of the address)*/
                       if(w_read_data_ready)
                            r_state <= WRITE_ADD1;
                    end
                WRITE_ADD1      :
                    begin
                       /*Wait for a complete byte(remaining bits of the address)*/
                       r_mem_type <= r_mem_type_next;                       
                       if(w_read_data_ready)
                       begin
                           r_state <= WRITE_ADD2;
                           r_address <= r_address_next;
                       end
                    end
                WRITE_ADD2      :
                    begin                       
                        /*Wait for a complete byte(first 2 bits of the length)*/
                        if(w_read_data_ready)
                        begin
                            r_state <= WRITE_LEN1;
                            r_address <= r_address_next;
                        end
                    end
                WRITE_LEN1      :
                    begin                     
                        /*Wait for a complete byte(remaining bits of the length)*/
                        //r_length <= r_length_next;
                        if(w_read_data_ready)
                        begin
                            r_state <= WRITE_LEN2;
                            r_length <= r_length_next;
                        end
                    end
                WRITE_LEN2      :
                    begin
                        /*Complete the length vector*/
                        //r_length <= r_length_next;
                        r_address_counter <= r_address;                       
                        if(w_read_data_ready)
                        begin
                            r_length <= r_length_next;
                            if(r_mem_type)
                                r_state <= WRITE_PMEM1;
                            else
                                r_state <= WRITE_DMEM1;
                            r_data_counter    <= r_data_counter_next;
                        end
                    end
                WRITE_DMEM1      :
                    begin
                        /*Wait for the data byte to be received*/   
                        o_dmem_write <= r_dmem_write_next; 
                        r_state <= r_state_next;                
                        if(w_read_data_ready )
                        begin
                            o_dmem_data <= r_dmem_data_next;                      
                            r_data_counter <= r_data_counter_next;
                        end                                        
                    end
                WRITE_DMEM2:
                    begin 
                       o_dmem_data <= r_dmem_data_next;
                       o_dmem_write <= r_dmem_write_next;                      
                       r_data_counter    <= r_data_counter_next;
                       r_address_counter <= r_address_counter_next;
                       if(r_address_counter == ( r_address + r_length - 1 ) )
                            r_state <= REQUEST_COMMAND;      
                       else
                            r_state <= WRITE_DMEM1;
                    end
                WRITE_PMEM1      :
                    begin
                        /*Wait for the data byte to be received*/   
                        o_pmem_write <= r_pmem_write_next; 
                        r_state <= r_state_next;                
                        if(w_read_data_ready )
                        begin
                            o_pmem_data <= r_pmem_data_next;                     
                            r_data_counter  <= r_data_counter_next;
                        end                                        
                    end
                WRITE_PMEM2:
                    begin
                       o_pmem_data <= r_pmem_data_next;
                       o_pmem_write <= r_pmem_write_next;                      
                       r_data_counter    <= r_data_counter_next;
                       r_address_counter <= r_address_counter_next;
                       if(r_address_counter == ( r_address + r_length - 1 ) )
                            r_state <= REQUEST_COMMAND;      
                       else
                            r_state <= WRITE_PMEM1;
                    end
                    
                endcase
            end
   end
   /*Outputs asserts*/
   always@(*)
   begin
       /*UART control*/
       r_read = 0;
       r_write = 0;
       /*CPU control*/
       o_cpu_reset_n = 1;
       o_cpu_halt = 0;
       o_cpu_start = 0;
       /*Data Memory Control*/
       r_mem_type_next = 0;
     
       r_dmem_write_next = 0;
       r_pmem_write_next = 0;
       
       r_dmem_read_next = 0;

       r_dmem_data_next = 0;
       r_pmem_data_next = 0;
       
       r_address_next = 0;
       r_length_next = 0;
       r_address_counter_next = 0;
       
       r_data_counter_next = 0;
       
       r_state_next = 0;
       
       r_write_data_next = 0;
       
       case(r_state)
            START           :
                begin
                /**/
                end
            REQUEST_COMMAND :
                begin
                    r_read = 1;
                end
            CHECK_COMMAND   :
                begin
                /**/
                    r_read = 0;
                end
            RESET_CPU       :
                begin
                    r_read = 0;
                    o_cpu_reset_n = 0;
                    o_cpu_start  = 0;
                    o_cpu_halt = 0;
                end
            START_CPU       :
                begin
                    r_read = 0;
                    o_cpu_reset_n = 1;
                    o_cpu_start  = 1;
                    o_cpu_halt = 0;
                end
            HALT_CPU        :
                begin
                    r_read = 0;
                    o_cpu_reset_n = 1;
                    o_cpu_start  = 0;
                    o_cpu_halt = 1;
                end
            /*Read States*/
            READ_START      :
                begin
                    /*Read the first 2(9-8) bits of the address*/
                    r_read = 1;
                end         
            READ_ADD1       :
                begin         
                    /*Read the remaining bits(7-0) */           
                    r_read = 1;
                    /*Concatenate the first bits to the complete address*/
                    r_address_next = w_read_data;                   
                end
            READ_ADD2       :
                begin
                    /*Read the remaining bits(7-0) */
                    r_read = 1;
                    /*Concatenate the remaining bits to the complete address*/
                    /*Address is complete*/
                    r_address_next =  ( r_address << 8 )+ w_read_data ;                    
                end
            READ_LEN1       :
                begin
                    /*Read the first 2(9-8) bits of the length */
                    r_read = 1;
                    /*Concatenate the first bits to the complete length*/
                    r_length_next = w_read_data;
                    r_address_counter_next = r_address;
                end
            READ_LEN2       :
                begin
                    /*Read the remaining bits(7-0) of the length */
                    r_read = 1;
                    /*Length is complete*/
                    r_length_next = ( r_length << 8 ) + w_read_data;
                    /*Set the counter to zero before starting to concatenate data*/
                    r_address_counter_next = r_address;
                    /*Read from DMEM*/
                    r_dmem_read_next = 1;
                end
            READ_DMEM1      :
                begin
                    r_read = 0;
                    r_write = 0;
                    r_data_counter_next = 0;
                    r_address_counter_next = r_address_counter;
                    r_dmem_read_next = 0;
                    r_write_data_next = r_write_data;
                end  
            READ_DMEM2 :
                begin
                    r_read = 0;
                    r_write = 0;
                    r_data_counter_next = r_data_counter;
                    r_address_counter_next = r_address_counter;
                    r_dmem_read_next = 0;
                    r_write_data_next = r_write_data;
                end          
            READ_DMEM3      :
                begin
                    r_read = 0;
                    r_write = 1;
                    r_dmem_read_next = 0;
                    case(r_data_counter)
                        3'b000:
                        begin
                            r_read = 0;
                            r_address_counter_next = r_address_counter;
                            r_data_counter_next = r_data_counter + 1;
                            r_write_data_next = r_dmem_data[31:24];
                        end
                        3'b001:
                        begin
                            r_read = 0;
                            r_address_counter_next = r_address_counter;
                            r_data_counter_next = r_data_counter + 1;
                            r_write_data_next = r_dmem_data[23:16];                      
                        end
                        3'b010:
                        begin
                            r_read = 0;
                            r_address_counter_next = r_address_counter;
                            r_data_counter_next = r_data_counter + 1;  
                            r_write_data_next = r_dmem_data[15:8];
                        end
                        3'b011:
                        begin
                            r_read = 0;
                            r_address_counter_next = r_address_counter + 1;//4 nu are efect
                            r_data_counter_next = r_data_counter + 1; 
                            r_write_data_next = r_dmem_data[7:0]; 
                        end                       
                        3'b100:
                        begin
                            r_read = 0;
                            r_address_counter_next = r_address_counter + 1 ;
                            r_data_counter_next = r_data_counter;
                            r_write_data_next = r_write_data;
                        end                  
                        default: r_write_data_next = r_write_data;
                    endcase
                end
            READ_DMEM4     :
                begin
                   r_read = 0;
                   r_write = 0;
                   r_dmem_read_next = 0;
                   r_write_data_next = r_write_data;
                   r_address_counter_next = r_address_counter;
                   r_data_counter_next = r_data_counter;
                    if(r_data_counter == 3'b100)//write_data_full unused
                    begin
                        if( r_address_counter == ( r_address + r_length  ) )// cu sau fata -1?
                            r_state_next = REQUEST_COMMAND; 
                        else
                            r_state_next = READ_DMEM1;//Jump to READ_DMEM1, read the new data from DMEM.
                    end
                    else
                        r_state_next = READ_DMEM2;
                end
            /*Write States*/
            WRITE_START      :
                begin
                    /*Read the first 2(9-8) bits of the address*/
                    r_read = 1;
                end
            WRITE_ADD1      :
                begin
                    /*Read the remaining bits(7-0) */
                    r_read = 1;
                    /*Concatenate the first bits to the complete address*/
                    r_mem_type_next = w_read_data[2];
                    r_address_next = { 6'd0, w_read_data[1:0] };
                end
            WRITE_ADD2      :
                begin
                    /*Read the first 2(9-8) bits of the length */
                    r_read = 1;
                    /*Concatenate the reamining bits to the complete address*/
                    /*Address is complete*/
                    r_address_next =  ( r_address << 8 )+ w_read_data ;
                end
            WRITE_LEN1      :
                begin
                    /*Read the remaining bits(7-0) of the length */
                    r_read = 1;
                    /*Concatenate the first bits to the complete length*/
                    r_length_next = w_read_data;
                    r_address_counter_next = r_address;
                end
            WRITE_LEN2      :
                begin
                    /*Read the remaining bits(7-0) of the length */
                    r_read = 1;
                    /*Length is complete*/
                    r_length_next = ( r_length << 8 ) + w_read_data;
                    /*Set the counter to zero before starting to concatenate data*/
                    r_data_counter_next = 0;
                end
                
            WRITE_DMEM1     :
                begin
                    /*Read a data byte, 4 bytes are needed*/  
                    case(r_data_counter)
                        3'b000:
                        begin
                            r_dmem_data_next = w_read_data;//iau datele
                            r_read = 1; //data urmatoare citesc iar
                            r_address_counter_next = r_address_counter;//The address counter changes only after I have read 4 bytes
                            r_data_counter_next = r_data_counter + 1;//Increase the data counter each time
                            r_dmem_write_next = 0;
                            r_state_next = WRITE_DMEM1;//Loop back to WRITE_DMEM1 until i have read 4 bytes
                        end
                        3'b001: 
                        begin
                            r_dmem_data_next = ( o_dmem_data << 8 )+ w_read_data;
                            r_read = 1;
                            r_address_counter_next = r_address_counter;
                            r_data_counter_next = r_data_counter + 1;
                            r_dmem_write_next = 0;
                            r_state_next = WRITE_DMEM1;
                        end
                        3'b010: 
                        begin
                            r_dmem_data_next = ( o_dmem_data << 8 )+ w_read_data;
                            r_read = 1;
                            r_address_counter_next = r_address_counter;
                            r_data_counter_next = r_data_counter + 1;
                            r_dmem_write_next = 0;
                            r_state_next = WRITE_DMEM1;
                        end
                        3'b011: 
                        begin 
                            r_dmem_data_next = ( o_dmem_data << 8 )+ w_read_data;
                            r_read = 1;
                            r_address_counter_next = r_address_counter;
                            r_data_counter_next = r_data_counter + 1;
                            r_dmem_write_next = 0;
                            r_state_next = WRITE_DMEM1;
                        end
                        3'b100:
                        begin
                            r_dmem_data_next = o_dmem_data;
                            r_read = 1;
                            r_address_counter_next = r_address_counter;
                            r_dmem_write_next = 1;
                            r_state_next = WRITE_DMEM2;
                        end
                        default: r_dmem_data_next = o_dmem_data;
                    endcase                                                                           
                end
             
            WRITE_DMEM2:
                begin
                    r_read = 0;
                    r_dmem_write_next = 0;
                    r_address_counter_next = r_address_counter + 1;//Increase the address counter
                    r_data_counter_next = 0;//Reset the counter
                end                          
            WRITE_PMEM1    :
                begin                     
                     /*Read a data byte, 2 bytes are needed*/    
                    case(r_data_counter)
                        3'b000: 
                        begin
                            r_pmem_data_next  = w_read_data;
                            r_read = 1;
                            r_address_counter_next = r_address_counter;
                            r_data_counter_next = r_data_counter + 1;
                            r_pmem_write_next = 0;
                            r_state_next = WRITE_PMEM1; 
                        end
                        3'b001: 
                        begin
                            r_pmem_data_next  = ( o_pmem_data << 8 )+ w_read_data[7:0]; 
                            r_read = 1;
                            r_address_counter_next = r_address_counter;
                            r_data_counter_next = r_data_counter + 1;
                            r_pmem_write_next = 0;
                            r_state_next = WRITE_PMEM1;
                        end
                        3'b010:
                        begin
                            r_pmem_data_next = o_pmem_data;
                            r_read = 1;
                            r_address_counter_next = r_address_counter;                           
                            r_pmem_write_next = 1;
                            r_state_next = WRITE_PMEM2;
                        end 
                        default: r_pmem_data_next = o_pmem_data;                      
                    endcase                                   
                end 
            WRITE_PMEM2     :
                begin
                    r_read = 0;
                    r_pmem_write_next = 0;
                    r_address_counter_next = r_address_counter + 1;//Increase the address counter
                    r_data_counter_next = 0;//Reset the counter
                end
                                        
            default         : 
                begin
                end
       endcase
   end
   
   assign o_dmem_address = r_address_counter;
   assign o_pmem_address = r_address_counter;
   
endmodule
