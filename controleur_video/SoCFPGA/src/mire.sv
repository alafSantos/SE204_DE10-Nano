module mire #(
    parameter HDISP = 800,
    parameter VDISP = 480
) (
    wshb_if.master wshb_ifm
);

  logic [5:0] cycleCpt;

  // Insérer un cycle à vide (avec cyc et stb à 0) toutes les 64 requêtes d'écriture
  always_ff @(posedge wshb_ifm.clk) begin
    if (wshb_ifm.rst || cycleCpt == 63) begin
      cycleCpt <= 0;
      wshb_ifm.stb <= 0;
    end else begin
      wshb_ifm.stb <= 1;
      cycleCpt <= cycleCpt + wshb_ifm.ack;
    end
  end
  assign wshb_ifm.cyc = wshb_ifm.stb;

  logic pixelCpt_aux;

  // Compteurs
  logic [$clog2(HDISP) - 1:0] pixelCpt;
  logic [$clog2(VDISP) - 1:0] ligneCpt;

  // Gestionnaire de compteur horizontal
  always_ff @(posedge wshb_ifm.clk) begin
    if (wshb_ifm.rst || pixelCpt_aux) begin
      pixelCpt <= 0;
    end else begin
      pixelCpt <= pixelCpt + wshb_ifm.ack;
    end
  end

  // Gestionnaire de compteur vertical
  always_ff @(posedge wshb_ifm.clk) begin
    if (wshb_ifm.rst || ligneCpt == VDISP) begin
      ligneCpt <= 0;
    end else begin
      ligneCpt <= ligneCpt + pixelCpt_aux;
    end
  end

  // Distributeur de signal 
  assign wshb_ifm.dat_ms = ((pixelCpt % 16) && (ligneCpt % 16)) ? 32'h00000000 : 32'h00FFFFFF;

  // Compteur de pixels (largeur maximale)
  assign pixelCpt_aux = pixelCpt == HDISP - 1;

  // Adresse
  always_ff @(posedge wshb_ifm.clk) begin
    if (wshb_ifm.rst || (wshb_ifm.adr == (4 * (HDISP * VDISP - 1)))) begin
      wshb_ifm.adr <= 0;
    end else if (wshb_ifm.ack) begin
      wshb_ifm.adr = wshb_ifm.adr + 4;
    end
  end

  // D'autres signaux
  always_comb begin
    wshb_ifm.we  = 1;
    wshb_ifm.sel = 4'hF;
    wshb_ifm.cti = 0;
    wshb_ifm.bte = 0;
  end
endmodule
