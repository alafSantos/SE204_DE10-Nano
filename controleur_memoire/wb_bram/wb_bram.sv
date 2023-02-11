//-----------------------------------------------------------------
// Wishbone BlockRAM
//-----------------------------------------------------------------
//
// Le paramètre mem_adr_width doit permettre de déterminer le nombre 
// de mots de la mémoire : (2048 pour mem_adr_width=11)

module wb_bram #(
    parameter mem_adr_width = 11
) (
    // Wishbone interface
    wshb_if.slave wb_s
);
  // a vous de jouer a partir d'ici
  logic ack_w, ack_r, ack_r2;
  logic [3:0][7:0] memory[0:2**mem_adr_width-1];
  wire [mem_adr_width-1:0] adr_i = wb_s.adr[mem_adr_width+1:2];

  // 0 in our slaves
  assign wb_s.err = 0;
  assign wb_s.rty = 0;

  // ACK
  assign ack_w = wb_s.we & wb_s.stb;
  assign ack_r2 = !wb_s.we & wb_s.stb;
  assign wb_s.ack = ack_w | ack_r;

  always_ff @(posedge wb_s.clk) begin
    // Reset
    if (wb_s.rst || (ack_r2)) begin
      ack_r <= !wb_s.rst;
    end

    // Reading
    if (ack_r2) begin
      // Classic bus cycle
      if (!(wb_s.cti[0]||wb_s.cti[1])) begin //cti = '000'
        if (!ack_r) begin
          for (int i = 0; i < 4; i++) begin
            if (wb_s.sel[i]) begin
              wb_s.dat_sm[(8*i+7)-:8] <= memory[adr_i][i];
            end
          end
        end
        ack_r <= !ack_r;
      end
    end

    // Writing
    if (ack_w) begin
      for (int i = 0; i < 4; i++) begin
        if (wb_s.sel[i]) begin
          memory[adr_i][i] <= wb_s.dat_ms[(8*i+7)-:8];
        end
      end
    end
  end
endmodule

