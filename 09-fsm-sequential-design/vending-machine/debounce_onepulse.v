module debounce_onepulse #(
    parameter DEBOUNCE_LIMIT = 200_000  // ~1.6ms @125MHz; override smaller for sim
)(
    input  wire clk,
    input  wire rst,
    input  wire btn_in,
    output reg  pulse_out   // one clk-wide pulse per clean press
);
    reg [1:0] sync_reg;
    reg       btn_clean, btn_clean_d;
    reg [$clog2(DEBOUNCE_LIMIT)-1:0] cnt;

    // 2-FF synchronizer
    always @(posedge clk or posedge rst) begin
        if (rst) sync_reg <= 2'b00;
        else     sync_reg <= {sync_reg[0], btn_in};
    end

    // debounce counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt       <= 0;
            btn_clean <= 1'b0;
        end else if (sync_reg[1] != btn_clean) begin
            if (cnt == DEBOUNCE_LIMIT-1) begin
                btn_clean <= sync_reg[1];
                cnt       <= 0;
            end else
                cnt <= cnt + 1'b1;
        end else begin
            cnt <= 0;
        end
    end

    // rising-edge one-shot pulse
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_clean_d <= 1'b0;
            pulse_out   <= 1'b0;
        end else begin
            btn_clean_d <= btn_clean;
            pulse_out   <= btn_clean & ~btn_clean_d;
        end
    end
endmodule