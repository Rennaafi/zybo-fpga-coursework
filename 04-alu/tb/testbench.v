`timescale 1ns / 1ps

module tb_project2();

    reg  [7:0] sw;
    reg  [3:0] btn;
    wire [3:0] led;
    wire       led5_r, led5_g, led5_b;

    // Instantiate the top module
    project2 uut (
        .sw(sw),
        .btn(btn),
        .led(led),
        .led5_r(led5_r),
        .led5_g(led5_g),
        .led5_b(led5_b)
    );

    // Test sequence
    initial begin
        $display("Testing 4-bit ALU Calculator");
        $display("========================================");
        
        // Test Addition: 5 + 3 = 8
        sw = 8'h35;  // A=5, B=3
        btn = 4'b0001;  // Addition
        #10;
        $display("Addition: A=%d, B=%d, Result=%d, Carry=%b", 
                 sw[3:0], sw[7:4], led, led5_b);
        
        // Test Subtraction: 9 - 4 = 5
        sw = 8'h49;  // A=9, B=4
        btn = 4'b0010;  // Subtraction
        #10;
        $display("Subtraction: A=%d, B=%d, Result=%d, Overflow=%b", 
                 sw[3:0], sw[7:4], led, led5_r);
        
        // Test AND: 0xF & 0xA = 0xA
        sw = 8'hAF;  // A=15, B=10
        btn = 4'b0100;  // AND
        #10;
        $display("AND: A=%h, B=%h, Result=%h", sw[3:0], sw[7:4], led);
        
        // Test XOR: 0x5 ^ 0x3 = 0x6
        sw = 8'h35;  // A=5, B=3
        btn = 4'b1000;  // XOR
        #10;
        $display("XOR: A=%d, B=%d, Result=%d", sw[3:0], sw[7:4], led);
        
        $display("========================================");
        $display("Test completed");
        $finish;
    end

endmodule