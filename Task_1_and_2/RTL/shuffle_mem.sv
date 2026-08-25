`define IDLE 4'b0000
`define MODULATE 4'b0001
`define GET_SI 4'b0010
`define CALC 4'b0011
`define ADDR_SJ 4'b1000
`define GET_SJ 4'b0100
`define TEMP 4'b0101
`define INCREMENT 4'b0111
`define CHECK 4'b1001
`define WAIT_SI 4'b1010
`define WR_J 4'b1011
`define WR_I 4'b1100
`define COMPLETED 4'b1101
`define WAIT_SJ 4'b1110


module shuffle_mem(
    input clk, reset, start,
    input [7:0] s_q,
    input [23:0] secret_key,
    output reg wren, finished,
    output reg [7:0] s_data, s_addr
);

    reg [7:0] i, j; // therefore ignore mod 256 in calc, because
    reg [7:0] secret_key_sel, si, sj, s_tempi, s_tempj;
    reg [3:0] state = `IDLE;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= `IDLE;
        end else begin
            case(state)
                `IDLE: state <= (start) ? `MODULATE : `IDLE;

                `MODULATE: state <= `WAIT_SI;

                `WAIT_SI: state <= `GET_SI;

                `GET_SI: state <= `CALC;

                `CALC: state <= `ADDR_SJ;

                `ADDR_SJ: state <= `WAIT_SJ;

                `WAIT_SJ: state <= `GET_SJ;

                `GET_SJ: state <= `TEMP;

                `TEMP: state <= `WR_J;

                `WR_J: state <= `WR_I;

                `WR_I: state <= `CHECK;

                `CHECK: begin
                    if (i == 8'hFF)
                        state <= `COMPLETED;
                    else
                        state <= `INCREMENT;
                end

                `INCREMENT: state <= `MODULATE;

                `COMPLETED: state <= `COMPLETED;

                default: state <= `IDLE;
            endcase
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            wren <= 0;
            finished <= 0;
            i <= 0;
            j <= 0;
            secret_key_sel <= 0;
            si <= 0;
            sj <= 0;
            s_tempi <= 0;
            s_tempj <= 0;
            s_data <= 0;
            s_addr <= 0;
        end else begin
            case(state)
                `IDLE: begin
                    wren <= 0;
                    finished <= 0;
                    i <= 0;
                    j <= 0;
                    secret_key_sel <= 0;
                    si <= 0;
                    sj <= 0;
                    s_tempi <= 0;
                    s_tempj <= 0;
                    s_data <= 0;
                    s_addr <= 0;
                end

                `MODULATE: begin
                    case(i % 3)
                        2'b00: secret_key_sel <= secret_key[23:16];

                        2'b01: secret_key_sel <= secret_key[15:8];

                        2'b10: secret_key_sel <= secret_key[7:0];

                        default: secret_key_sel <= 8'b0;
                    endcase

                    s_addr <= i;
                end

                `WAIT_SI: begin
                    
                end

                `GET_SI: si <= s_q;

                `CALC: j <= j + si + secret_key_sel;

                `ADDR_SJ: s_addr <= j;

                `WAIT_SJ: begin

                end

                `GET_SJ: sj <= s_q;

                `TEMP: begin
                    s_tempi <= si;
                    s_tempj <= sj;
                end

                `WR_J: begin
                    wren <= 1;
                    s_addr <= i;
                    s_data <= s_tempj;
                end

                `WR_I: begin
                    s_addr <= j;
                    s_data <= s_tempi;
                end

                `CHECK: begin
                    wren <= 0;
                end

                `INCREMENT: i <= i + 1;

                `COMPLETED: begin
                    wren <= 0;
                    finished <= 1;
                end
            endcase
        end
    end

endmodule