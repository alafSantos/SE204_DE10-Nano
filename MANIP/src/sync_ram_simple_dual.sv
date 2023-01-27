// Ici, l'adresse de lecture est différente de l'adresse
// d'écriture
// Déclaration du module, des paramètres génériques
// puis des entrées/sorties.
module sync_ram_simple_dual   #( parameter d_width = 8,
                     parameter a_width = 4)
                   ( input logic clk,
                     input logic we,
                     input logic [d_width-1:0] data_in,
                     input logic [a_width-1:0] address_w,
                     input logic [a_width-1:0] address_r,
                     output logic [d_width-1:0] data_out
                     );

// Tableau représentant les données en RAM
logic [d_width-1:0] mem [0:2**a_width-1];


always_ff @(posedge clk)
begin
    // Si autorisation, écriture
    if (we) 
        mem[address_w] <= data_in;
    // Lecture
    data_out <= mem[address_r];
end

endmodule
