// ============================================================
// clock_divider.v
// Produces single-cycle "tick" enable pulses at lower rates,
// derived from the main system clock. Everything downstream
// still runs on `clk` -- these are enable pulses, not derived
// clocks, which keeps the whole design in one clock domain
// (the FPGA-friendly way to do this).
// ============================================================
module clock_divider #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer TICK1_HZ    = 1000,  // fast tick, used for debounce sampling
    parameter integer TICK2_HZ    = 2      // slow tick, spare/for visual timing use
) (
    input  wire clk,
    input  wire rst,
    output reg  tick_1khz,   // pulses at TICK1_HZ
    output reg  tick_2hz     // pulses at TICK2_HZ
);

    localparam integer DIV1 = CLK_FREQ_HZ / TICK1_HZ;
    localparam integer DIV2 = CLK_FREQ_HZ / TICK2_HZ;

    localparam integer CW1 = (DIV1 <= 1) ? 1 : $clog2(DIV1);
    localparam integer CW2 = (DIV2 <= 1) ? 1 : $clog2(DIV2);

    reg [CW1-1:0] cnt1;
    reg [CW2-1:0] cnt2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt1      <= {CW1{1'b0}};
            tick_1khz <= 1'b0;
        end else if (cnt1 == DIV1 - 1) begin
            cnt1      <= {CW1{1'b0}};
            tick_1khz <= 1'b1;
        end else begin
            cnt1      <= cnt1 + 1'b1;
            tick_1khz <= 1'b0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt2     <= {CW2{1'b0}};
            tick_2hz <= 1'b0;
        end else if (cnt2 == DIV2 - 1) begin
            cnt2     <= {CW2{1'b0}};
            tick_2hz <= 1'b1;
        end else begin
            cnt2     <= cnt2 + 1'b1;
            tick_2hz <= 1'b0;
        end
    end

endmodule