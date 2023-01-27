module MED #(parameter WIDTH = 8, PIXELS = 9)
            (input [WIDTH-1:0] DI,
             input DSI, BYP, CLK,
             output [WIDTH-1:0] DO);

    logic [WIDTH-1:0] REGISTERS[0:PIXELS-1];
    logic [WIDTH-1:0]MIN, MAX;

    MCE #(.WIDTH(WIDTH))
    myMCE(.A(DO), .B(REGISTERS[PIXELS-2]), .MIN(MIN), .MAX(MAX));


    always_ff @(posedge CLK)
    begin
        //shift register from R0 to R7
        for (integer i = 0; i <= PIXELS - 3; i = i + 1)
        begin
            REGISTERS[i+1] <= REGISTERS[i];
        end
        
        //BYP
        REGISTERS[PIXELS-1] <= BYP ? REGISTERS[PIXELS-2] : MAX;

        //DSI
        REGISTERS[0] <= DSI ? DI: MIN;
    end

    //OUTPUT
    assign DO = REGISTERS[PIXELS-1];

endmodule