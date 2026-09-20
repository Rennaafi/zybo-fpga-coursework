// ============================================================
// tb_practice1.v
// Practice 1: Simulate the CLOCK DIVIDER and TICK GENERATOR
// side by side, so their behavior can be visually compared
// in the Vivado waveform viewer.
//
// NOTE: MAX_COUNT / HALF_PERIOD are shrunk WAY down from the
// real 124_999_999 / 62_499_999 so the simulation finishes in
// microseconds instead of 1 real second. The logic is
// identical to the real design, only the compare value differs.
// ============================================================
`timescale 1ns/1ps

module tb_practice1;

    // ---- simulation-scale parameters ----
    // Real design: MAX_COUNT = 124_999_999 (tick),
    //              HALF_PERIOD = 62_499_999 (clock divider)
    // For simulation we use small numbers so waveforms are
    // readable in a few hundred ns.
    localparam SIM_MAX_COUNT   = 9;  // tick_generator: 0..9  -> pulses every 10 clk cycles
    localparam SIM_HALF_PERIOD = 4;  // clock_divider: 0..4   -> toggles every 5 clk cycles
                                      // (so clk_div period = 10 clk cycles, matching tick period)

    reg clk;
    reg rst;

    wire clk_div;   // output of clock_divider
    wire tick;      // output of tick_generator

    // ---- DUT instances ----
    clock_divider #(
        .HALF_PERIOD(SIM_HALF_PERIOD)
    ) u_clock_divider (
        .clk     (clk),
        .rst     (rst),
        .clk_div (clk_div)
    );

    tick_generator #(
        .MAX_COUNT(SIM_MAX_COUNT)
    ) u_tick_generator (
        .clk  (clk),
        .rst  (rst),
        .tick (tick)
    );

    // ---- 125 MHz system clock: period = 8ns ----
    initial clk = 0;
    always #4 clk = ~clk;   // 8ns period -> 125 MHz

    // ---- stimulus ----
    initial begin
        $timeformat(-9, 0, " ns", 8);  // display $time in ns
        rst = 1;
        #20;            // hold reset for a couple clock edges
        rst = 0;

        // Let it run long enough to see several tick pulses
        // and several clk_div toggles (period is 10 clk cycles
        // = 80ns each here, so 500ns gives ~6 periods)
        #500;

        $display("Simulation finished at time %0t", $time);
        $finish;
    end

    // ---- waveform dump for Vivado ----
    initial begin
        $dumpfile("tb_practice1.vcd");
        $dumpvars(0, tb_practice1);
    end

    // ---- text log so you can also read the transcript ----
    initial begin
        $display("  time(ns) | rst | clk_div | tick");
        $monitor("%9t |  %b  |    %b    |  %b", $time, rst, clk_div, tick);
    end

endmodule