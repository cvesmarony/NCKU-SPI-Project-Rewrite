module shift_reg_tb (
        
    );

    shift_reg #(
        .DATA_LEN(DATA_LEN)
    ) dut (
        .clk(clk),
        .rst(rst),
        .load(load_tx),
        .shift(shift_sig),
        .d_in(tx_data),
        .serial_in(),
        .TOP(mosi),
        .d_out(tx_out)
    );

    initial begin
        $dumpfile("shift1.vcd");
        $dumpvars(0, shift_reg_tb);
    end

endmodule