module data_memory(
    input wire i_clk,
    input wire [9:0] i_address1,//CPU Port
    input wire [9:0] i_address2,//Debugger Port
    input wire i_write1,//CPU Port
    input wire i_write2,//Debugger Port
    input wire [31:0] i_data1,//CPU Port
    input wire [31:0] i_data2,//Debugger Port
    output wire [31:0] o_data1,//CPU Port
    output wire [31:0] o_data2//Debugger Port
    );
    reg [31:0] r_memory [0:1023];
    reg [9:0] r_address1;
    reg [31:0] r_data1;
    reg r_write1;
    always@(posedge i_clk)
    begin 
        case({r_write1, i_write2})
        2'b00:
            begin
            end
        2'b01:
            begin
                r_memory[i_address2] <= i_data2;
                $display("Writing 0x%0h in DMEM through Port 2, at address 0x%0h at %0t", i_data2, i_address2, $time);
            end
        2'b10:
            begin
                r_memory[r_address1] <= r_data1;
                $display("Writing 0x%0h in DMEM through Port 1, at address 0x%0h at %0t", i_data1, i_address1, $time);
            end
        2'b11:
            begin
                r_memory[r_address1] <= r_data1;
                $display("Writing 0x%0h in DMEM through Port 1, at address 0x%0h at %0t", i_data1, i_address1, $time);
            end
        endcase
    end
    
    always@(posedge i_clk)
    begin
        r_address1 <= i_address1;
        r_write1 <= i_write1;
        r_data1 <= i_data1;
    end
    
    assign o_data1 = r_memory[r_address1];
    assign o_data2 = r_memory[i_address2];
endmodule

