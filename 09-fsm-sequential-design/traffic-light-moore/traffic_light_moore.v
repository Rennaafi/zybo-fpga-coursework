module traffic_light_moore (
    input  wire clk,
    input  wire rst,
    output reg  red_led,
    output reg  green_led,
    output reg  yellow_led
);

    // State definition
    reg [1:0] state;
    localparam RED    = 2'b00;
    localparam GREEN  = 2'b01;
    localparam YELLOW = 2'b10;

    // Tick counter
    reg [4:0] count;

    // State transition
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= RED;
            count <= 5'd0;
        end
        else begin
            case (state)
                RED: begin
                    if (count == 5'd19) begin
                        state <= GREEN;
                        count <= 5'd0;
                    end
                    else begin
                        state <= RED;
                        count <= count + 1'b1;
                    end
                end
                GREEN: begin
                    if (count == 5'd14) begin
                        state <= YELLOW;
                        count <= 5'd0;
                    end
                    else begin
                        state <= GREEN;
                        count <= count + 1'b1;
                    end
                end
                YELLOW: begin
                    if (count == 5'd4) begin
                        state <= RED;
                        count <= 5'd0;
                    end
                    else begin
                        state <= YELLOW;
                        count <= count + 1'b1;
                    end
                end
                default: begin
                    state <= RED;
                    count <= 5'd0;
                end
            endcase
        end
    end

    // Moore output
    always @(*) begin
        red_led    = 1'b0;
        green_led  = 1'b0;
        yellow_led = 1'b0;

        case (state)
            RED:    red_led    = 1'b1;
            GREEN:  green_led  = 1'b1;
            YELLOW: yellow_led = 1'b1;
        endcase
    end

endmodule