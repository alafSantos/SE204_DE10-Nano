module comp    #( parameter d_width = 8)
                ( input logic clk, rst, ena, ld,
                  input logic [d_width-1:0] Din,
                  output logic [d_width-1:0] Q
                );


always_ff @ (posedge clk)
begin
    if (ena)
    begin
        Q <= Q+1;
		if (ld) Q <= Din;
        if (rst) Q <= 0;
    end
end
endmodule

