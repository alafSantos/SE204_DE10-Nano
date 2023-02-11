// Le module vga est un maître
module vga #(
    parameter HDISP = 800,
    parameter VDISP = 480
) (
    input pixel_clk,  // horloge entrante du module
    input pixel_rst,  // initialisation,  actif à l'état haut
    video_if.master video_ifm // Tous les signaux destinés à l'écran passeront par cette interface
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
    if (BLANK_aux) begin
      video_ifm.RGB <= ((pixelCpt - (H_width - HDISP)) % 16) && ((ligneCpt - (V_width - VDISP)) % 16) ? 24'h000000 : 24'hFFFFFF;
    end
  end

  // Clock Dealer
  assign video_ifm.CLK = pixel_clk;
  assign pixelCpt_aux = pixelCpt == H_width - 1;
  assign BLANK_aux = ((pixelCpt >= (H_width - HDISP)) && (ligneCpt >= (V_width - VDISP)));
endmodule

