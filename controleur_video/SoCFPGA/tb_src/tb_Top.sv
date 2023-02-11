`timescale 1ns / 1ps `default_nettype none

module tb_Top;

  // Entrées sorties extérieures
  bit FPGA_CLK1_50;
  logic [1:0] KEY;
  wire [7:0] LED;
  logic [3:0] SW;

  // Interface vers le support matériel
  hws_if hws_ifm ();

  ///////////////////////////////
  //  Code élèves
  //////////////////////////////

  // Signal d'horloge
  always #10ns FPGA_CLK1_50 = ~FPGA_CLK1_50;

  `define SIMULATION 1'b1

  // Démarrage de la simulation
  initial begin
    $display("Starting...");
    KEY[0] = 1;
    #128ns KEY[0] = 0;
    #128ns KEY[0] = 1;
    #10ms $stop();
  end

  video_if myVideo ();
  
  // Instance du module Top
  Top #(
      .HDISP(160),
      .VDISP(90)
  ) myTop (
      .FPGA_CLK1_50(FPGA_CLK1_50),
      .KEY(KEY),
      .LED(LED),
      .SW(SW),
      .hws_ifm(hws_ifm),
      .video_ifm(myVideo)
  );

  // Instance du module screen
  screen #(
      .mode(13),
      .X(160),
      .Y(90)
  ) screen0 (
      .video_ifs(myVideo)
  );

endmodule
