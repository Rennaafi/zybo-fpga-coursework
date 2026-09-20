// ============================================================
// clock_divider.v
// Generates a slower CLOCK signal (clk_div) by toggling a
// register every time an internal counter reaches HALF_PERIOD.
// This is the "new derived clock" approach from Chapter 6.
// ============================================================
module clock_divider #(
    parameter HALF_PERIOD = 62_499_999   // cycles to count before toggling
                                          // (real value for 1Hz from 125MHz)
)(
    input  wire clk,
    input  wire rst,
    output reg  clk_div
);

    reg [26:0] clk_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_count <= 0;
            clk_div   <= 0;
        end
        else begin
            if (clk_count == HALF_PERIOD) begin
                clk_count <= 0;
                clk_div   <= ~clk_div;
            end
            else begin
                clk_count <= clk_count + 1;
            end
        end
    end

endmodule