module multicycle ( input clk, rst,
              input OpRdy,
              output logic ResRdy,
              input [31:0] op0,op1,
              output logic [31:0] res
              );

logic computing;
logic [1:0] delay_cpt; 

always_ff@(posedge clk)
if (rst)
 begin
    computing <= 0;
    delay_cpt <= '0;
    ResRdy <= 0;
 end
else
begin
  ResRdy <= 0;
  if (computing)
  begin
    delay_cpt <= delay_cpt - 1;
    if (delay_cpt == 0)
    begin
        computing <= 0;
        ResRdy <= 1;
    end
  end
  else if (OpRdy)
    begin
        delay_cpt <= 1;
        computing <= 1;
    end
end

logic [31:0] R0,R1;

//pragma attribute res dedicated_mult OFF

always_ff@(posedge clk)
begin
    if (OpRdy & !computing)
    begin
        R0 <= op0;
        R1 <= op1;
    end
    if (computing && (delay_cpt == 0))
    begin
        res <= R0 * R1;
    end
end

endmodule

//synthesis translate_off
module tb();

logic clk = 0, rst = 0;
logic OpRdy = 0;
logic ResRdy;
logic [31:0] op0,op1;
logic [31:0] res;

multicycle uut ( clk, rst, OpRdy, ResRdy, op0,op1, res);

always #5ns clk=~clk;

initial 
    begin
        @(negedge clk)
          rst = 1;
        @(negedge clk)
          rst = 0;
        @(negedge clk)
        repeat(5)
        begin
            op0 = $random();
            op1 = $random();
            OpRdy = 1;
            @(negedge clk)
            OpRdy = 0;
            forever
            begin
                @(posedge clk)
                if (ResRdy) break;
            end
            $display ("%d x %d = %d (%d)", op0,op1,res,op0*op1);
        @(negedge clk);
        end
    $stop();
    end
endmodule
//synthesis translate_on
