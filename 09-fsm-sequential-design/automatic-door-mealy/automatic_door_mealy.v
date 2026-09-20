module automatic_door_mealy (
    input  wire clk,
    input  wire rst,
    input  wire sensor,
    output reg  door_command
);

    // State definition
    reg state;
    localparam CLOSED = 1'b0;
    localparam OPEN   = 1'b1;

    // State transition
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= CLOSED;
        end
        else begin
            case (state)
                CLOSED: begin
                    if (sensor == 1'b1)
                        state <= OPEN;
                    else
                        state <= CLOSED;
                end
                OPEN: begin
                    if (sensor == 1'b1)
                        state <= OPEN;
                    else
                        state <= CLOSED;
                end
                default: begin
                    state <= CLOSED;
                end
            endcase
        end
    end

    // Mealy output logic
    always @(*) begin
        case (state)
            CLOSED: begin
                if (sensor == 1'b1)
                    door_command = 1'b1; // start opening
                else
                    door_command = 1'b0; // stay closed
            end
            OPEN: begin
                if (sensor == 1'b1)
                    door_command = 1'b1; // stay open
                else
                    door_command = 1'b0; // command closed
            end
            default: door_command = 1'b0;
        endcase
    end

endmodule