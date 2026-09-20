`timescale 1ns / 1ps

module tb;

    // =====================================================
    // INPUTS to top.v
    // =====================================================
    reg clk;
    reg reset;
    reg button_raw;
    reg button_debounced;

    // =====================================================
    // OUTPUTS from top.v
    // =====================================================
    wire led_raw;
    wire led_debounced;


    // =====================================================
    // Connect the testbench to top.v
    // =====================================================
    top uut (
        .clk              (clk),
        .reset            (reset),
        .button_raw       (button_raw),
        .button_debounced (button_debounced),
        .led_raw          (led_raw),
        .led_debounced    (led_debounced)
    );


    // =====================================================
    // Generate 125 MHz clock
    //
    // Zybo clock period = 8 ns
    //
    //       4ns     4ns
    //     ┌─────┐
    // ────┘     └────
    //
    // =====================================================
    always #4 clk = ~clk;


    // =====================================================
    // Print whenever an LED changes
    // =====================================================

    always @(led_raw) begin
        $display(
            "Time = %0t ns | RAW LED changed --> %b",
            $time,
            led_raw
        );
    end


    always @(led_debounced) begin
        $display(
            "Time = %0t ns | DEBOUNCED LED changed --> %b",
            $time,
            led_debounced
        );
    end


    // =====================================================
    // MAIN TEST
    // =====================================================
    initial begin

        // -------------------------
        // Initial values
        // -------------------------
        clk              = 0;
        reset            = 1;
        button_raw       = 0;
        button_debounced = 0;


        // =================================================
        // STEP 1: RESET
        // =================================================

        $display("");
        $display("==============================");
        $display(" RESET");
        $display("==============================");

        #40;

        reset = 0;

        $display("Reset released.");

        #100;


        // =================================================
        // STEP 2: SIMULATE BUTTON BOUNCE
        // =================================================
        //
        // Both buttons receive the SAME bouncing signal:
        //
        //        ┌──┐  ┌──┐  ┌────────────
        //        │  │  │  │  │
        // ───────┘  └──┘  └──┘
        //
        // =================================================

        $display("");
        $display("==============================");
        $display(" PRESSING BOTH BUTTONS");
        $display(" WITH BOUNCE");
        $display("==============================");


        // First contact
        button_raw       = 1;
        button_debounced = 1;

        #16;


        // Bounce back LOW
        button_raw       = 0;
        button_debounced = 0;

        #16;


        // Bounce HIGH again
        button_raw       = 1;
        button_debounced = 1;

        #16;


        // Bounce LOW again
        button_raw       = 0;
        button_debounced = 0;

        #16;


        // Finally stable HIGH
        button_raw       = 1;
        button_debounced = 1;


        $display("");
        $display("Button is now STABLE HIGH.");


        // Stay HIGH long enough for debouncer
        #200;


        // =================================================
        // STEP 3: RELEASE BUTTON
        // =================================================

        $display("");
        $display("==============================");
        $display(" RELEASING BUTTONS");
        $display("==============================");


        button_raw       = 0;
        button_debounced = 0;


        // Wait for debouncer
        #200;


        // =================================================
        // STEP 4: FINAL RESULT
        // =================================================

        $display("");
        $display("==============================");
        $display(" FINAL RESULT");
        $display("==============================");

        $display("RAW LED       = %b", led_raw);
        $display("DEBOUNCED LED = %b", led_debounced);

        $display("");
        $display("Simulation complete!");

        $finish;

    end

endmodule