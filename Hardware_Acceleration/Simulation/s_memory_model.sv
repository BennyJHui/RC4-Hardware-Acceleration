module s_memory_model(
    input clk,
    input [7:0] address,
    input [7:0] data,
    input wren,
    output [7:0] q
);

    reg [7:0] mem [0:255];
    reg [7:0] read_address;

    integer k;

    initial begin
        for (k = 0; k < 256; k = k + 1)
            mem[k] = k;
    end

    always @(posedge clk) begin
        read_address <= address;

        if (wren)
            mem[address] <= data;
    end

    assign q = mem[read_address];

endmodule