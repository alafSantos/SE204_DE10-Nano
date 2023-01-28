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

  // Counters
  logic [$clog2(H_width) - 1:0] pixelCpt;
  logic [$clog2(V_width) - 1:0] ligneCpt;

  // Counter Dealer - Horizontal
  always_ff @(posedge pixel_clk) begin
    if (pixel_rst || pixelCpt_aux) begin
      pixelCpt <= 0;
    end else begin
      pixelCpt <= pixelCpt + 1;
    end
  end

  // Counter Dealer - Vertical
  always_ff @(posedge pixel_clk) begin
    if (pixel_rst || ligneCpt == V_width) begin
      ligneCpt <= 0;
    end else begin
      ligneCpt <= ligneCpt + pixelCpt_aux;
    end
  end

  // Signals Dealer 
  always_ff @(posedge pixel_clk) begin
    video_ifm.HS <= !(pixelCpt >= HFP && pixelCpt < HFP + HPULSE);
    video_ifm.VS <= !(ligneCpt >= VFP && ligneCpt < VFP + VPULSE);
    video_ifm.BLANK <= BLANK_aux;
  end

  assign video_ifm.CLK = pixel_clk;  // Clock Dealer
  assign pixelCpt_aux = pixelCpt == H_width - 1;
  assign BLANK_aux = ((pixelCpt >= (H_width - HDISP)) && (ligneCpt >= (V_width - VDISP)));

  // Générez sur wshb_ifm des requètes d'écriture permanentes
  logic read, rempty, write, wfull, walmost_full, fifoFull, cyc_syn;
  assign wshb_ifm.cyc = cyc_syn && !wfull;
  assign wshb_ifm.stb = wshb_ifm.cyc;  // Le bus est sélectionné
  assign wshb_ifm.dat_ms = '0;  // Donnée 32 bits émises
  assign wshb_ifm.sel = 4'b1111;  // Les 4 octets sont à écrire
  assign wshb_ifm.we = 1'b0;  // Transaction en écriture
  assign wshb_ifm.cti = '0;  // Transfert classique
  assign wshb_ifm.bte = '0;  // sans utilité

  // Ecriture en FIFO 
  logic [31:0] rdata, wdata;

  async_fifo #(
      .DATA_WIDTH(32),
      .DEPTH_WIDTH($clog2(256)),
      .ALMOST_FULL_THRESHOLD(224)
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
  assign write = wshb_ifm.ack;
  assign wdata = wshb_ifm.dat_sm;

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
    if (pixel_rst) begin
      fifoFull <= 0;
    end else begin
      read <= (video_ifm.BLANK && !rempty && fifoFull);
      fifoFull <= (wfull && !(video_ifm.VS && video_ifm.HS)) ? 1 : fifoFull;
      if (BLANK_aux) begin
        video_ifm.RGB <= rdata[23:0];
      end
    end
  end

  // Upgrade cyc (stb)
  always_ff @(posedge wshb_ifm.clk) begin
    if(wshb_ifm.rst) begin
      cyc_syn <= 0;
    end
    else if (!walmost_full) begin
      cyc_syn <= 1;
    end
  end
endmodule

