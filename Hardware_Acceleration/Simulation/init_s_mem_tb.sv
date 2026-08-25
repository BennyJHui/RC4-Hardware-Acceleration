module init_s_mem_tb();

    reg clk_tb;
    wire [7:0] addr_tb, data_tb;
    wire wren_tb, finished_tb;


    init_s_mem U(
        .clk(clk_tb),
        .addr(addr_tb),
        .data(data_tb),
        .wren(wren_tb),
        .finished(finished_tb)
    );

    initial begin
        clk_tb = 0;
        #2;
        forever begin
            clk_tb = ~clk_tb;
            #2;
        end
    end

    initial begin
        #1200;
        $stop;
    end

endmodule