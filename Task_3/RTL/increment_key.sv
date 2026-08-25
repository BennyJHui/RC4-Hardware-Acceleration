module increment_key(
    input clk,
    input restart,
    input reset,
    output reg [21:0] count_key
);

    always_ff @(posedge clk) begin
        if (restart) begin
            count_key <= count_key + 1;
        end

        if (reset) begin
            count_key <= 0;
        end
    end

endmodule