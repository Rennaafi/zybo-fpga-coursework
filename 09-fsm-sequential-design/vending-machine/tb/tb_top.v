`timescale 1ns/1ps

module tb_top;

    reg clk, rst, btn_coin, btn_menu, btn_proceed;
    wire [3:0] ld;
    wire rgb_r, rgb_g, rgb_b;

    top dut (
        .clk         (clk),
        .rst         (rst),
        .btn_coin    (btn_coin),
        .btn_menu    (btn_menu),
        .btn_proceed (btn_proceed),
        .ld          (ld),
        .rgb_r       (rgb_r),
        .rgb_g       (rgb_g),
        .rgb_b       (rgb_b)
    );

    // shrink timing for simulation
    defparam dut.db_coin.DEBOUNCE_LIMIT    = 4;
    defparam dut.db_menu.DEBOUNCE_LIMIT    = 4;
    defparam dut.db_proceed.DEBOUNCE_LIMIT = 4;
    defparam dut.u_fsm.HOLD_CYCLES         = 20;
    defparam dut.u_fsm.RED_OFF_CYCLES      = 40;
    defparam dut.u_fsm.BLINK_CYCLES        = 10;
    defparam dut.u_fsm.BLINK_COUNT         = 3;

    // clock: 8ns period to mimic 125MHz ratio (not critical for functional sim)
    initial clk = 0;
    always #4 clk = ~clk;

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        btn_coin = 0; btn_menu = 0; btn_proceed = 0;
        rst = 1;
        repeat (2) @(posedge clk);
        rst = 0;

        // ---- Case 1: select menu2 (300 won), pay exactly, proceed ----
        btn_menu = 1; #8 btn_menu = 0; #16; // -> menu1 (200)
        btn_menu = 1; #8 btn_menu = 0; #16; // -> menu2 (300)

        btn_coin = 1; #8 btn_coin = 0; #16; // +100
        btn_coin = 1; #8 btn_coin = 0; #16; // +200
        btn_coin = 1; #8 btn_coin = 0; #16; // +300

        btn_proceed = 1; #8 btn_proceed = 0; // proceed -> expect GREEN only

        #400; // GREEN hold, back to idle

        // ---- Case 2: same menu (300), overpay with 400 ----
        btn_coin = 1; #8 btn_coin = 0; #16;
        btn_coin = 1; #8 btn_coin = 0; #16;
        btn_coin = 1; #8 btn_coin = 0; #16;
        btn_coin = 1; #8 btn_coin = 0; #16; // total 400 > price 300

        btn_proceed = 1; #8 btn_proceed = 0; // proceed -> expect GREEN then BLUE

        #500;

        // ---- Case 3: underpay -> RED_ON -> dark 2s -> blink x3 -> IDLE, money returned ----
        btn_coin = 1; #8 btn_coin = 0; #16; // +100 only (menu2 needs 300)

        btn_proceed = 1; #8 btn_proceed = 0; // proceed -> expect RED sequence

        #700; // long enough to cover RED_ON + RED_OFF + 3 blinks

        // top up correctly and retry
        btn_coin = 1; #8 btn_coin = 0; #16; // +100 (now 200)
        btn_coin = 1; #8 btn_coin = 0; #16; // +100 (now 300, matches price)

        btn_proceed = 1; #8 btn_proceed = 0; // proceed -> expect GREEN

        #400;

        $display("Simulation finished at %0t", $time);
        $finish;
    end

    // Readable state monitor
    function [15*8-1:0] state_name;
        input [3:0] s;
        case (s)
            4'd0: state_name = "IDLE";
            4'd1: state_name = "CHECK";
            4'd2: state_name = "GREEN";
            4'd3: state_name = "BLUE";
            4'd4: state_name = "RED_ON";
            4'd5: state_name = "RED_OFF";
            4'd6: state_name = "RED_BLINK_ON";
            4'd7: state_name = "RED_BLINK_OFF";
            default: state_name = "UNKNOWN";
        endcase
    endfunction

    initial begin
        $monitor("t=%0t state=%s menu=%0d money=%0d price=%0d ld=%b R=%b G=%b B=%b",
                   $time, state_name(dut.u_fsm.state), dut.u_fsm.menu_sel,
                   dut.u_fsm.money, dut.u_fsm.price, ld, rgb_r, rgb_g, rgb_b);
    end

endmodule