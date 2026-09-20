module debouncer #(
    parameter integer DEBOUNCE_LIMIT = 20'd999_999
)(
    input  wire clk,
    input  wire reset,
    input  wire noisy_btn,
    output reg  clean_btn
);

    reg [19:0] count;
    reg        btn_state;

    always @(posedge clk) begin
        if (reset) begin
            count     <= 20'd0;
            btn_state <= 1'b0;
            clean_btn <= 1'b0;
        end

        else if (noisy_btn == btn_state) begin
            count <= 20'd0;
        end

        else begin
            if (count < DEBOUNCE_LIMIT) begin
                count <= count + 1'b1;
            end

            else begin
                btn_state <= noisy_btn;
                clean_btn <= noisy_btn;
                count     <= 20'd0;
            end
        end
    end

endmodule