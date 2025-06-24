module shift_reg_tb;

    parameter DATA_LEN = 8;
    reg clk = 0, rst = 0, load_en = 0, shift_en = 0;
    reg [DATA_LEN-1:0] d_in;
    reg serial_in = 1'b1;
    wire serial_out;
    wire [DATA_LEN-1:0] d_out;

    always #5 clk = ~clk;

    shift_reg #(.DATA_LEN(DATA_LEN)) dut (
        .clk(clk),
        .rst(rst),
        .d_in(d_in),
        .load_en(load_en),
        .shift_en(shift_en),
        .serial_in(serial_in),
        .serial_out(serial_out),
        .d_out(d_out)
    );

    initial begin
        $display("=== Shift Register Test ===");
        $dumpfile("shift_reg_tb.vcd");
        $dumpvars(0, shift_reg_tb);

        rst = 1; #10; rst = 0;

        d_in = 8'b10110011;
        load_en = 1; #10; load_en = 0;

        repeat (8) begin
            shift_en = 1; #10; shift_en = 0;
            #10;
        end

        $finish;
    end
endmodule