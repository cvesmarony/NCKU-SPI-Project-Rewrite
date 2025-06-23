`include "spi_defines.vh"

module spi_leader #(
    parameter DATA_LEN = `DATA_LEN,
    parameter CPOL = `CPOL,
    parameter CPHA = `CPHA
    )(
        input  wire                   clk,        // System clock
        input  wire                   rst,
        input  wire                   start,      // Start transfer
        input  wire [DATA_LEN-1:0]    data_in,    // Data to transmit
        input  wire                   miso,       // Master In Slave Out
        output wire                   sclk,       // SPI clock output
        output wire                   mosi,       // Master Out Slave In
        output reg                    CS          // Chip select (active low)
    );

    // Internal control
    reg [DATA_LEN-1:0] tx_data;
    reg [DATA_LEN-1:0] rx_data;
    wire [DATA_LEN-1:0] tx_out;
    wire [DATA_LEN-1:0] rx_out;
    reg  load_tx, load_rx;
    reg  TIP;

    reg [$clog2(DATA_LEN):0] bit_count;
    wire shift_sig, sample_sig;
    wire [DATA_LEN-1:0] divider = 8'd4;  // SPI clk = sys_clk / 8

    // State machine
    typedef enum logic [1:0] {
        IDLE, LOAD, TRANSFER, DONE
    } state_t;

    state_t state;

    // Instantiate clock generator
    spi_clkgen #(
        .DIV_WIDTH(`DIV_WIDTH)
    ) clkgen_inst (
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

    // TX shift register
    shift_reg #(
        .DATA_LEN(DATA_LEN)
    ) tx_shift (
        .clk(clk),
        .rst(rst),
        .load(load_tx),
        .shift(shift_sig),
        .d_in(tx_data),
        .serial_in(),
        .TOP(mosi),
        .d_out(tx_out)
    );

    // RX shift register
    shift_reg #(
        .DATA_LEN(DATA_LEN)
    ) rx_shift (
        .clk(clk),
        .rst(rst),
        .load(load_rx),
        .shift(sample_sig),          // Sample on sample signal
        .d_in('0),                   // Load nothing
        .serial_in(miso),
        .TOP(),                      // Unused
        .d_out(rx_out)
    );


    // FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            CS        <= 1;  // Not selected
            load_tx   <= 0;
            load_rx   <= 0;
            TIP       <= 0;
            bit_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    CS <= 1;
                    TIP <= 0;
                    load_tx <= 0;
                    load_rx <= 0;
                    bit_count <= 0;

                    if (start) begin
                        tx_data <= data_in;
                        state <= LOAD;
                    end
                end

                LOAD: begin
                    load_tx <= 1;
                    load_rx <= 1;
                    CS <= 0;      // Assert CS
                    TIP <= 1;
                    state <= TRANSFER;
                end

                TRANSFER: begin
                    load_tx <= 0;
                    load_rx <= 0;

                    if (sample_sig) begin
                        bit_count <= bit_count + 1;
                        rx_data <= rx_out
                    end

                    if (bit_count == DATA_LEN) begin
                        TIP <= 0;
                        state <= DONE;
                    end
                end

                DONE: begin
                    CS <= 1;  // Deassert CS
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
