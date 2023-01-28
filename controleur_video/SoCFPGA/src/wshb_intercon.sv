module wshb_intercon (
    wshb_if.slave  wshb_ifs_mire,
    wshb_if.slave  wshb_ifs_vga,
    wshb_if.master wshb_ifm
);
  logic token;  // 0 -> VGA, 1 -> Mire

  always_ff @(posedge wshb_ifm.clk) begin
    if (wshb_ifm.rst) begin
      token <= 1;
    end else begin
      token <= ((token && !wshb_ifs_mire.cyc) || (!token && !wshb_ifs_vga.cyc)) ? !token : token;
    end
  end

  always_comb begin
    if (token) begin
      wshb_ifm.cyc = wshb_ifs_mire.cyc;
      wshb_ifm.stb = wshb_ifs_mire.stb;
      wshb_ifm.adr = wshb_ifs_mire.adr;
      wshb_ifm.we = wshb_ifs_mire.we;
      wshb_ifm.dat_ms = wshb_ifs_mire.dat_ms;
      wshb_ifm.sel = wshb_ifs_mire.sel;
      wshb_ifm.cti = wshb_ifs_mire.cti;
      wshb_ifm.bte = wshb_ifs_mire.bte;

      wshb_ifs_mire.ack = wshb_ifm.ack;
      wshb_ifs_vga.ack = 0;
      wshb_ifs_mire.dat_sm = wshb_ifm.dat_sm;
      wshb_ifs_vga.dat_sm = 0;
    end else begin
      wshb_ifm.cyc = wshb_ifs_vga.cyc;
      wshb_ifm.stb = wshb_ifs_vga.stb;
      wshb_ifm.adr = wshb_ifs_vga.adr;
      wshb_ifm.we = wshb_ifs_vga.we;
      wshb_ifm.dat_ms = wshb_ifs_vga.dat_ms;
      wshb_ifm.sel = wshb_ifs_vga.sel;
      wshb_ifm.cti = wshb_ifs_vga.cti;
      wshb_ifm.bte = wshb_ifs_vga.bte;

      wshb_ifs_vga.ack = wshb_ifm.ack;
      wshb_ifs_mire.ack = 0;
      wshb_ifs_vga.dat_sm = wshb_ifm.dat_sm;
      wshb_ifs_mire.dat_sm = 0;
    end
    wshb_ifs_mire.err = 0;
    wshb_ifs_vga.err = 0;
    wshb_ifs_mire.rty = 0;
    wshb_ifs_vga.rty = 0;
  end

endmodule
