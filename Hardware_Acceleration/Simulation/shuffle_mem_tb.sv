module shuffle_mem_tb();

    reg clk;
    reg start;

    reg [23:0] secret_key;

    wire [7:0] s_q;
    wire [7:0] s_data;
    wire [7:0] s_addr;

    wire wren;
    wire finished;


    // Expected software result
    reg [7:0] expected [0:255];

    reg [7:0] temp;
    reg [7:0] key_byte;

    integer i;
    integer j;
    integer errors;


    //-----------------------------------------
    // Clock
    //-----------------------------------------

    initial begin
        clk = 0;

        forever
            #10 clk = ~clk;
    end


    //-----------------------------------------
    // Your shuffle FSM
    //-----------------------------------------

    shuffle_mem DUT(
        .clk(clk),
        .start(start),
        .s_q(s_q),
        .secret_key(secret_key),

        .wren(wren),
        .finished(finished),
        .s_data(s_data),
        .s_addr(s_addr)
    );


    //-----------------------------------------
    // Fake S RAM
    //-----------------------------------------

    s_memory_model RAM(
        .clk(clk),
        .address(s_addr),
        .data(s_data),
        .wren(wren),
        .q(s_q)
    );


    //-----------------------------------------
    // Test
    //-----------------------------------------

    initial begin

        start = 0;

        // Lab example key
        secret_key = 24'h000249;

        errors = 0;


        //-------------------------------------
        // Make expected S array
        //-------------------------------------

        for (i = 0; i < 256; i = i + 1)
            expected[i] = i;


        //-------------------------------------
        // Perform RC4 KSA in the testbench
        //-------------------------------------

        j = 0;

        for (i = 0; i < 256; i = i + 1) begin

            case (i % 3)

                0:
                    key_byte = secret_key[23:16];

                1:
                    key_byte = secret_key[15:8];

                2:
                    key_byte = secret_key[7:0];

                default:
                    key_byte = 8'h00;

            endcase


            // 8-bit arithmetic automatically gives mod 256
            j = (j + expected[i] + key_byte) & 8'hFF;


            // swap
            temp = expected[i];

            expected[i] = expected[j];

            expected[j] = temp;

        end


        //-------------------------------------
        // Start hardware FSM
        //-------------------------------------

        @(posedge clk);

        start = 1;

        @(posedge clk);

        start = 0;


        //-------------------------------------
        // Wait for hardware to finish
        //-------------------------------------

        wait(finished == 1);

        @(posedge clk);


        //-------------------------------------
        // Compare all 256 bytes
        //-------------------------------------

        for (i = 0; i < 256; i = i + 1) begin

            if (RAM.mem[i] !== expected[i]) begin

                $display(
                    "ERROR: S[%02h] expected %02h, got %02h",
                    i,
                    expected[i],
                    RAM.mem[i]
                );

                errors = errors + 1;

            end

        end


        //-------------------------------------
        // Result
        //-------------------------------------

        if (errors == 0)
            $display("PASS: Shuffle is correct!");

        else
            $display("FAIL: %0d locations incorrect.", errors);


        $stop;

    end

endmodule