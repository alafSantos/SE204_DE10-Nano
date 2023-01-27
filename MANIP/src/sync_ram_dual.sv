// Ici, l'adresse de lecture est différente de l'adresse
// d'écriture
// Déclaration du module, des paramètres génériques
// puis des entrées/sorties.
module sync_ram_dual   #( parameter d_width = 8,
                          parameter a_width = 8)
                        ( input logic clka, clkb,
                          input logic wea, web,
                          input logic [d_width-1:0] dataa_in, datab_in,
                          input logic [a_width-1:0] addra, addrb,
                          output logic [d_width-1:0] dataa_out, datab_out
                          );

// Tableau représentant les données en RAM
logic [d_width-1:0] mem [0:2**a_width-1];


// port A
always_ff @(posedge clka)
begin
    // Si autorisation, écriture
    if (wea) 
    begin
        mem[addra] <= dataa_in;
        dataa_out <= dataa_in;
    end
    else // Lecture
    dataa_out <= mem[addra];
end


// port B
always_ff @(posedge clkb)
begin
    // Si autorisation, écriture
    if (web) 
    begin
        mem[addrb] <= datab_in;
        datab_out <= datab_in;
    end
    else // Lecture
        datab_out <= mem[addrb];
end

endmodule
