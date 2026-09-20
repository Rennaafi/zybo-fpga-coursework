`timescale 1ns/1ps

module tb_traffic_light_moore;

    reg clk;
    reg rst;
    wire red_led;
    wire green_led;
    wire yellow_led;

    // Instantiate DUT
    traffic_light_moore dut (
        .clk        (clk),
        .rst        (rst),
        .red_led    (red_led),
        .green_led  (green_led),
        .yellow_led (yellow_led)
    );

    // Clock generation: 10ns period (100MHz)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        // Dump waveform for GTKWave / other viewers
        $dumpfile("tb_traffic_light_moore.vcd");
        $dumpvars(0, tb_traffic_light_moore);

        // Apply reset
        rst = 1'b1;
        repeat (2) @(posedge clk);
        rst = 1'b0;

        // Let it run through several full cycles
        // One full cycle = 20 (RED) + 15 (GREEN) + 5 (YELLOW) = 40 clk periods
        repeat (3 * 40) @(posedge clk);

        // Mid-run reset test
        rst = 1'b1;
        repeat (2) @(posedge clk);
        rst = 1'b0;

        repeat (40) @(posedge clk);

        $display("Simulation finished at time %0t", $time);
        $finish;
    end

    // Monitor state/output changes on every clock edge
    initial begin
        $monitor("t=%0t rst=%b state=%b red=%b green=%b yellow=%b count=%0d",
                  $time, rst, dut.state, red_led, green_led, yellow_led, dut.count);
    end

    // Self-check: only one LED should ever be high at a time
    always @(posedge clk) begin
        if (!rst) begin
            if ((red_led + green_led + yellow_led) > 1) begin
                $display("ERROR at t=%0t: more than one LED active!", $time);
            end
        end
    end

endmodule