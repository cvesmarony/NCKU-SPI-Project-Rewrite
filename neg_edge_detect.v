module neg_edge_detect(
        input wire sig,
        input wire clk,
        output wire ne
    );
    
    reg sig_dly;
    always @(posedge clk) sig_dly <= sig;
    assign ne = sig_dly & ~sig;
endmodule
