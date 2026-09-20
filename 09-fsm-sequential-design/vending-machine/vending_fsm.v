module vending_fsm #(
    parameter HOLD_CYCLES    = 125_000_000, // steady GREEN/BLUE/RED_ON duration (~1s @125MHz)
    parameter RED_OFF_CYCLES = 250_000_000, // red "dark" duration after RED_ON (~2s @125MHz)
    parameter BLINK_CYCLES   = 31_250_000,  // each blink on/off duration (~0.25s @125MHz)
    parameter BLINK_COUNT    = 3            // number of blinks after the dark period
)(
    input  wire clk,
    input  wire rst,
    input  wire p_btn0,   // one-shot: insert 100 won
    input  wire p_btn1,   // one-shot: change menu
    input  wire p_btn2,   // one-shot: proceed
    output reg  [3:0] ld,
    output reg  rgb_r,
    output reg  rgb_g,
    output reg  rgb_b
);

    localparam IDLE          = 4'd0,
               CHECK         = 4'd1,
               GREEN         = 4'd2,
               BLUE          = 4'd3,
               RED_ON        = 4'd4,
               RED_OFF       = 4'd5,
               RED_BLINK_ON  = 4'd6,
               RED_BLINK_OFF = 4'd7;

    reg [3:0]  state, nstate;
    reg [31:0] hold_cnt;
    reg [1:0]  blink_cnt;
    reg [1:0]  menu_sel;
    reg [9:0]  money;
    reg [8:0]  price;

    // ---- Menu selection (only while idle) ----
    always @(posedge clk or posedge rst) begin
        if (rst) menu_sel <= 2'd0;
        else if (p_btn1 && state == IDLE) menu_sel <= menu_sel + 1'b1; // 0->1->2->3->0
    end

    always @(*) begin
        case (menu_sel)
            2'd0: begin price = 9'd100; ld = 4'b0001; end
            2'd1: begin price = 9'd200; ld = 4'b0010; end
            2'd2: begin price = 9'd300; ld = 4'b0100; end
            2'd3: begin price = 9'd400; ld = 4'b1000; end
            default: begin price = 9'd100; ld = 4'b0001; end
        endcase
    end

    // ---- Money accumulator ----
    always @(posedge clk or posedge rst) begin
        if (rst) money <= 10'd0;
        else if (p_btn0 && state == IDLE) money <= money + 10'd100;
        else if ((state == GREEN || state == BLUE) && nstate == IDLE) money <= 10'd0;      // change consumed
        else if (state == CHECK && nstate == RED_ON) money <= 10'd0;                        // underpay -> return
    end

    // ---- State register ----
    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else     state <= nstate;
    end

    // ---- Blink counter ----
    always @(posedge clk or posedge rst) begin
        if (rst) blink_cnt <= 2'd0;
        else if (state == RED_OFF && nstate == RED_BLINK_ON) blink_cnt <= 2'd0;
        else if (state == RED_BLINK_OFF && hold_cnt == BLINK_CYCLES-1)
            blink_cnt <= blink_cnt + 1'b1;
    end

    // ---- Next-state logic ----
    always @(*) begin
        nstate = state;
        case (state)
            IDLE:  if (p_btn2) nstate = CHECK;

            CHECK: nstate = (money >= price) ? GREEN : RED_ON;

            GREEN: if (hold_cnt == HOLD_CYCLES-1)
                       nstate = (money > price) ? BLUE : IDLE;

            BLUE:  if (hold_cnt == HOLD_CYCLES-1) nstate = IDLE;

            RED_ON:  if (hold_cnt == HOLD_CYCLES-1) nstate = RED_OFF;

            RED_OFF: if (hold_cnt == RED_OFF_CYCLES-1) nstate = RED_BLINK_ON;

            RED_BLINK_ON:  if (hold_cnt == BLINK_CYCLES-1) nstate = RED_BLINK_OFF;

            RED_BLINK_OFF: if (hold_cnt == BLINK_CYCLES-1)
                                nstate = (blink_cnt == BLINK_COUNT-1) ? IDLE : RED_BLINK_ON;

            default: nstate = IDLE;
        endcase
    end

    // ---- Hold / timing counter (resets whenever state is about to change) ----
    always @(posedge clk or posedge rst) begin
        if (rst) hold_cnt <= 32'd0;
        else if (state != nstate) hold_cnt <= 32'd0;
        else if (state == GREEN || state == BLUE || state == RED_ON ||
                 state == RED_OFF || state == RED_BLINK_ON || state == RED_BLINK_OFF)
            hold_cnt <= hold_cnt + 1'b1;
        else
            hold_cnt <= 32'd0;
    end

    // ---- RGB output logic ----
    always @(*) begin
        rgb_r = (state == RED_ON) || (state == RED_BLINK_ON);
        rgb_g = (state == GREEN);
        rgb_b = (state == BLUE);
    end

endmodule