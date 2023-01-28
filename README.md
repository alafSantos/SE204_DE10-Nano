# Architectures reconfigurables et langages HDL
## Alaf do Nascimento Santos

### Exercices

- L'exercice sur la **simulation événementielle** se trouve dans le dossier **ExoSim**.

---

### TD SystemVerilog
- Le **filtre médian** se trouve dans le dossier **median**

---

### TD Interfaces SystemVerilog et Bus Wishbone
- La hiérarchie chargée est structurée de la façon suivante :
    * Le répertoire **controleur_memoire** contient
        * Un fichier **Makefile** permettant de tester le code
        * Un répertoire **wshb_bram_tb_src** contenant les sources d'un testbench pour le contrôleur.
        * Un répertoire **wb_bram** contenant l'implementation du module wishbone slave (wb_bram.sv)

    * Le répertoire **wshb_if** contient
        * la définition de l'interface Wishbone en SystemVerilog
        * la documentation de l'interface Wishbone
        * des outils nécessaires à la réalisation du testbench
---