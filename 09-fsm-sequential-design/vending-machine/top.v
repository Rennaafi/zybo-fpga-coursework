module top (
    input  wire clk,          // 125 MHz onboard oscillator (K17)
    input  wire rst,          // btn[3], used as system reset
    input  wire btn_coin,     // btn[0], insert 100 won
    input  wire btn_menu,     // btn[1], change menu
    input  wire btn_proceed,  // btn[2], proceed
    output wire [3:0] ld,     // led[3:0], menu indicator
    output wire rgb_r,        // led6_r
    output wire rgb_g,        // led6_g
    output wire rgb_b         // led6_b
);

    wire p_btn0, p_btn1, p_btn2;

    debounce_onepulse db_coin (
        .clk       (clk),
        .rst       (rst),
        .btn_in    (btn_coin),
        .pulse_out (p_btn0)
    );

    debounce_onepulse db_menu (
        .clk       (clk),
        .rst       (rst),
        .btn_in    (btn_menu),
        .pulse_out (p_btn1)
    );

    debounce_onepulse db_proceed (
        .clk       (clk),
        .rst       (rst),
        .btn_in    (btn_proceed),
        .pulse_out (p_btn2)
    );

    vending_fsm u_fsm (
        .clk    (clk),
        .rst    (rst),
        .p_btn0 (p_btn0),
        .p_btn1 (p_btn1),
        .p_btn2 (p_btn2),
        .ld     (ld),
        .rgb_r  (rgb_r),
        .rgb_g  (rgb_g),
        .rgb_b  (rgb_b)
    );

endmodule