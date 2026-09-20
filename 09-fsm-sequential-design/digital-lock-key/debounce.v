// ============================================================
// debounce.v
// Generic debouncer. Samples `noisy_in` once per `tick_en` pulse
// (tick_en should come from clock_divider, e.g. ~1kHz) and only
// updates `clean_out` once the input has been stable for
// DEBOUNCE_TICKS consecutive samples.
// ============================================================
module debounce #(
    parameter integer DEBOUNCE_TICKS = 20   // stable samples required before accepting a change
) (
    input  wire clk,
    input  wire rst,       // async reset
    input  wire tick_en,   // one-cycle sample-enable pulse (slow tick)
    input  wire noisy_in,  // raw, possibly bouncy input
    output reg  clean_out  // debounced, stable output
);

    localparam integer CW = (DEBOUNCE_TICKS <= 1) ? 1 : $clog2(DEBOUNCE_TICKS);
    reg [CW-1:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clean_out <= 1'b0;
            count     <= {CW{1'b0}};
        end else if (tick_en) begin
            if (noisy_in == clean_out) begin
                // already agrees with current output -> no bounce in progress
                count <= {CW{1'b0}};
            end else if (count >= DEBOUNCE_TICKS - 1) begin
                // input disagreed with output for DEBOUNCE_TICKS samples in a row -> accept it
                clean_out <= noisy_in;
                count     <= {CW{1'b0}};
            end else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule