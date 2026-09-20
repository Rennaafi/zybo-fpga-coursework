// cetak dan ganti baris

`timescale 1ns / 1ps
module top (
    input wire clk,
    output wire uart_tx
);

    localparam integer CLK_FREQ = 125_000_000;
    reg [26:0] timer;
    reg [3:0] message_index;
    reg sending;
    reg send;
    reg [7:0] data_to_send;
    wire tx_busy;

    uart_tx #(
       .CLK_FREQ (125_000_000),
       .BAUD_RATE (115200)
    ) uart_tx_inst (
       .clk (clk),
       .rst (1'b0),
       .data_in (data_to_send),
       .send (send),
       .tx (uart_tx),
       .busy (tx_busy)
    );

    function [7:0] get_char;
        input [3:0] index;
        begin
            case (index)
                4'd0: get_char = "H";
                4'd1: get_char = "e";
                4'd2: get_char = "l";
                4'd3: get_char = "l";
                4'd4: get_char = "o";
                4'd5: get_char = " ";
                4'd6: get_char = "F";
                4'd7: get_char = "P";
                4'd8: get_char = "G";
                4'd9: get_char = "A";
                4'd10: get_char = 8'h0D; // CR
                4'd11: get_char = 8'h0A; // LF
                default: get_char = " ";
            endcase
        end
    endfunction

    always @(posedge clk) begin
        send <= 1'b0; // default 0, cuma 1 clock
        if (!sending) begin
            if (timer < CLK_FREQ - 1) timer <= timer + 1;
            else begin
                timer <= 0; sending <= 1; message_index <= 0;
            end
        end
        else begin
            if (!tx_busy &&!send) begin // tunggu tx idle baru kirim
                data_to_send <= get_char(message_index);
                send <= 1'b1;
                if (message_index == 11) sending <= 0;
                else message_index <= message_index + 1;
            end
        end
    end
    initial begin timer=0; message_index=0; sending=0; send=0; data_to_send=0; end
endmodule