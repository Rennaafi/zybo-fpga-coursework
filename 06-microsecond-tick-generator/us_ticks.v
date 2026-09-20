`timescale 1ns / 1ps

module us_tick (
    input  wire clk,
    input  wire rst,
    output reg  tick_us
);

    // 125 MHz clock
    // 1 clock = 8 ns
    // 125 clocks = 1 us

    reg [6:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 7'd0;
            tick_us <= 1'b0;
        end
        else begin
            if (counter == 7'd124) begin
                counter <= 7'd0;
                tick_us <= 1'b1;
            end
            else begin
                counter <= counter + 1'b1;
                tick_us <= 1'b0;
            end
        end
    end

endmodule