`timescale 1ns / 1ps

module us_tick_tb;

    // Testbench signals
    reg clk;
    reg rst;
    wire tick_us;

    // Instantiate DUT (Device Under Test)
    us_tick uut (
        .clk(clk),
        .rst(rst),
        .tick_us(tick_us)
    );

    // ------------------------------------------------
    // 125 MHz clock
    // Period = 8 ns
    // Half period = 4 ns
    // ------------------------------------------------
    initial begin
        clk = 1'b0;

        forever #4 clk = ~clk;
    end

    // ------------------------------------------------
    // Test sequence
    // ------------------------------------------------
    initial begin

        // Start with reset active
        rst = 1'b1;

        // Hold reset for a little while
        #20;

        // Release reset
        rst = 1'b0;

        // Run simulation
        #2000;

        // Finish
        $finish;
    end

    // ------------------------------------------------
    // Monitor signals
    // ------------------------------------------------
    initial begin
        $monitor(
            "Time = %0t ns | clk = %b | rst = %b | counter = %d | tick_us = %b",
            $time,
            clk,
            rst,
            uut.counter,
            tick_us
        );
    end

endmodule