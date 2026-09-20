`timescale 1ns/1ps

module tb_automatic_door_mealy;

    reg clk;
    reg rst;
    reg sensor;
    wire door_command;

    // Instantiate DUT
    automatic_door_mealy dut (
        .clk          (clk),
        .rst          (rst),
        .sensor       (sensor),
        .door_command (door_command)
    );

    // Clock generation: 10ns period (100MHz)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        $dumpfile("tb_automatic_door_mealy.vcd");
        $dumpvars(0, tb_automatic_door_mealy);

        // Reset
        sensor = 1'b0;
        rst    = 1'b1;
        repeat (2) @(posedge clk);
        rst = 1'b0;

        // 1) Idle closed: sensor stays 0, door should stay closed
        repeat (3) @(posedge clk);

        // 2) Someone approaches: sensor=1 -> door should open
        sensor = 1'b1;
        repeat (3) @(posedge clk);

        // 3) Person still there: sensor stays 1 -> door stays open
        repeat (2) @(posedge clk);

        // 4) Person leaves: sensor=0 -> Mealy output should react immediately
        //    door_command=0 (close command) combinationally,
        //    BEFORE the next clock edge moves state back to CLOSED
        sensor = 1'b0;
        #1; // small delta after sensor change, before next clock edge
        if (door_command !== 1'b0)  // CHANGED: was 1'b1
            $display("ERROR at t=%0t: expected door_command=0 (close cmd) while still in OPEN, got %b",
                       $time, door_command);
        else
            $display("OK   at t=%0t: Mealy close command asserted correctly (state still OPEN)", $time);

        @(posedge clk); // now state should have moved to CLOSED
        #1;
        if (door_command !== 1'b0)
            $display("ERROR at t=%0t: expected door_command=0 once back in CLOSED with sensor=0, got %b",
                       $time, door_command);
        else
            $display("OK   at t=%0t: door_command correctly low in CLOSED with sensor=0", $time);

        // 5) Idle closed again for a bit
        repeat (3) @(posedge clk);

        // 6) Quick re-trigger: open then immediately close
        sensor = 1'b1;
        @(posedge clk); // -> OPEN
        sensor = 1'b0;
        #1;
        if (door_command !== 1'b0)  // CHANGED: was 1'b1
            $display("ERROR at t=%0t: expected close command on quick re-trigger, got %b",
                       $time, door_command);
        else
            $display("OK   at t=%0t: close command correct on quick re-trigger", $time);

        repeat (3) @(posedge clk);

        // 7) Mid-run async reset test
        sensor = 1'b1;
        @(posedge clk); // -> OPEN
        rst = 1'b1;
        #1;
        if (door_command !== 1'b0)
            $display("ERROR at t=%0t: expected door_command=0 immediately on rst, got %b",
                       $time, door_command);
        repeat (2) @(posedge clk);
        rst = 1'b0;
        sensor = 1'b0;

        repeat (5) @(posedge clk);

        $display("Simulation finished at time %0t", $time);
        $finish;
    end

    // Monitor
    initial begin
        $monitor("t=%0t rst=%b sensor=%b state=%b door_command=%b",
                   $time, rst, sensor, dut.state, door_command);
    end

endmodule