// Declaration du module, des paramètres génériques
// puis des entrées/sorties.
module sync_ram_dual_multi_r #( parameter num_out = 4,
                                parameter d_width = 8,
                                parameter a_width = 4)
                              ( input logic clk,
                                input logic we,
                                input logic [d_width-1:0] data_in,
                                input logic [a_width-1:0] address_w,
                                input logic [a_width-1:0] address_r[num_out -1:0],
                                output logic [d_width-1:0] data_out[num_out -1:0]
                                );

// Tableau représentant les données en RAM
logic [d_width-1:0] mem [0:2**a_width-1];
//XXXXXX pragma attribute mem ram_block FALSE

always_ff @(posedge clk)
begin
    // Si autorisation, écriture
    if (we) 
        mem[address_w] <= data_in;
    for (int i=0;i<num_out;i++)
        data_out[i] <= mem[address_r[i]];
end

endmodule
