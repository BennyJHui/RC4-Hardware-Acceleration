`define IDLE 2'b00
`define INITIALIZE 2'b01
`define COMPLETED 2'b10

module init_s_mem(
    input clk,
    input reset,
    output reg [7:0] addr,
    output reg [7:0] data,
    output reg wren,
    output reg finished
);

    reg [7:0] count;
    reg [1:0] state = `IDLE;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= `IDLE;
            finished <= 0;
            count <= 0;
            wren <= 0;
        end else begin
            case(state) 
                `IDLE: begin 
                    state <= `INITIALIZE;
                    finished <= 0;
                    count <= 0;
                    wren <= 0;
                end

                `INITIALIZE: begin
                    if (count == 8'hFF) begin
                        addr <= count;
                        data <= count;
                        state <= `COMPLETED;
                    end else begin
                        wren <= 1;
                        addr <= count;
                        data <= count;
                        count <= count + 1;
                    end
                end

                `COMPLETED: begin
                    count <= 0;
                    wren <= 0;
                    finished <= 1;
                end

                default: state <= `IDLE;
            endcase
        end
    end

endmodule