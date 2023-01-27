module retime  #( parameter d_width = 16,
                  parameter pipe_depth  = 2)
                ( input logic [d_width-1:0] In1,In2,
                  input logic clk,
                  output logic [d_width-1:0] Q);

logic [d_width-1:0] In1_r, In2_r;
logic [d_width-1:0] P_r [pipe_depth-1:0];

assign Q = P_r[pipe_depth -1];

always_ff @(posedge clk )
    begin
        // Registres en entrée
		In1_r <= In1;
		In2_r <= In2;
        P_r[0] <= In1_r/In2_r;
        // Registre à décalage en sortie
        for (int i = 0; i< pipe_depth-1; i++)
            P_r[i+1] <= P_r[i];
    end

endmodule

