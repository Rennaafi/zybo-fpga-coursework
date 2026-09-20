// ============================================================
// tick_generator.v
// Generates a single-cycle ENABLE PULSE (tick) on the ORIGINAL
// clock domain. No new clock is created.
// ============================================================
module tick_generator #(
    parameter MAX_COUNT = 124_999_999   // cycles before pulsing tick
                                         // (real value for 1Hz from 125MHz)
)(
    input  wire clk,
    input  wire rst,
    output reg  tick
);

    reg [26:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            tick  <= 0;
        end
        else begin
            if (count == MAX_COUNT) begin
                count <= 0;
                tick  <= 1;
            end
            else begin
                count <= count + 1;
                tick  <= 0;
            end
        end
    end

endmodule