module MCE_tb;  // Un environnement de simulation n'a ni entrées ni
                // sorties.

  logic [7:0] A, B;      // On déclare les variables qui seront connectées
  wire  [7:0] MAX, MIN; // aux entrées/sorties du module a tester.
                       // Les types doivent être compatibles avec les
                       // ports du module et avec l'usage qu'on en fait.
                       // A et B sont déclarés "logic" car leur valeur
                       // sera modifiée par un bloc "always" ou
                       // "initial".

  MCE I_MCE(.A(A), .B(B), .MAX(MAX), .MIN(MIN)); // On instancie le module a tester.

  initial begin: ENTREES // Ici tout est géré par un seul bloc "initial"
                         // que l'on nomme pour pouvoir y déclarer des
                         // variables locales.

    logic [7:0] RAND, vmin, vmax; // Quatre variables locales.
                                 // RAND sera utilisée par le générateur
                                 // aléatoire,
                                 // vmax et vmin seront utilisées pour calculer
                                 // les  valeurs attendues.

    repeat (1000) begin // Nous allons simuler 1000
                                          // vecteurs.
      RAND = $random ; // On donne aux entrées A et B une valeur
      A = RAND;        // aléatoire entre 0 et 255.
      RAND = $random ;
      B = RAND;
      #1; // On attend une unité de temps pour laisser au module sous
          // test le temps de mettre ses sorties a jour.
      if(A < B) begin // On calcule les sorties attendues par un
        vmin = A;     // algorithme différent de celui utilise dans le
        vmax = B;     // module sous test.
      end
      else begin
        vmin = B;
        vmax = A;
      end
      if(MIN !== vmin || MAX !== vmax) begin // Si les sorties ne sont
                                             // pas celles attendues.
        $display("Erreur : MIN = ", MIN, ", MAX = ", MAX,
                 " au lieu de MIN = ", vmin, ", MAX = ", vmax);
               // On produit un message d'erreur.
        $stop; // Et on stoppe la simulation.
      end
    end
    // Lorsque la simulation est terminée on affiche un message.
    $display("Fin de la simulation sans aucune erreur"); 
    $finish; // Et on termine la simulation.

  end

endmodule

