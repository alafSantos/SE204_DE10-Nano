EXE = vlog +acc 
ALTERA = -L cycloneii_ver

.PHONY : clean

MCE: ../src/MCE.sv
	$(EXE) $^

mce: ../src/mce-tb.sv
	$(EXE) $^

MED: ../src/MED.sv
	$(EXE) $^

med: ../src/med-tb.sv
	$(EXE) $^

MEDIAN: ../src/MEDIAN.sv
	$(EXE) $^

median: ../src/median-tb.sv
	$(EXE) $^

median_img: ../src/median-image-tb.sv
	$(EXE) $^
	
modelsim.ini:
	vmap cycloneii_ver /comelec/softs/opt/altera/altera13.0sp1/sim_lib/verilog_libs/cycloneii_ver

simMEDIAN:
	vsim MEDIAN_tb $(ALTERA)
	
simMEDIAN_IMG:
	vsim MEDIAN_IMAGE_tb $(ALTERA)

work:
	vlib work

clean:
	rm -r work