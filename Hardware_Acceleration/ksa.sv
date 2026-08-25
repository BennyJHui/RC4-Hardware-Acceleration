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

    logic clk;
    assign clk = CLOCK_50;


    // CORE 1
    logic reset, restart, done;
    logic s_wren, s_wren_mem, shuffle_wren_mem, dram_wren, s_decrypt_wren;
    logic s_finished_a, s_finished_b, s_finished_c;
    logic [4:0] dram_addr, rom_addr;
    logic [7:0] s_addr, s_addr_mem, shuffle_addr_mem, s_decrypt_addr;
    logic [7:0] s_data, s_data_mem, shuffle_data_mem, dram_data, s_decrypt_data;
    logic [7:0] s_q, rom_q, dram_q;
    logic [23:0] secret_key;
    logic [21:0] count_key = 22'h000000;

    assign secret_key = {2'b00, count_key};
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
        .start(0),
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
        .found(found),
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
        .setter(22'h0FFFFF),
        .number(22'h000000),
        .done(done),
        .count_key(count_key)
    );

    // CORE 2
    logic reset2, restart2, done2;
    logic s_wren2, s_wren_mem2, shuffle_wren_mem2, dram_wren2, s_decrypt_wren2;
    logic s_finished_a2, s_finished_b2, s_finished_c2;
    logic [4:0] dram_addr2, rom_addr2;
    logic [7:0] s_addr2, s_addr_mem2, shuffle_addr_mem2, s_decrypt_addr2;
    logic [7:0] s_data2, s_data_mem2, shuffle_data_mem2, dram_data2, s_decrypt_data2;
    logic [7:0] s_q2, rom_q2, dram_q2;
    logic [23:0] secret_key2;
    logic [21:0] count_key2 = 22'h100000;
    
    assign secret_key2 = {2'b00, count_key2};
    assign reset2 = (restart2 | ~KEY[3]);
    // assign secret_key = {14'b0, SW[9:0]};

    s_memory U02(
        .address(s_addr2),
        .clock(clk),
        .data(s_data2),
        .wren(s_wren2),
        .q(s_q2)
    );

    init_s_mem U12(
        .clk(clk),
        .reset(reset2),
        .start(0),
        .addr(s_addr_mem2),
        .data(s_data_mem2),
        .wren(s_wren_mem2),
        .finished(s_finished_a2)
    ); // BEGIN: {start_b, start_a} = 2'b00, END: {start_b, start_a} = 2'b01

    shuffle_mem U22(
        .clk(clk),
        .reset(reset2),
        .start(s_finished_a2),
        .s_q(s_q2),
        .secret_key(secret_key2),
        .wren(shuffle_wren_mem2),
        .finished(s_finished_b2),
        .s_data(shuffle_data_mem2),
        .s_addr(shuffle_addr_mem2)
    ); // BEGIN: {start_b, start_a} = 2'b01, END: {start_b, start_a} = 2'b11

    data_selector U32(
        .start_a(s_finished_a2),
        .start_b(s_finished_b2),
        .shuffle_wren_mem(shuffle_wren_mem2),
        .shuffle_addr_mem(shuffle_addr_mem2), 
        .shuffle_data_mem(shuffle_data_mem2), 
        .s_wren_mem(s_wren_mem2), 
        .s_addr_mem(s_addr_mem2), 
        .s_data_mem(s_data_mem2),
        .s_decrypt_wren(s_decrypt_wren2),
        .s_decrypt_addr(s_decrypt_addr2),
        .s_decrypt_data(s_decrypt_data2),
        .s_wren(s_wren2),
        .s_addr(s_addr2), 
        .s_data(s_data2)
    );

    ROM U42(
        .address(rom_addr2),
        .clock(clk),
        .q(rom_q2)
    );

    RAM_Decrypt U52(
        .address(dram_addr2),
        .clock(clk),
        .data(dram_data2),
        .wren(dram_wren2),
        .q(dram_q2)
    );

    decrypter U62(
        .clk(clk),
        .reset(reset2),
        .start(s_finished_b2),
        .found(found),
        .rom_q(rom_q2),
        .s_q(s_q2),
        .restart(restart2),
        .finished(s_finished_c2),
        .s_decrypt_wren(s_decrypt_wren2),
        .dram_wren(dram_wren2),
        .s_decrypt_data(s_decrypt_data2),
        .s_decrypt_addr(s_decrypt_addr2),
        .dram_data(dram_data2),
        .dram_addr(dram_addr2),
        .rom_addr(rom_addr2)
    );

    increment_key U72(
        .clk(clk),
        .restart(restart2),
        .reset(~KEY[3]),
        .setter(22'h1FFFFF),
        .number(22'h100000),
        .done(done2),
        .count_key(count_key2)
    );

    // CORE 3
    logic reset3, restart3, done3;
    logic s_wren3, s_wren_mem3, shuffle_wren_mem3, dram_wren3, s_decrypt_wren3;
    logic s_finished_a3, s_finished_b3, s_finished_c3;
    logic [4:0] dram_addr3, rom_addr3;
    logic [7:0] s_addr3, s_addr_mem3, shuffle_addr_mem3, s_decrypt_addr3;
    logic [7:0] s_data3, s_data_mem3, shuffle_data_mem3, dram_data3, s_decrypt_data3;
    logic [7:0] s_q3, rom_q3, dram_q3;
    logic [23:0] secret_key3;
    logic [21:0] count_key3 = 22'h200000;
   
    assign secret_key3 = {2'b00, count_key3};
    assign reset3 = (restart3 | ~KEY[3]);
    // assign secret_key = {14'b0, SW[9:0]};

    s_memory U03(
        .address(s_addr3),
        .clock(clk),
        .data(s_data3),
        .wren(s_wren3),
        .q(s_q3)
    );

    init_s_mem U13(
        .clk(clk),
        .reset(reset3),
        .start(0),
        .addr(s_addr_mem3),
        .data(s_data_mem3),
        .wren(s_wren_mem3),
        .finished(s_finished_a3)
    ); // BEGIN: {start_b, start_a} = 2'b00, END: {start_b, start_a} = 2'b01

    shuffle_mem U23(
        .clk(clk),
        .reset(reset3),
        .start(s_finished_a3),
        .s_q(s_q3),
        .secret_key(secret_key3),
        .wren(shuffle_wren_mem3),
        .finished(s_finished_b3),
        .s_data(shuffle_data_mem3),
        .s_addr(shuffle_addr_mem3)
    ); // BEGIN: {start_b, start_a} = 2'b01, END: {start_b, start_a} = 2'b11

    data_selector U33(
        .start_a(s_finished_a3),
        .start_b(s_finished_b3),
        .shuffle_wren_mem(shuffle_wren_mem3),
        .shuffle_addr_mem(shuffle_addr_mem3), 
        .shuffle_data_mem(shuffle_data_mem3), 
        .s_wren_mem(s_wren_mem3), 
        .s_addr_mem(s_addr_mem3), 
        .s_data_mem(s_data_mem3),
        .s_decrypt_wren(s_decrypt_wren3),
        .s_decrypt_addr(s_decrypt_addr3),
        .s_decrypt_data(s_decrypt_data3),
        .s_wren(s_wren3),
        .s_addr(s_addr3), 
        .s_data(s_data3)
    );

    ROM U43(
        .address(rom_addr3),
        .clock(clk),
        .q(rom_q3)
    );

    RAM_Decrypt U53(
        .address(dram_addr3),
        .clock(clk),
        .data(dram_data3),
        .wren(dram_wren3),
        .q(dram_q3)
    );

    decrypter U63(
        .clk(clk),
        .reset(reset3),
        .start(s_finished_b3),
        .found(found),
        .rom_q(rom_q3),
        .s_q(s_q3),
        .restart(restart3),
        .finished(s_finished_c3),
        .s_decrypt_wren(s_decrypt_wren3),
        .dram_wren(dram_wren3),
        .s_decrypt_data(s_decrypt_data3),
        .s_decrypt_addr(s_decrypt_addr3),
        .dram_data(dram_data3),
        .dram_addr(dram_addr3),
        .rom_addr(rom_addr3)
    );

    increment_key U73(
        .clk(clk),
        .restart(restart3),
        .reset(~KEY[3]),
        .setter(22'h2FFFFF),
        .number(22'h200000),
        .done(done3),
        .count_key(count_key3)
    );

    // CORE 4
    logic reset4, restart4, done4;
    logic s_wren4, s_wren_mem4, shuffle_wren_mem4, dram_wren4, s_decrypt_wren4;
    logic s_finished_a4, s_finished_b4, s_finished_c4;
    logic [4:0] dram_addr4, rom_addr4;
    logic [7:0] s_addr4, s_addr_mem4, shuffle_addr_mem4, s_decrypt_addr4;
    logic [7:0] s_data4, s_data_mem4, shuffle_data_mem4, dram_data4, s_decrypt_data4;
    logic [7:0] s_q4, rom_q4, dram_q4;
    logic [23:0] secret_key4;
    logic [21:0] count_key4 = 22'h300000;
    
    assign secret_key4 = {2'b00, count_key4};
    assign reset4 = (restart4 | ~KEY[3]);
    // assign secret_key = {14'b0, SW[9:0]};

    s_memory U04(
        .address(s_addr4),
        .clock(clk),
        .data(s_data4),
        .wren(s_wren4),
        .q(s_q4)
    );

    init_s_mem U14(
        .clk(clk),
        .reset(reset4),
        .start(0),
        .addr(s_addr_mem4),
        .data(s_data_mem4),
        .wren(s_wren_mem4),
        .finished(s_finished_a4)
    ); // BEGIN: {start_b, start_a} = 2'b00, END: {start_b, start_a} = 2'b01

    shuffle_mem U24(
        .clk(clk),
        .reset(reset4),
        .start(s_finished_a4),
        .s_q(s_q4),
        .secret_key(secret_key4),
        .wren(shuffle_wren_mem4),
        .finished(s_finished_b4),
        .s_data(shuffle_data_mem4),
        .s_addr(shuffle_addr_mem4)
    ); // BEGIN: {start_b, start_a} = 2'b01, END: {start_b, start_a} = 2'b11

    data_selector U34(
        .start_a(s_finished_a4),
        .start_b(s_finished_b4),
        .shuffle_wren_mem(shuffle_wren_mem4),
        .shuffle_addr_mem(shuffle_addr_mem4), 
        .shuffle_data_mem(shuffle_data_mem4), 
        .s_wren_mem(s_wren_mem4), 
        .s_addr_mem(s_addr_mem4), 
        .s_data_mem(s_data_mem4),
        .s_decrypt_wren(s_decrypt_wren4),
        .s_decrypt_addr(s_decrypt_addr4),
        .s_decrypt_data(s_decrypt_data4),
        .s_wren(s_wren4),
        .s_addr(s_addr4), 
        .s_data(s_data4)
    );

    ROM U44(
        .address(rom_addr4),
        .clock(clk),
        .q(rom_q4)
    );

    RAM_Decrypt U54(
        .address(dram_addr4),
        .clock(clk),
        .data(dram_data4),
        .wren(dram_wren4),
        .q(dram_q4)
    );

    decrypter U64(
        .clk(clk),
        .reset(reset4),
        .start(s_finished_b4),
        .found(found),
        .rom_q(rom_q4),
        .s_q(s_q4),
        .restart(restart4),
        .finished(s_finished_c4),
        .s_decrypt_wren(s_decrypt_wren4),
        .dram_wren(dram_wren4),
        .s_decrypt_data(s_decrypt_data4),
        .s_decrypt_addr(s_decrypt_addr4),
        .dram_data(dram_data4),
        .dram_addr(dram_addr4),
        .rom_addr(rom_addr4)
    );

    increment_key U74(
        .clk(clk),
        .restart(restart4),
        .reset(~KEY[3]),
        .setter(22'h3FFFFF),
        .number(22'h300000),
        .done(done4),
        .count_key(count_key4)
    );

    //dont touch ssdisplay set this should display hex of whichever core gets it
    logic [23:0] sel_key;

    assign sel_key = (s_finished_c)  ? (secret_key)  :
                     (s_finished_c2) ? (secret_key2) :
                     (s_finished_c3) ? (secret_key3) :
                     (s_finished_c4) ? (secret_key4) :
                     secret_key4; 

    SevenSegmentDisplayDecoder ssHEX0(
        .ssOut(HEX0),
        .nIn(sel_key[3:0])
    );

    SevenSegmentDisplayDecoder ssHEX1(
        .ssOut(HEX1),
        .nIn(sel_key[7:4])
    );

    SevenSegmentDisplayDecoder ssHEX2(
        .ssOut(HEX2),
        .nIn(sel_key[11:8])
    );

    SevenSegmentDisplayDecoder ssHEX3(
        .ssOut(HEX3),
        .nIn(sel_key[15:12])
    );

    SevenSegmentDisplayDecoder ssHEX4(
        .ssOut(HEX4),
        .nIn(sel_key[19:16])
    );

    SevenSegmentDisplayDecoder ssHEX5(
        .ssOut(HEX5),
        .nIn(sel_key[23:20])
    );

    // RESULTS of Core 1, 2, 3, 4
    logic found;
    assign found =   s_finished_c | s_finished_c2 | s_finished_c3 | s_finished_c4;
    assign LEDR[0] = s_finished_a | s_finished_a2 | s_finished_a3 | s_finished_a4;
    assign LEDR[1] = s_finished_b | s_finished_b2 | s_finished_b3 | s_finished_b4;
    assign LEDR[2] = done;
    assign LEDR[3] = done2;
    assign LEDR[4] = done3;
    assign LEDR[5] = done4;
    assign LEDR[6] = s_finished_c;
    assign LEDR[7] = s_finished_c2;
    assign LEDR[8] = s_finished_c3;
    assign LEDR[9] = s_finished_c4;

endmodule