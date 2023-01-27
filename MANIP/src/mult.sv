module mult    #( parameter d_width = 8)
                ( input logic [d_width-1:0] A,B,
                  output logic [2*d_width-1:0] S
                );



//XXXXX pragma attribute S dedicated_mult OFF
assign S = A * B;

endmodule


