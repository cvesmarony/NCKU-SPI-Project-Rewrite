module spi_leader (
        input wire          clk,        // System clock
        input wire          rst,
        input wire          start,
        input wire [7:0]    data_in,
        input wire          miso,
        output wire         sclk,       // SPI clock output
        output wire         mosi,
        output wire         CS
    );

    parameter [7:0] DATA_LEN;
    parameter CPOL = 0, CPHA = 0;

    reg  [7:0] tx_data;
    wire [7:0] tx_out;
    wire       shift_sig, sample_sig;
    reg        load_tx, load_rx;
    reg  [2:0] bit_count;
    reg  [7:0] rx_data;
    wire [7:0] rx_out;
    reg        TIP;
    wire [7:0] divider = 8'd4; // Set this to whatever (SPI clk = sys_clk / 8)

    reg [DATA_LEN-1:0] tx;
    reg [DATA_LEN-1:0] rx;

    // States
    typedef enum logic [1:0] {
        IDLE, LOAD, TRANSFER, DONE
    } state_t;

    state_t state = IDLE;


    spi_clkgen clkgen_inst (
        .sys_clk(clk),
        .rst(rst),
        .divider(divider),
        .TIP(TIP),
        .CS(CS),
        .CPOL(CPOL),
        .CPHA(CPHA),
        .clk_out(sclk),
        .shift(shift_sig),
        .sample(sample_sig)
    );

    shift_reg tx_shift (
        .clk(clk),
        .rst(rst),
        .load(load_tx),
        .shift(shift_sig),
        .d_in(tx_data),
        .TOP(mosi),
        .d_out(tx_out)
    );

    shift_reg rx_shift (
        .clk(clk),
        .rst(rst),
        .load(load_rx),
        .shift(shift_sig),
        .d_in(rx_data),
        .TOP(mosi),
        .d_out(rx_out)
    );
    
    reg [7:0] rx_shift;

    always @(posedge clk) begin
        if (rst) begin
            rx_shift <= 0;
        end else if (sample_sig) begin
            rx_shift <= {rx_shift[6:0], miso};
        end
    end

    assign rx_out = rx_shift;

    always @(posedge(clk)) begin
        if (rst) begin
            state <= IDLE;
            TIP <= 0;
            CS <= 0;

        end else begin
            case (state)
                START:

                LOAD:

                TRANSFER:

                DONE:

            endcase
        end
    end
    
endmodule
