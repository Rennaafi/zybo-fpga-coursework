// ============================================================
// Digital Door Lock FSM
// Matches the state diagram:
//   S0 IDLE -> S1 Digit1 -> S2 Digit2 -> S3 Digit3 -> S4 Digit4
//   S4 automatically checks the password:
//       correct -> S6 UNLOCK
//       wrong   -> S5 WRONG
//   BTN3 (reset) returns to S0 from S1..S6
// Digit entry: set sw[3:0] to the digit, press BTN0 to confirm.
// ============================================================
module digital_lock #(
    parameter [3:0] PW1 = 4'd1,   // password digit 1
    parameter [3:0] PW2 = 4'd9,   // password digit 2
    parameter [3:0] PW3 = 4'd5,   // password digit 3
    parameter [3:0] PW4 = 4'd4    // password digit 4
) (
    input  wire       clk,
    input  wire       rst,        // async global reset (power-on)
    input  wire [3:0] sw,         // switch value for the digit being entered
    input  wire       btn0,       // confirm current digit
    input  wire       btn3,       // cancel / reset to IDLE
    output reg        led0,       // digit1 confirmed
    output reg        led1,       // digit2 confirmed
    output reg        led2,       // digit3 confirmed
    output reg        led3,       // digit4 confirmed
    output reg        led_green,  // UNLOCK
    output reg        led_red     // WRONG password
);

    // ---------------- State encoding ----------------
    localparam S0_IDLE   = 3'd0;
    localparam S1_DIGIT1 = 3'd1;
    localparam S2_DIGIT2 = 3'd2;
    localparam S3_DIGIT3 = 3'd3;
    localparam S4_DIGIT4 = 3'd4;
    localparam S5_WRONG  = 3'd5;
    localparam S6_UNLOCK = 3'd6;

    reg [2:0] state, nst;

    // ---------------- Button edge detection (1 pulse per press) ----------------
    reg btn0_d, btn3_d;
    wire btn0_p = btn0 & ~btn0_d;   // rising-edge pulse
    wire btn3_p = btn3 & ~btn3_d;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn0_d <= 1'b0;
            btn3_d <= 1'b0;
        end else begin
            btn0_d <= btn0;
            btn3_d <= btn3;
        end
    end

    // ---------------- Entered-digit storage ----------------
    reg [3:0] d1, d2, d3, d4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            d1 <= 4'd0; d2 <= 4'd0; d3 <= 4'd0; d4 <= 4'd0;
        end else begin
            case (state)
                S0_IDLE:   if (btn0_p) d1 <= sw;
                S1_DIGIT1: if (btn0_p) d2 <= sw;
                S2_DIGIT2: if (btn0_p) d3 <= sw;
                S3_DIGIT3: if (btn0_p) d4 <= sw;
                default: ; // hold
            endcase
        end
    end

    // ---------------- State register ----------------
    always @(posedge clk or posedge rst) begin
        if (rst) state <= S0_IDLE;
        else     state <= nst;
    end

    // ---------------- Next-state logic ----------------
    always @(*) begin
        nst = state;
        case (state)
            S0_IDLE:   if (btn0_p) nst = S1_DIGIT1;

            S1_DIGIT1: if (btn3_p)      nst = S0_IDLE;
                       else if (btn0_p) nst = S2_DIGIT2;

            S2_DIGIT2: if (btn3_p)      nst = S0_IDLE;
                       else if (btn0_p) nst = S3_DIGIT3;

            S3_DIGIT3: if (btn3_p)      nst = S0_IDLE;
                       else if (btn0_p) nst = S4_DIGIT4;

            // Auto-checks the password the instant all 4 digits are in
            S4_DIGIT4: if (d1 == PW1 && d2 == PW2 && d3 == PW3 && d4 == PW4)
                           nst = S6_UNLOCK;
                       else
                           nst = S5_WRONG;

            S5_WRONG:  if (btn3_p) nst = S0_IDLE;

            S6_UNLOCK: if (btn3_p) nst = S0_IDLE;

            default:   nst = S0_IDLE;
        endcase
    end

    // ---------------- Moore output logic ----------------
    always @(*) begin
        led0      = (state != S0_IDLE);
        led1      = (state == S2_DIGIT2 || state == S3_DIGIT3 || state == S4_DIGIT4 ||
                     state == S5_WRONG  || state == S6_UNLOCK);
        led2      = (state == S3_DIGIT3 || state == S4_DIGIT4 ||
                     state == S5_WRONG  || state == S6_UNLOCK);
        led3      = (state == S4_DIGIT4 || state == S5_WRONG || state == S6_UNLOCK);
        led_green = (state == S6_UNLOCK);
        led_red   = (state == S5_WRONG);
    end

endmodule