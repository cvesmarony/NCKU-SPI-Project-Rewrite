module clkgen (
        input wire          clk,
        input wire          rst,
        input wire [2:0]    divider,
        input wire          cpol,
        input wire          cs,

        output reg          sclk
    );

    reg [15:0]      count;
    reg [15:0]      div;
    always @ (*) begin
        case (divider)
            3'b000:      div <= 1;
            3'b001:      div <= 4;
            3'b010:      div <= 8;
            3'b011:      div <= 16;
            default:    div <= 4;
        endcase
    end

    always @ (posedge clk or posedge rst) begin
        // $display("cpol:", cpol);
        if (rst) begin
            sclk <= 0;      // needed to be 0 instead of cpol
            count <= 0;
        end else begin
            if (~cs) begin
                if (count >= div) begin
                    count <= 0;
                    sclk <= ~sclk;
                end else begin
                    count <= count + 1;
                end
            end else begin
                if (cpol) begin
                    sclk <= 1;
                end else begin
                    sclk <= 0;
                end
                count <= 0;
            end
        end
    end

endmodule