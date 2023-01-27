/* L'environnement de simulation de MEDIAN est plus simple que celui de
   MED car nous n'avons pas generer le signal de controle BYP et car
   nous savons quand la sortie de MEDIAN est valide grace au signal DSO.
   Le reste est tres similaire ... */


`timescale 1ps/1ps

module MEDIAN_tb;

  logic [7:0] DI;
  logic CLK, nRST, DSI;
  wire  [7:0] DO;
  wire  DSO;

  MEDIAN I_MEDIAN(  .DI(DI),.DO(DO),
                    .CLK(CLK), .DSI(DSI), 
                    .nRST(nRST), .DSO(DSO)
                 );

  always #10ns CLK = ~CLK;

  initial begin: ENTREES

    int i, j, k, v[0:8], tmp;

    CLK  = 1'b0;
    DSI  = 1'b0;
    nRST = 1'b0;
    @(negedge CLK);
    nRST = 1'b1;
    repeat(1000) begin
      @(negedge CLK);
      DSI = 1'b1;
      for(j = 0; j < 9; j = j + 1) begin
        v[j] = {$random} % 256 ;
        DI   = v[j];
        @(negedge CLK);
      end
      DSI = 1'b0;
      while(DSO == 1'b0) @(posedge CLK);
      for(j = 0; j < 8; j = j + 1)
        for(k = j + 1; k < 9; k = k + 1)
          if(v[j] < v[k]) begin
            tmp = v[j];
            v[j] = v[k];
            v[k] = tmp;
          end
      if(DO !== v[4]) begin
        $display("Erreur : DO = ", DO, " au lieu de ", v[4]);
        $stop;
      end
    end
    $display("Fin de simulation sans aucune erreur");
    $finish;
  end

endmodule
