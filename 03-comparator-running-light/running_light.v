module running_light(
    input sysclk,
    output [1:0] led
);

reg [26:0] counter;
reg [3:0] half_seconds;
reg [1:0] led_reg;

always @(posedge sysclk) begin

    if (half_seconds < 4'd16) begin

        if (counter == 27'd62499999) begin
            counter <= 0;
            half_seconds <= half_seconds + 1;

            if (led_reg == 2'b01)
                led_reg <= 2'b10;
            else
                led_reg <= 2'b01;

        end
        else begin
            counter <= counter + 1;
        end

    end
    else begin
        led_reg <= 2'b00;
    end

end

assign led = led_reg;

endmodule