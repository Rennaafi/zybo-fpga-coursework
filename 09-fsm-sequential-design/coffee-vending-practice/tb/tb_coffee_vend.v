`timescale 1ns/1ps

module tb_coffee_vend;
    reg clk, rstn, btn, w100;
    wire ret, sale;

    coffee_vend coffee_vend (
        .clk  (clk),
        .rstn (rstn),
        .btn  (btn),
        .w100 (w100),
        .ret  (ret),
        .sale (sale)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_coffee_vend.vcd");
        $dumpvars(0, tb_coffee_vend);

        rstn = 0; btn = 0; w100 = 0;
        #7  rstn = 1;

        #30 w100 = 1; // 100
        #10 w100 = 0;
        #30 w100 = 1; // 200
        #10 w100 = 0;
        #30 w100 = 1; // 300
        #10 w100 = 0;
        #30 btn  = 1; // sale
        #10 btn  = 0;

        #30 w100 = 1; // 100
        #10 w100 = 0;
        #30 w100 = 1; // 200
        #10 w100 = 0;
        #30 btn  = 1; // ret
        #10 btn  = 0;

        #100 $finish;
    end

    initial begin
        $monitor("t=%0t rstn=%b w100=%b btn=%b st=%b ret=%b sale=%b",
                   $time, rstn, w100, btn, coffee_vend.st, ret, sale);
    end
endmodule