module top(
    input [3:0] sw,
    input [3:0] btn,
    input sysclk,

    output led6_r,
    output led6_g,
    output led6_b,

    output [1:0] led
);

    // -------------------------
    // 4-bit Comparator
    // -------------------------
    comparator_4bit comp1 (
        .a    (sw[3:0]),
        .b    (btn[3:0]),
        .eq_r (led6_r),
        .gt_g (led6_g),
        .lt_b (led6_b)
    );


    // -------------------------
    // Running Light
    // -------------------------
    running_light run1 (
        .sysclk (sysclk),
        .led    (led)
    );

endmodule