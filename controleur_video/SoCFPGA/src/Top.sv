`default_nettype none

module Top (
    // Les signaux externes de la partie FPGA
    input  wire                FPGA_CLK1_50,
    input  wire          [1:0] KEY,
    output logic         [7:0] LED,
    input  wire          [3:0] SW,
    // Les signaux du support matériel son regroupés dans une interface
           hws_if.master       hws_ifm
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

  //=============================
  // On neutralise l'interface
  // du flux video pour l'instant
  // A SUPPRIMER PLUS TARD
  //=============================
  assign wshb_if_stream.ack = 1'b1;
  assign wshb_if_stream.dat_sm = '0;
  assign wshb_if_stream.err = 1'b0;
  assign wshb_if_stream.rty = 1'b0;

  //=============================
  // On neutralise l'interface SDRAM
  // pour l'instant
  // A SUPPRIMER PLUS TARD
  //=============================
  assign wshb_if_sdram.stb = 1'b0;
  assign wshb_if_sdram.cyc = 1'b0;
  assign wshb_if_sdram.we = 1'b0;
  assign wshb_if_sdram.adr = '0;
  assign wshb_if_sdram.dat_ms = '0;
  assign wshb_if_sdram.sel = '0;
  assign wshb_if_sdram.cti = '0;
  assign wshb_if_sdram.bte = '0;

  //--------------------------
  //------- Code Eleves ------
  //--------------------------
  logic [31:0] cpt, cpt2; // size 32 a cause d'un warning
  logic pixel_rst, D0, D1, Q0;

  // recopier la valeur  du signal KEY[0]  vers la led LED[0]
  assign LED[0] = KEY[0];

  // Les LEDs qui ne sont pas utilises ont ete mis au GND
  // parce qu'il y avait un warning avant
  assign LED[3] = 0;
  assign LED[4] = 0;
  assign LED[5] = 0;
  assign LED[6] = 0;
  assign LED[7] = 0;

  // pour tenir compte du contexte (simulation/synthèse)
`ifdef SIMULATION
  localparam hcmpt = 50;
`else
  localparam hcmpt = 50000000;
`endif

  // faire clignoter le signal LED[1] à  1Hz en utilisant l'horloge sys_clk.
  always_ff @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst) begin
      cpt <= 0;
      LED[1] <= 0;
    end else if (cpt != hcmpt) begin
      cpt <= cpt + 1;
    end else begin
      cpt <= 0;
      LED[1] <= !(LED[1]);
    end
  end

  // pour tenir compte du contexte (simulation/synthèse)
`ifdef SIMULATION
  localparam hcmpt2 = 16;
`else
  localparam hcmpt2 = 16000000;
`endif

  // Générez le signal pixel_rst en respectant le shéma proposé.
  assign D0 = 0;
  assign D1 = Q0;
  always_ff @(posedge pixel_clk or posedge sys_rst) begin
    Q0 <= sys_rst ? sys_rst : D0;
    pixel_rst <= sys_rst ? sys_rst : D1;
  end

  // faire clignoter le signal LED[2] à  1Hz en utilisant l'horloge pixel_clk
  always_ff @(posedge pixel_clk or posedge pixel_rst) begin
    if (pixel_rst) begin
      cpt2   <= 0;
      LED[2] <= 0;
    end else if (cpt2 != hcmpt2) begin
      cpt2 <= cpt2 + 1;
    end else begin
      cpt2   <= 0;
      LED[2] <= !(LED[2]);
    end
  end
endmodule
