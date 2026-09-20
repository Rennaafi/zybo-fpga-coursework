module challenge(
    input R_in,
    input G_in,
    input B_in,
    input Enable,
    output R_out,
    output G_out,
    output B_out
);

assign R_out = R_in & Enable;
assign G_out = G_in & Enable;
assign B_out = B_in & Enable;

endmodule