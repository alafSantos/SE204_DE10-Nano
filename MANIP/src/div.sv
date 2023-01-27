module div     #( parameter d_width = 8)
                ( input logic [d_width-1:0] A,B,
                  output logic [d_width-1:0] S
                );



assign S = A / B;

endmodule
