module big_tb;

    reg sys_clk = 0, rst = 1;
    reg [2:0] divider = 3'b1;
    reg cpol, cpha;
    reg cs = 0;

    wire sclk;
    wire sclk_pe, sclk_ne;

    // SPI wires
    wire mosi_from_leader;
    wire miso_from_follower;

    reg [7:0] leader_data_in = 8'hA5;    // LSB-first: 10100101
    reg [7:0] ogl = 8'hA5;
    wire [7:0] leader_data_out;
    reg [7:0] follower_data_in = 8'h3C;  // LSB-first: 00111100
    reg [7:0] ogf = 8'h3C;
    wire [7:0] follower_data_out;

    reg start = 0;
    reg shift_leader = 0;
    reg shift_follower = 0;
    reg sample_leader = 0; 
    reg sample_follower = 0;

    // reg [4:0] count = 0;
    integer count;
    integer mode;
    reg shift_edge, sample_edge;

    reg first_edge;

    // Generate system clock
    always #5 sys_clk = ~sys_clk;

    // Instantiate clkgen
    clkgen clkgen_inst (
        .clk(sys_clk),
        .rst(rst),
        .divider(divider),
        .cpol(cpol),
        .cs(cs),
        .sclk(sclk)
    );

    // Edge detectors on SCLK
    pos_edge_detect ped(.sig(sclk), .clk(sys_clk), .pe(sclk_pe));
    neg_edge_detect ned(.sig(sclk), .clk(sys_clk), .ne(sclk_ne));

    // Leader shift register (sample on CPHA edge)
    shift_reg leader (
        .clk(sys_clk),
        .rst(rst),
        .data_in(leader_data_in),
        .sample_en(sample_leader),
        .shift_en(shift_leader),
        .serial_in(miso_from_follower),
        .serial_out(mosi_from_leader),
        .data_out(leader_data_out)
    );

    // Follower shift register (sample on CPHA edge)
    shift_reg follower (
        .clk(sys_clk),
        .rst(rst),
        .data_in(follower_data_in),
        .sample_en(sample_follower),
        .shift_en(shift_follower),
        .serial_in(mosi_from_leader),
        .serial_out(miso_from_follower),
        .data_out(follower_data_out)
    );

    initial begin
        // Dump waves for viewing
        $dumpfile("big_tb.vcd");
        $dumpvars(0, big_tb);

        $display("=== SPI Shift Register CPOL/CPHA Test ===");

        // Initialize
        #10 rst = 0;

        // Loop through all 4 SPI modes
        for (mode = 0; mode < 4; mode = mode + 1) begin
            cs = 1;
            #20;

            cpol = mode[1];
            cpha = mode[0];
            $display("\n--- Testing SPI Mode %0d (CPOL=%b, CPHA=%b) ---", mode, cpol, cpha);

            // Reset shift registers
            rst = 1;
            #10 rst = 0;
            leader_data_in <= ogl;
            follower_data_in <= ogf;

            count = 0;
            first_edge = 0;
            cs = 0;


            // Simulate 9 SCLK cycles (32 sys_clk for half cycles)
            // repeat (36) begin
            while (count < 8) begin          // need to implement a check
                @(posedge sys_clk);

                shift_edge  = (cpol == cpha) ? sclk_ne : sclk_pe;
                sample_edge = (cpol == cpha) ? sclk_pe : sclk_ne;

                if (cpha == 0) begin
                    shift_leader    <= shift_edge;
                    shift_follower  <= shift_edge;
                    sample_leader   <= sample_edge;
                    sample_follower <= sample_edge;
                end else begin
                    if (first_edge) begin
                        shift_leader    <= shift_edge;
                        shift_follower  <= shift_edge;
                        sample_leader   <= sample_edge;
                        sample_follower <= sample_edge;
                    end else if (shift_edge || sample_edge)
                        first_edge <= 1;  // Mark the first clock edge seen
                end

                // if (shift_leader) count = count + 1;
                leader_data_in <= leader_data_out;
                follower_data_in <= follower_data_out;

                // Print debug info for each sys_clk posedge
                $display("Time %4t | SCLK=%b | sclk_pe=%b sclk_ne=%b | shift=%b sample=%b | Leader dout=0x%02h | Follower dout=0x%02h",
                    $time, sclk, sclk_pe, sclk_ne, shift_leader, sample_leader, leader_data_out, follower_data_out);


            end

            // Clear shift enables
            shift_leader = 0;
            shift_follower = 0;
            sample_leader = 0;
            sample_follower = 0;

            $display("  Leader Sent:    0x%02h | Received: 0x%02h", ogl, follower_data_out);
            $display("  Follower Sent:  0x%02h | Received: 0x%02h", ogf, leader_data_out);
        end

        $display("\nTestbench complete.");
        $finish;
    end

    always @(posedge sys_clk) begin
        if (shift_leader) begin
            count <= count + 1;
        end
    end

endmodule
