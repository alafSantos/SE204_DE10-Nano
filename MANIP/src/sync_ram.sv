// Declaration du module, des paramètres génériques
// puis des entrées/sorties.
module sync_ram   #( parameter d_width = 8,
                     parameter a_width = 8)
                   ( input logic clk,
                     input logic we,
                     input logic [d_width-1:0] data_in,
                     input logic [a_width-1:0] address,
                     output logic [d_width-1:0] data_out
                     );

// Tableau représentant les données en RAM
logic [d_width-1:0] mem [0:2**a_width-1];
//ipragma attribute mem ram_block FALSE


always_ff @(posedge clk)
begin
    // Si autorisation, écriture
    if (we) 
        mem[address] <= data_in;
    // Lecture
        data_out <= mem[address];
end

endmodule

