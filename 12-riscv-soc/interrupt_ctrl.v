`timescale 1ns / 1ps

module interrupt_ctrl(
    input  wire clk,
    input  wire rst,
    input  wire uart_irq,
    output wire cpu_irq
);

    reg uart_irq_prev;

    always @(posedge clk) begin

        if (rst) begin
            uart_irq_prev <= 1'b0;
        end
        else begin
            uart_irq_prev <= uart_irq;
        end

    end

    // Generate a one-clock pulse on the rising edge.
    assign cpu_irq = uart_irq && !uart_irq_prev;

endmodule