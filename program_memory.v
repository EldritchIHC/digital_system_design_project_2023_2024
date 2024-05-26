module program_memory(
    input wire i_clk,
    input wire [9:0] i_write_address,
    input wire [9:0] i_read_address,
    input wire i_write,
    input wire [15:0] i_data,
    output wire [15:0] o_data
    );
    reg [15:0] r_memory [0:1023];
    always@(posedge i_clk)
    begin
        if(i_write)
        begin
            $display("Writing 0x%0h in PMEM at address 0x%0h at %0t", i_data, i_write_address, $time);
            r_memory[i_write_address] <= i_data;
        end
    end
    assign o_data = r_memory[i_read_address];
endmodule
