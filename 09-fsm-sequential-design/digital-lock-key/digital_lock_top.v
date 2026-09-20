// ============================================================
// digital_lock_top.v
// Top-level wrapper: clock_divider + debounce(btn0) + debounce(btn3)
// + digital_lock core. Port names here are generic; a board-specific
// pin-constraints file maps these to physical FPGA pins.
// ============================================================
module digital_lock_top #(
    parameter integer CLK_FREQ_HZ    = 50_000_000,
    parameter integer TICK1_HZ       = 1000,
    parameter integer TICK2_HZ       = 2,
    parameter integer DEBOUNCE_TICKS = 20,
    parameter [3:0]   PW1 = 4'd1,
    parameter [3:0]   PW2 = 4'd9,
    parameter [3:0]   PW3 = 4'd5,
    parameter [3:0]   PW4 = 4'd4
) (
    input  wire       clk,
    input  wire       rst,        // async global reset (power-on / reset button)
    input  wire [3:0] sw,         // password-digit switches
    input  wire       btn0_raw,   // raw "confirm digit" button
    input  wire       btn3_raw,   // raw "reset/cancel" button
    output wire        led0,
    output wire        led1,
    output wire        led2,
    output wire        led3,
    output wire        led_green,
    output wire        led_red
);

    wire tick_1khz, tick_2hz;
    wire btn0_clean, btn3_clean;

    clock_divider #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .TICK1_HZ    (TICK1_HZ),
        .TICK2_HZ    (TICK2_HZ)
    ) u_clkdiv (
        .clk       (clk),
        .rst       (rst),
        .tick_1khz (tick_1khz),
        .tick_2hz  (tick_2hz)
    );

    debounce #(
        .DEBOUNCE_TICKS (DEBOUNCE_TICKS)
    ) u_deb_btn0 (
        .clk       (clk),
        .rst       (rst),
        .tick_en   (tick_1khz),
        .noisy_in  (btn0_raw),
        .clean_out (btn0_clean)
    );

    debounce #(
        .DEBOUNCE_TICKS (DEBOUNCE_TICKS)
    ) u_deb_btn3 (
        .clk       (clk),
        .rst       (rst),
        .tick_en   (tick_1khz),
        .noisy_in  (btn3_raw),
        .clean_out (btn3_clean)
    );

    digital_lock #(
        .PW1 (PW1),
        .PW2 (PW2),
        .PW3 (PW3),
        .PW4 (PW4)
    ) u_lock (
        .clk       (clk),
        .rst       (rst),
        .sw        (sw),
        .btn0      (btn0_clean),
        .btn3      (btn3_clean),
        .led0      (led0),
        .led1      (led1),
        .led2      (led2),
        .led3      (led3),
        .led_green (led_green),
        .led_red   (led_red)
    );

endmodule