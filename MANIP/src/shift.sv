module shift   #( parameter d_width = 4,
                  parameter shift_depth  = 4)
                ( input logic [d_width-1:0] Din,
                  input logic clk,
                  output logic [d_width-1:0] Dout);

logic [d_width-1:0] P_r [shift_depth-1:0];

assign Dout = P_r[shift_depth -1];

always_ff @(posedge clk )
    begin
        P_r[0] <= Din;
        for (int i = 0; i< shift_depth-1; i++)
            P_r[i+1] <= P_r[i];
    end

endmodule

