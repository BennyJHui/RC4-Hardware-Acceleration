module data_selector(
    input start_a, 
    input start_b,  
    input       shuffle_wren_mem,
    input [7:0] shuffle_addr_mem,
    input [7:0] shuffle_data_mem,
    input       s_wren_mem,
    input [7:0] s_addr_mem, 
    input [7:0] s_data_mem,
    input       s_decrypt_wren,
    input [7:0] s_decrypt_addr,
    input [7:0] s_decrypt_data,
    output reg       s_wren,
    output reg [7:0] s_addr, 
    output reg [7:0] s_data
);

    always_comb begin
        case({start_b, start_a})
            2'b00: begin
                s_data = s_data_mem;
                s_addr = s_addr_mem;
                s_wren = s_wren_mem;
            end

            2'b01: begin
                s_data = shuffle_data_mem;
                s_addr = shuffle_addr_mem;
                s_wren = shuffle_wren_mem;                
            end

            2'b11: begin
                s_data = s_decrypt_data;
                s_addr = s_decrypt_addr;
                s_wren = s_decrypt_wren;      
            end

            default: begin
                s_data = 0;
                s_addr = 0;
                s_wren = 0;    
            end
        endcase
    end
    
endmodule