`timescale 1ns/1ps

module counter_4bittb;

    reg clk, rst;
    wire [3:0] count;

    // Connect the counter (DUT) -> ini yang ngejadiin design source jadi simulated on tb
    counter_4bit DUT (
        .clk(clk),
        .rst(rst),
        .count(count)
    );
  
    // 1. Clock generation
    initial clk = 0;
    initial rst = 1;
    
    always #5 clk = ~clk;


    // 2. Test scenario
   always #175 rst = ~rst;
   
   initial begin
   
        // Let counter count
        #1000;

    $display("Time=%0t | rst=%b | clk=%b | count=%d",
             $time, rst, clk, count);
        // End simulation
        $finish;

  
   
                
    end

endmodule