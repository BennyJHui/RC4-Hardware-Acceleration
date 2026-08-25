module ksa(
    input CLOCK_50,
    input [3:0] KEY,
    input [9:0] SW,
    output [9:0] LEDR,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5
);

    logic clk, reset, restart;
    logic s_wren, s_wren_mem, shuffle_wren_mem, dram_wren, s_decrypt_wren;
    logic s_finished_a, s_finished_b, s_finished_c;
    logic [4:0] dram_addr, rom_addr;
    logic [7:0] s_addr, s_addr_mem, shuffle_addr_mem, s_decrypt_addr;
    logic [7:0] s_data, s_data_mem, shuffle_data_mem, dram_data, s_decrypt_data;
    logic [7:0] s_q, rom_q, dram_q;
    logic [23:0] secret_key;
    logic [21:0] count_key = 0;

    assign secret_key = {2'b0, count_key};
    assign clk = CLOCK_50;
    assign reset = (restart | ~KEY[3]);
    // assign secret_key = {14'b0, SW[9:0]};

    s_memory U0(
        .address(s_addr),
        .clock(clk),
        .data(s_data),
        .wren(s_wren),
        .q(s_q)
    );

    init_s_mem U1(
        .clk(clk),
        .reset(reset),
        .start(~KEY[0]),
        .addr(s_addr_mem),
        .data(s_data_mem),
        .wren(s_wren_mem),
        .finished(s_finished_a)
    ); // BEGIN: {start_b, start_a} = 2'b00, END: {start_b, start_a} = 2'b01

    shuffle_mem U2(
        .clk(clk),
        .reset(reset),
        .start(s_finished_a),
        .s_q(s_q),
        .secret_key(secret_key),
        .wren(shuffle_wren_mem),
        .finished(s_finished_b),
        .s_data(shuffle_data_mem),
        .s_addr(shuffle_addr_mem)
    ); // BEGIN: {start_b, start_a} = 2'b01, END: {start_b, start_a} = 2'b11

    data_selector U3(
        .start_a(s_finished_a),
        .start_b(s_finished_b),
        .shuffle_wren_mem(shuffle_wren_mem),
        .shuffle_addr_mem(shuffle_addr_mem), 
        .shuffle_data_mem(shuffle_data_mem), 
        .s_wren_mem(s_wren_mem), 
        .s_addr_mem(s_addr_mem), 
        .s_data_mem(s_data_mem),
        .s_decrypt_wren(s_decrypt_wren),
        .s_decrypt_addr(s_decrypt_addr),
        .s_decrypt_data(s_decrypt_data),
        .s_wren(s_wren),
        .s_addr(s_addr), 
        .s_data(s_data)
    );

    ROM U4(
        .address(rom_addr),
        .clock(clk),
        .q(rom_q)
    );

    RAM_Decrypt U5(
        .address(dram_addr),
        .clock(clk),
        .data(dram_data),
        .wren(dram_wren),
        .q(dram_q)
    );

    decrypter U6(
        .clk(clk),
        .reset(reset),
        .start(s_finished_b),
        .rom_q(rom_q),
        .s_q(s_q),
        .restart(restart),
        .finished(s_finished_c),
        .s_decrypt_wren(s_decrypt_wren),
        .dram_wren(dram_wren),
        .s_decrypt_data(s_decrypt_data),
        .s_decrypt_addr(s_decrypt_addr),
        .dram_data(dram_data),
        .dram_addr(dram_addr),
        .rom_addr(rom_addr)
    );

    increment_key U7(
        .clk(clk),
        .restart(restart),
        .reset(~KEY[3]),
        .count_key(count_key)
    );

    SevenSegmentDisplayDecoder ssHEX0(
        .ssOut(HEX0),
        .nIn(secret_key[3:0])
    );

    SevenSegmentDisplayDecoder ssHEX1(
        .ssOut(HEX1),
        .nIn(secret_key[7:4])
    );

    SevenSegmentDisplayDecoder ssHEX2(
        .ssOut(HEX2),
        .nIn(secret_key[11:8])
    );

    SevenSegmentDisplayDecoder ssHEX3(
        .ssOut(HEX3),
        .nIn(secret_key[15:12])
    );

    SevenSegmentDisplayDecoder ssHEX4(
        .ssOut(HEX4),
        .nIn(secret_key[19:16])
    );

    SevenSegmentDisplayDecoder ssHEX5(
        .ssOut(HEX5),
        .nIn(secret_key[23:20])
    );

    assign LEDR[0] = s_finished_a;
    assign LEDR[1] = s_finished_b;
    assign LEDR[2] = s_finished_c;
    assign LEDR[9:3] = 7'b0;

endmodule