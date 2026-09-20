`timescale 1ns / 1ps 

 module led_blinker( 
     input clk,      // 125MHz System Clock (K17 pin) 
     input rst,      // Reset Button 
     output reg led  // Output LED 
     ); 

     //125MHz oscillates 125,000,000 times per second.
         // To toggle every 0.5 seconds, count 62,500,000 cycles. 
     // 62,500,000 requires about 26 bits in binary (2^26 = 67,108,864) 

     reg [25:0] count; // 26-bit counter register 

     always @(posedge clk or posedge rst) begin 
         if (rst) begin 
             count <= 0; 
             led <= 0; 
         end 
         else begin 
         if (count == 26'd62_499_999) begin // subtract 1 because counting starts from 0 
                 count <= 26'd0;       // reset counter 
                 led <= ~led;      // toggle LED state (Toggle) 
             end 
             else begin 
                 count <= count + 1'b1; // increment counter  
             end 
         end 
     end 

 endmodule