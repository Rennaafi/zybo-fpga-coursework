module coffee_vend (
    input  clk, rstn, btn, w100,
    output ret, sale
);

    reg [1:0] st, nst;
    parameter ST0   = 2'b00,
              ST100 = 2'b01,
              ST200 = 2'b10,
              ST300 = 2'b11;

    // next state logic
    always @(st or btn or w100) begin
        case (st)
            ST0: begin
                if (w100) nst = ST100;
                else      nst = ST0;
            end
            ST100: begin
                if (w100)      nst = ST200;
                else if (btn)  nst = ST0;
                else           nst = ST100;
            end
            ST200: begin
                if (w100)      nst = ST300;
                else if (btn)  nst = ST0;
                else           nst = ST200;
            end
            ST300: begin
                if (w100)      nst = ST0;
                else if (btn)  nst = ST0;
                else           nst = ST300;
            end
            default: nst = ST0;
        endcase
    end

    // state register
    always @(posedge clk or negedge rstn) begin
        if (!rstn) st <= ST0;
        else       st <= nst;
    end

    // output logic (Mealy)
    assign ret  = (st == ST100) && btn && !w100
                || (st == ST200) && btn && !w100
                || (st == ST300) && w100;
    assign sale = (st == ST300) && btn && !w100;

endmodule