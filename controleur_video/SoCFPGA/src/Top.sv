`default_nettype none

module Top #(
    parameter HDISP = 800,
    parameter VDISP = 480
) (
    // Les signaux externes de la partie FPGA
    input  wire                  FPGA_CLK1_50,
    input  wire            [1:0] KEY,
    output logic           [7:0] LED,
    input  wire            [3:0] SW,
    // Les signaux du support matériel son regroupés dans une interface
           hws_if.master         hws_ifm,
           video_if.master       video_ifm
);

  //====================================
  //  Déclarations des signaux internes
  //====================================
  wire sys_rst;  // Le signal de reset du système
  wire sys_clk;  // L'horloge système a 100Mhz
  wire pixel_clk;  // L'horloge de la video 32 Mhz

  //=======================================================
  //  La PLL pour la génération des horloges
  //=======================================================

  sys_pll sys_pll_inst (
      .refclk  (FPGA_CLK1_50),  // refclk.clk
      .rst     (1'b0),          // pas de reset
      .outclk_0(pixel_clk),     // horloge pixels a 32 Mhz
      .outclk_1(sys_clk)        // horloge systeme a 100MHz
  );

  //=============================
  //  Les bus Wishbone internes
  //=============================
  wshb_if #(
      .DATA_BYTES(4)
  ) wshb_if_sdram (
      sys_clk,
      sys_rst
  );
  wshb_if #(
      .DATA_BYTES(4)
  ) wshb_if_stream (
      sys_clk,
      sys_rst
  );

  //=============================
  //  Le support matériel
  //=============================
  hw_support hw_support_inst (
      .wshb_ifs(wshb_if_sdram),
      .wshb_ifm(wshb_if_stream),
      .hws_ifm (hws_ifm),
      .sys_rst (sys_rst),         // output
      .SW_0    (SW[0]),
      .KEY     (KEY)
  );

  //--------------------------
  //------- Code Eleves ------
  //--------------------------
  logic [31:0] cpt, cpt2;  // size 32 a cause d'un warning
  logic pixel_rst;

  // Recopier la valeur  du signal KEY[0]  vers la led LED[0]
  assign LED[0] = KEY[0];

  // Les LEDs qui ne sont pas utilises ont ete mis au GND
  assign LED[3+:5] = '0;

  // Pour tenir compte du contexte (simulation/synthèse)
`ifdef SIMULATION
  localparam hcmpt = 50;
  localparam hcmpt2 = 16;
`else
  localparam hcmpt = 50000000;
  localparam hcmpt2 = 16000000;
`endif

  // Faire clignoter le signal LED[1] à  1Hz en utilisant l'horloge sys_clk.
  always_ff @(posedge sys_clk) begin
    if (sys_rst) begin
      cpt <= 0;
      LED[1] <= 0;
    end else begin
      cpt <= cpt + 1;
      if (cpt == hcmpt) begin
        cpt <= 0;
        LED[1] <= !(LED[1]);
      end
    end
  end

  // Générez le signal pixel_rst en respectant le shéma proposé.
  always_ff @(posedge pixel_clk) begin
    logic Q0; // Variable locale
    if (sys_rst) begin
      Q0 <= 1;
      pixel_rst <= 1;
    end else begin
      Q0 <= 0;
      pixel_rst <= Q0;
    end
  end

  // Faire clignoter le signal LED[2] à  1Hz en utilisant l'horloge pixel_clk
  always_ff @(posedge pixel_clk) begin
    if (pixel_rst) begin
      cpt2   <= 0;
      LED[2] <= 0;
    end else begin
      cpt2 <= cpt2 + 1;
      if (cpt2 == hcmpt2) begin
        cpt2   <= 0;
        LED[2] <= !(LED[2]);
      end
    end
  end

  // Dédiée aux transferts de données du module vga qui ne pourra plus accéder directement au contrôleur de SDRAM.
  wshb_if #(
      .DATA_BYTES(4)
  ) wshb_if_vga (
      sys_clk,
      sys_rst
  );

  /* Instances des sous-modules */
  vga #(
      .HDISP(HDISP),
      .VDISP(VDISP)
  ) myVGA (
      .pixel_clk(pixel_clk),
      .pixel_rst(pixel_rst),
      .video_ifm(video_ifm),
      .wshb_ifm (wshb_if_vga.master)
  );

  wshb_intercon myIntercon (
      .wshb_ifs_mire(wshb_if_stream),
      .wshb_ifs_vga(wshb_if_vga.slave),
      .wshb_ifm(wshb_if_sdram.master)
  );

endmodule
