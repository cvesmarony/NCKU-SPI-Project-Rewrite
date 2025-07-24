module top (
    input  wire        clk,
    input  wire        rst,
    input  wire        in,
    inout  wire [7:0]  data,
    inout  wire        cs,
    inout  wire        ext_clk,
    output wire        out,
    output wire        ready
);

    // Configuration Settings
    reg [7:0]   config_reg;
    reg         config_set;
    reg set;
    
    // State machine
    parameter ST_CONFIG = 2'b00;
    parameter ST_READY   = 2'b01;
    parameter ST_TX_RX   = 2'b10;
    parameter ST_TRANSFER = 2'b11;

    reg [1:0] state;

    // Configuration fields
    wire        mode  = config_reg[7];  // 1 = leader, 0 = follower
    wire        len   = config_reg[6];  // 1 = 16 bits, 0 = 8 bits
    wire        cpol  = config_reg[5];  // clock polarity
    wire        cpha  = config_reg[4];  // clock phase
    wire [2:0]  div   = config_reg[3:1]; // divider
    
    reg [4:0] count;
    wire [4:0] data_len = len ? 16 : 8;

    // Clock signals
    wire sclk, sclk_pe, sclk_ne;

    // Data buffers
    reg [7:0] txi, rxi;
    wire [7:0] txo, rxo;

    // CPU interface
    reg data_en;
    wire [7:0] data_in = data;
    assign data = data_en ? rxo : 8'bz;
    assign ready = set;  // Ready signal indicates configuration complete

    // Shift control
    reg shift_tx, shift_rx;
    reg sample_tx, sample_rx;
    reg first_edge;
    reg shift_edge, sample_edge;
    // CS and clock control
    reg cs_en;
    reg cs_out;
    wire cs_in = cs;
    assign cs = cs_en ? cs_out : 1'bz;

    reg ext_clk_en;

    assign ext_clk = ext_clk_en ? sclk : 1'bz;
    reg load;


    // Instantiate clock generator and edge detectors
    clkgen clock (
        .clk(clk),
        .rst(rst),
        .divider(div),
        .cpol(cpol),
        .cs(cs),
        .sclk(sclk)
    );

    pos_edge_detect ped(.sig(sclk), .clk(clk), .pe(sclk_pe));
    neg_edge_detect ned(.sig(sclk), .clk(clk), .ne(sclk_ne));

    // Shift registers
    shift_reg transmit (
        .clk(clk),
        .rst(rst),
        .data_in(txi),
        .sample_en(sample_tx),
        .shift_en(shift_tx),
        .serial_in(1'b1),
        .serial_out(out),
        .data_out(txo),
        .load(load)
    );

    shift_reg receive (
        .clk(clk),
        .rst(rst),
        .data_in(rxi),
        .sample_en(sample_rx),
        .shift_en(shift_rx),
        .serial_in(in),
        .serial_out(),
        .data_out(rxo),
        .load(load)
    );

    // Main state machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= ST_CONFIG;
            config_set <= 0;
            config_reg <= 8'b00000001;
            data_en <= 0;
            count <= 0;
            first_edge <= 0;
            txi <= 0;
            rxi <= 0;
            shift_tx <= 0;
            shift_rx <= 0;
            sample_tx <= 0;
            sample_rx <= 0;
            cs_out <= 1;
        end else begin
            // Default values
            shift_tx <= 0;
            shift_rx <= 0;
            sample_tx <= 0;
            sample_rx <= 0;
            
            case (state)
                ST_CONFIG: begin
                    if (~config_set) begin
                        config_reg <= data_in;
                        if (config_reg[0] == 1'b0) begin  // Only capture non-zero config
                            config_set <= 1;
                            set <= 1;
                            data_en <= 0;  // Release bus after config
                        end
                    end else begin
                        state <= ST_READY;
                    end
                end
                
                ST_READY: begin
                    set <= 0;
                    if (mode) begin // Leader mode
                        if (data_in != config_reg) begin // Valid data received
                            txi <= data_in;
                            
                            count <= 0;
                            state <= ST_TX_RX;
                            load <= 1;
                            data_en <= 0;  // Release bus
                            // cs_out <= 0;   // Assert CS
                        end
                    end else begin // Follower mode
                        if (~cs_in) begin
                            count <= 0;
                            state <= ST_TX_RX;
                            first_edge <= 0;
                            load <= 1;
                        end
                    end
                end
                
                ST_TX_RX: begin
                    cs_out <= 0;
                    load <= 0;
                    
                    $display("txi: ", txi);
                    $display("rxi: ", rxi);
                    $display("txo: ", txo);
                    $display("rxo: ", rxo);
                    $display("in: ", in);

                    if (count < data_len && config_set) begin      // check logic
                        data_en <= 1;
                    end else if (data_en && (count == data_len)) begin
                        state <= ST_TRANSFER;
                    end

                    txi <= txo;
                    rxi <= rxo;
                    // has not sent/received all bits yet and if cs is on and after config
                    if ((count < data_len) && ~cs && config_set && ~load) begin          // check logic for cs as it is inout
                    // while (count < data_len) begin
                        // $display("COUNTING") ;
                        // Detecing shift and sample edges
                        shift_edge  = (cpol == cpha) ? sclk_ne : sclk_pe;
                        sample_edge = (cpol == cpha) ? sclk_pe : sclk_ne;
                        
                        // Determining when to shift and sample
                        if (cpha == 0) begin
                            // $display("YAY");
                            shift_tx <= shift_edge;
                            shift_rx <= shift_edge;
                            sample_tx <= sample_edge;
                            sample_rx <= sample_edge;
                        end else begin
                            if (first_edge) begin
                                shift_tx    <= shift_edge;
                                shift_rx  <= shift_edge;
                                sample_tx   <= sample_edge;
                                sample_rx <= sample_edge;
                            end else if (shift_edge || sample_edge)
                                first_edge <= 1;  // Mark the first clock edge seen
                        end
                    end 

            if (shift_tx) begin
                count <= count + 1;
                $display("shifted");
            end

                end

            ST_TRANSFER: begin
                set <= 1;
                $display("rxo: ", rxo);
                $display("data: ", data);

            end
            endcase

        end
    end

    always @(*) begin
        cs_en = mode;
        ext_clk_en = mode;
    end

endmodule