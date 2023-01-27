// Declaration du module, des paramètres génériques
// puis des entrées/sorties.
module sync_rom   #( parameter d_width = 16,
                     parameter a_width = 8)
                   ( input logic clk,
                     input logic [a_width-1:0] address,
                     output logic [d_width-1:0] data_out
                     );

// Tableau représentant les données en ROM
logic [d_width-1:0] mem [0:2**a_width-1];


initial
begin
    $readmemh(`ROM_FILE, mem);
    // Le fichier romh.dat est un fichier ASCII
    // contenant la liste des valeur de la ROM 
    // exprimées en hexadecimal
    // Il existe aussi une fonction $readmemb
    // pour exprimer en binaire
end

// Lecture synchrone
always_ff @(posedge clk)
begin
        data_out <= mem[address];
end

endmodule

