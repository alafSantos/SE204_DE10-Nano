// Le module vga est un maître
module vga #(
    parameter HDISP = 800,
    parameter VDISP = 480
) (
    input pixel_clk,  // horloge entrante du module
    input pixel_rst,  // initialisation,  actif à l'état haut
    video_if.master video_ifm, // Tous les signaux destinés à l'écran passeront par cette interface
    wshb_if.master wshb_ifm // Cette interface permettra d'échanger des données de 32 bits avec une fréquence de bus de 100MHz
);

  // Time Parameters 
  localparam HFP = 40;  // Horizontal Front Porch
  localparam HPULSE = 48;  // Largeur de la synchro ligne
  localparam HBP = 40;  // Horizontal Back Porch
  localparam VFP = 13;  // Vertical Front Porch
  localparam VPULSE = 3;  // Largeur de la synchro image
  localparam VBP = 29;  // Vertical Back Porch

  localparam H_width = HDISP + HFP + HPULSE + HBP;
  localparam V_width = VDISP + VFP + VPULSE + VBP;

  logic BLANK_aux, pixelCpt_aux;
  logic read, rempty, write, wfull, walmost_full, fifoFull, cyc_syn, wfull_pxl;
  logic [31:0] rdata, wdata;

  // Compteurs
  logic [$clog2(H_width) - 1:0] pixelCpt;
  logic [$clog2(V_width) - 1:0] ligneCpt;

  // Gestionnaire de compteur horizontal
  always_ff @(posedge pixel_clk) begin
    if (pixel_rst) pixelCpt <= 0;
    else begin
      pixelCpt <= pixelCpt + 1;
      if (pixelCpt_aux) pixelCpt <= 0;
    end
  end

  // Gestionnaire de compteur vertical
  always_ff @(posedge pixel_clk) begin
    if (pixel_rst) ligneCpt <= 0;
    else begin
      ligneCpt <= ligneCpt + pixelCpt_aux;
      if (ligneCpt == V_width) ligneCpt <= 0;
    end
  end

  // Distributeur de signaux
  always_comb begin
    video_ifm.VS = !(ligneCpt >= VFP && ligneCpt < VFP + VPULSE);
    video_ifm.HS = !(pixelCpt >= HFP && pixelCpt < HFP + HPULSE);
    video_ifm.BLANK = ((pixelCpt >= (H_width - HDISP)) && (ligneCpt >= (V_width - VDISP)));
    video_ifm.CLK = pixel_clk;
    pixelCpt_aux = pixelCpt == H_width - 1;

    // Générez sur wshb_ifm des requètes d'écriture permanentes
    wshb_ifm.dat_ms = '0;  // Donnée 32 bits émises
    wshb_ifm.sel = 4'b1111;  // Les 4 octets sont à écrire
    wshb_ifm.we = 1'b0;  // Transaction en écriture
    wshb_ifm.cti = '0;  // Transfert classique
    wshb_ifm.bte = '0;  // sans utilité
    write = wshb_ifm.ack;
    wdata = wshb_ifm.dat_sm;
  end

  // Ecriture en FIFO 
  async_fifo #(
      .DATA_WIDTH(32),
      .DEPTH_WIDTH($clog2(256)),
      .ALMOST_FULL_THRESHOLD(192) // 224 avant
  ) myFIFO (
      .rst(wshb_ifm.rst),
      .rclk(pixel_clk),
      .read(read),
      .rdata(rdata),
      .rempty(rempty),
      .wclk(wshb_ifm.clk),
      .wdata(wdata),
      .write(write),
      .wfull(wfull),
      .walmost_full(walmost_full)
  );

  // Lecture en SDRAM
  always_ff @(posedge wshb_ifm.clk) begin
    if (wshb_ifm.rst) begin
      wshb_ifm.adr <= 0;
    end else if (wshb_ifm.ack) begin
      wshb_ifm.adr <= (wshb_ifm.adr == (4 * (VDISP * HDISP - 1))) ? 0 : wshb_ifm.adr + 4;
    end
  end

  // Lecture de la FIFO.
  always_ff @(posedge pixel_clk) begin
    logic DA, DB;
    DA <= wfull;
    if(wshb_ifm.clk) begin
      DB <= DA;
      wfull_pxl <= DB;
    end
  end

  always_ff @(posedge pixel_clk) begin
    if (pixel_rst) begin
      fifoFull <= 0;
    end else begin
      read <= (video_ifm.BLANK && !rempty && fifoFull);
      fifoFull <= (wfull_pxl && !(video_ifm.VS && video_ifm.HS)) ? 1 : fifoFull;
      if (video_ifm.BLANK) begin
        video_ifm.RGB <= rdata[23:0];
      end
    end
  end

  // Dispositif à hysteresis (cyc)
  always_ff @(posedge pixel_clk) begin
    if (pixel_rst) wshb_ifm.cyc <= 1;
    else if(wfull) wshb_ifm.cyc <= 0;
    else if (!walmost_full) wshb_ifm.cyc <= 1;
  end
  assign wshb_ifm.stb = wshb_ifm.cyc & !wfull;
endmodule

