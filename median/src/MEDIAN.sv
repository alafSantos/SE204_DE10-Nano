module MEDIAN #(parameter WIDTH = 8)
               (input [WIDTH-1:0] DI,
                input DSI, nRST, CLK,
                output [WIDTH-1:0] DO,
                output logic DSO);
    logic BYP;
    logic [3:0] counter, state;  
    localparam state0 = 4'd0, state1 = 4'd1, state2 = 4'd2, state3 = 4'd3,
    state4 = 4'd4, state5 = 4'd5, state6 = 4'd6;

    MED #(.WIDTH(WIDTH))
    myMED(.DI(DI), .DSI(DSI), .CLK(CLK), .BYP(BYP), .DO(DO));
    
    always_ff @(posedge CLK)
    begin
        if(nRST)
        begin
            if(counter == 4'd8)
                counter <= 0;

            else
                counter <= counter + 1;

            if(state == state0)
            begin
                state <= (DSI) ? state1 : state0;
                counter <= 0;
            end

            else if(state == state6 && counter == 4'd4)
                state <= (DSI) ? 1 : 0;
            
            else if(counter == 4'd8)
                state <= state + 1;
        
        end
        else //reset
        begin
            counter <= 0;
            state   <= 0;
        end
    end

    always_comb
    begin
        BYP = 0;
        DSO = 0;
        
        if(state == state6)
        begin
            if(counter == 4'd4)
            begin
                BYP = 0;
                DSO = 1;
            end
        end

        else if(state == state5)
        begin
            if(counter > 4'd4)
            begin
                BYP = 1;
                DSO = 0;
            end
        end

        else if(state == state4)
        begin
            if(counter > 4'd5)
            begin
                BYP = 1;
                DSO = 0;
            end
        end

        else if(state == state3)
        begin
            if(counter > 4'd6)
            begin
                BYP = 1;
                DSO = 0;
            end
        end

        else if(state == state2)
        begin
            if(counter > 4'd7)
            begin
                BYP = 1;
                DSO = 0;
            end
        end

        else if(state == state1)
        begin
            if(counter <= 4'd7)
            begin
                BYP = 1;
                DSO = 0;
            end
        end
    end
endmodule