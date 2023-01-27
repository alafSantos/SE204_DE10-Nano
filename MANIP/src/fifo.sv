module fifo      #( parameter DATA_WIDTH  = 8, DEPTH_WIDTH = 5)
                  ( clk, nrst, rdata, wdata, read, write,  full, empty);
input  logic  clk, nrst;
output logic [DATA_WIDTH-1:0] rdata;
input  logic [DATA_WIDTH-1:0] wdata;
input  logic read, write;
output logic full, empty;


localparam DEPTH = 2**DEPTH_WIDTH;

logic [DATA_WIDTH-1:0]     mem [DEPTH-1:0];
logic [DEPTH_WIDTH:0]      r_index;
logic [DEPTH_WIDTH:0]      w_index;

// mem
always_ff @(posedge clk)
    if (write)
    mem[w_index] <= wdata;

assign rdata = mem[r_index];

always_ff @(posedge clk or negedge nrst)
begin:indexes
logic [DEPTH_WIDTH:0]  used_words;
    if (nrst == 0)
    begin
        r_index    <= '0;
        w_index    <= '0;
        used_words  = '0;
        empty      <= 0;
        full       <= 0;
    end
    else
    begin
        if (read)
        begin
            r_index <= r_index + 1;
        end
        if (write)
        begin
            w_index <= w_index + 1;
        end

        used_words = used_words + write - read;
        empty <= ( used_words == 0 );
        full  <= ( used_words == DEPTH -1 );

    end
end


endmodule
