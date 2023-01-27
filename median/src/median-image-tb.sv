/* L'environnement de simulation de MEDIAN est plus simple que celui de
   MED car nous n'avons pas generer le signal de controle BYP et car
   nous savons quand la sortie de MEDIAN est valide grace au signal DSO.
   Le reste est tres similaire ... */

`timescale 1ps/1ps

module MEDIAN_IMAGE_tb;

  logic [7:0] DI;
  logic CLK, nRST, DSI;
  wire [7:0] DO;
  wire DSO;

  MEDIAN I_MEDIAN(.DI(DI), .DSI(DSI), .nRST(nRST), .CLK(CLK), .DO(DO), .DSO(DSO));

  always #10ns CLK = ~CLK;

  initial begin: ENTREES

    integer x, y, rx, ry, i, j, v[0:8], tmp, of;
    logic [7:0] img[0:256*256-1];

    of = $fopen("bogart_filtre.pgm");
    $fdisplay(of, "P2 256 256 255");
    $readmemh("bogart_bruite.hex", img);
    CLK = 1'b0;
    DSI = 1'b0;
    nRST = 1'b0;
    @(negedge CLK);
    nRST = 1'b1;
    for(y = 0; y < 256; y = y + 1)
      for(x = 0; x < 256; x = x + 1) begin
        for(i = - 1; i < 2; i = i + 1)
          for(j = - 1; j < 2; j = j + 1) begin
            rx = x + j;
            ry = y + i;
            rx = (rx == -1) ? 0 : rx;
            rx = (rx == 256) ? 255 : rx;
            ry = (ry == -1) ? 0 : ry;
            ry = (ry == 256) ? 255 : ry;
            v[3 * (i + 1) + j + 1] = img[256 * ry + rx];
          end
        @(negedge CLK);
        DSI = 1'b1;
        for(i = 0; i < 9; i = i + 1) begin
          DI = v[i];
          @(negedge CLK);
        end
        DSI = 1'b0;
        while(DSO == 1'b0)
          @(posedge CLK);
        for(i = 0; i < 8; i = i + 1)
          for(j = i + 1; j < 9; j = j + 1)
            if(v[i] < v[j]) begin
              tmp = v[i];
              v[i] = v[j];
              v[j] = tmp;
            end
        if(DO !== v[4]) begin
          $display("Erreur : DO = ", DO, " au lieu de ", v[4]);
          $stop;
        end
        $fdisplay(of, "%d", DO);
      end
    $fclose(of);
    $display("Fin de simulation sans aucune erreur");
    $finish;
  end

endmodule
