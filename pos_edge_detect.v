module pos_edge_detect(
        input wire sig,
        input wire clk,
        output wire pe
    );
    
    reg sig_dly;
    always @ (posedge clk) sig_dly <= sig;
    assign pe = sig & ~sig_dly;
endmodule
