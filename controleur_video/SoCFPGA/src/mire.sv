module mire #(
    parameter HDISP = 800,
    parameter VDISP = 480
) (
    wshb_if.master wshb_ifm
);

  logic [5:0] cycleCpt;

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

  // Counters
  logic [$clog2(HDISP) - 1:0] pixelCpt;
  logic [$clog2(VDISP) - 1:0] ligneCpt;

  // Counter Dealer - Horizontal
  always_ff @(posedge wshb_ifm.clk) begin
    if (wshb_ifm.rst || pixelCpt_aux) begin
      pixelCpt <= 0;
    end else begin
      pixelCpt <= pixelCpt + wshb_ifm.ack;
    end
  end

  // Counter Dealer - Vertical
  always_ff @(posedge wshb_ifm.clk) begin
    if (wshb_ifm.rst || ligneCpt == VDISP) begin
      ligneCpt <= 0;
    end else begin
      ligneCpt <= ligneCpt + pixelCpt_aux;
    end
  end

  // Signal Dealer 
  assign wshb_ifm.dat_ms = ((pixelCpt % 16) && (ligneCpt % 16)) ? 32'h00000000 : 32'h00FFFFFF;

  // Pixel Counter (max width)
  assign pixelCpt_aux = pixelCpt == HDISP - 1;

  // Address
  always_ff @(posedge wshb_ifm.clk) begin
    if (wshb_ifm.rst || (wshb_ifm.adr == (4 * (HDISP * VDISP - 1)))) begin
      wshb_ifm.adr <= 0;
    end else if (wshb_ifm.ack) begin
      wshb_ifm.adr = wshb_ifm.adr + 4;
    end
  end

  // Other Signals
  always_comb begin
    wshb_ifm.we  = 1;
    wshb_ifm.sel = 4'hF;
    wshb_ifm.cti = 0;
    wshb_ifm.bte = 0;
  end
endmodule
