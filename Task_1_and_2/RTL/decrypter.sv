`define IDLE 5'b00000
`define INCREMENT_I 5'b00001
`define GET_ADDR_SI 5'b00010
`define WAIT_SI 5'b00011
`define READ_ADDR_SI 5'b00100
`define CALC_J 5'b00101
`define GET_ADDR_SJ 5'b00110
`define WAIT_SJ 5'b00111
`define READ_ADDR_SJ 5'b01000
`define TEMP_SWAP 5'b01001
`define WR_I 5'b01010
`define WR_J 5'b01011
`define CALC_SI_SJ 5'b01100
`define GET_ADDR_SI_SJ 5'b01101
`define WAIT_SI_SJ 5'b01110
`define READ_ADDR_SI_SJ 5'b01111
`define GET_ADDR_ROM 5'b10000
`define WAIT_ROM 5'b10001
`define READ_ADDR_ROM 5'b10010
`define CALC_XOR 5'b10011
`define LOAD_RAM 5'b10100
`define CHECK 5'b10101
`define INCREMENT_K 5'b10110
`define COMPLETED 5'b10111

module decrypter(
    input clk,
    input reset,
    input start,
    input [7:0] rom_q,
    input [7:0] s_q,
    output reg finished,
    output reg s_decrypt_wren,
    output reg dram_wren,
    output reg [7:0] s_decrypt_data,
    output reg [7:0] s_decrypt_addr,
    output reg [7:0] dram_data,
    output reg [4:0] dram_addr,
    output reg [4:0] rom_addr
);

    reg [4:0] state = `IDLE;
    reg [7:0] i, j, f, temp_si, temp_sj, si, sj, sum_si_sj, temp_sq, temp_decrypt;
    reg [4:0] k;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= `IDLE;
        end else begin
            case(state)
                `IDLE: state <= (start) ? `INCREMENT_I : `IDLE;

                `INCREMENT_I: state <= `GET_ADDR_SI;

                `GET_ADDR_SI: state <= `WAIT_SI;

                `WAIT_SI: state <= `READ_ADDR_SI;

                `READ_ADDR_SI: state <= `CALC_J;

                `CALC_J: state <= `GET_ADDR_SJ;

                `GET_ADDR_SJ: state <= `WAIT_SJ;

                `WAIT_SJ: state <= `READ_ADDR_SJ;

                `READ_ADDR_SJ: state <= `TEMP_SWAP;

                `TEMP_SWAP: state <= `WR_I;

                `WR_I: state <= `WR_J;

                `WR_J: state <= `CALC_SI_SJ;

                `CALC_SI_SJ: state <= `GET_ADDR_SI_SJ;

                `GET_ADDR_SI_SJ: state <= `WAIT_SI_SJ;

                `WAIT_SI_SJ: state <= `READ_ADDR_SI_SJ;

                `READ_ADDR_SI_SJ: state <= `GET_ADDR_ROM;

                `GET_ADDR_ROM: state <= `WAIT_ROM;

                `WAIT_ROM: state <= `READ_ADDR_ROM;

                `READ_ADDR_ROM: state <= `CALC_XOR;
                
                `CALC_XOR: state <= `LOAD_RAM;

                `LOAD_RAM: state <= `CHECK;

                `CHECK: state <= (k == 5'd31) ? `COMPLETED : `INCREMENT_K;

                `INCREMENT_K: state <= `INCREMENT_I;

                `COMPLETED: state <= `COMPLETED;

                default: state <= `IDLE;
            endcase
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            finished <= 0;
            s_decrypt_wren <= 0;
            dram_wren <= 0;
            s_decrypt_data <= 0;
            s_decrypt_addr <= 0;
            dram_data <= 0;
            dram_addr <= 0;
            rom_addr <= 0;
            temp_si <= 0;
            temp_sj <= 0;
            temp_sq <= 0;
            temp_decrypt <= 0;
            si <= 0;
            sj <= 0;
            sum_si_sj <= 0;
            f <= 0;
            i <= 0;
            j <= 0;
            k <= 0;
        end else begin
            case(state)
                `IDLE: begin
                    finished <= 0;
                    s_decrypt_wren <= 0;
                    dram_wren <= 0;
                    s_decrypt_data <= 0;
                    s_decrypt_addr <= 0;
                    dram_data <= 0;
                    dram_addr <= 0;
                    rom_addr <= 0;
                    temp_si <= 0;
                    temp_sj <= 0;
                    temp_sq <= 0;
                    temp_decrypt <= 0;
                    si <= 0;
                    sj <= 0;
                    sum_si_sj <= 0;
                    f <= 0;
                    i <= 0;
                    j <= 0;
                    k <= 0;
                end

                `INCREMENT_I: i <= i + 1;

                `GET_ADDR_SI: s_decrypt_addr <= i;

                `WAIT_SI: begin
                    // nothing
                end

                `READ_ADDR_SI: si <= s_q;

                `CALC_J: j <= j + si;

                `GET_ADDR_SJ: s_decrypt_addr <= j;

                `WAIT_SJ: begin
                    // nothing
                end

                `READ_ADDR_SJ: sj <= s_q;

                `TEMP_SWAP: begin
                    temp_si <= si;
                    temp_sj <= sj;
                end

                `WR_I: begin
                    s_decrypt_wren <= 1;
                    s_decrypt_data <= temp_sj;
                    s_decrypt_addr <= i;
                end

                `WR_J: begin
                    s_decrypt_data <= temp_si;
                    s_decrypt_addr <= j;
                end

                `CALC_SI_SJ: begin
                    s_decrypt_wren <= 0;
                    sum_si_sj <= temp_si + temp_sj;
                end

                `GET_ADDR_SI_SJ: s_decrypt_addr <= sum_si_sj;

                `WAIT_SI_SJ: begin
                    // nothing
                end

                `READ_ADDR_SI_SJ: f <= s_q;

                `GET_ADDR_ROM: rom_addr <= k;

                `WAIT_ROM: begin
                    // nothing
                end

                `READ_ADDR_ROM: temp_sq <= rom_q;

                `CALC_XOR: temp_decrypt <= f ^ temp_sq;

                `LOAD_RAM: begin
                    dram_wren <= 1;
                    dram_data <= temp_decrypt;
                    dram_addr <= k;
                end

                `CHECK: dram_wren <= 0;

                `INCREMENT_K: k <= k + 1;

                `COMPLETED: begin
                    finished <= 1;
                end
            endcase
        end
    end

endmodule