module increment_key(
    input clk,
    input restart,
    input reset,
    input [21:0] setter,
    input [21:0] number,
    output reg done,
    output reg [21:0] count_key
);

    always_ff @(posedge clk) begin
        if (restart) begin
            if (count_key == setter) begin
                done <= 1;
            end else begin
                count_key <= count_key + 1;
                done <= 0;
            end
        end

        if (reset) begin
            count_key <= number;
            done <= 0;
        end
    end

endmodule