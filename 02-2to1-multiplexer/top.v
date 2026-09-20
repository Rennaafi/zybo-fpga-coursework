`timescale 1ns / 1ps

module top(
    input  [3:0] sw,
    output [3:0] led
);

    // Call the multiplexer
    multiplexer mux1 (
        .d0  (sw[0]),
        .d1  (sw[1]),
        .sel (sw[2]),
        .y   (led[0])
    );

    // Call the basic logic gates
   // basic_gates gates1 (
   //     .sw  (sw[1:0]),
   //     .led (gates_out)
   // );


endmodule