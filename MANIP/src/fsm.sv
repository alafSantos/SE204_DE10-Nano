// Definition du module et de ses I/O
module fsm (input logic clk, rst,
            input logic start, stop,
            output logic good, bad);

// Type énuméré pour définir les états
typedef enum logic [2:0] {INIT, E1, E2, E3, END} STATE;
STATE c_state, n_state;

// Processus synchrone pour le changement d'état
always_ff @(posedge clk or posedge rst)
begin
    if(rst)
        c_state <= INIT;
    else
        c_state <= n_state;
end

// Processus combinatoire pour le calcul de l'état futur
always_comb 
begin
    n_state <= c_state;
    unique case (c_state)
    INIT: if (start) n_state <= E1;
    E1:n_state <= E2;
    E2:n_state <= E3;
    E3:n_state <= END;
    END: if (stop) n_state <= INIT;
    endcase
end

// Processus combinatoire pour le calcul des sorties
always_comb 
begin
    unique case (c_state)
    INIT:begin
       good <= 0;
       bad  <= 0;
    end
    E1:begin
       good <= 1;
       bad  <= 0;
    end
    E2:begin
       good <= 1;
       bad  <= 0;
    end
    E3:begin
       good <= 1;
       bad  <= 0;
    end
    END:begin
       good <= 0;
       bad  <= 1;
    end
    endcase
end

endmodule
