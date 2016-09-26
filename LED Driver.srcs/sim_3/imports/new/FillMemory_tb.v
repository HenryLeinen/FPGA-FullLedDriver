module FillMemory_tb (
                     );

    reg clk;
    reg cs_n;
    wire done;
    
    wire    [10:0]  wr_addr;
    wire    [23:0]  wr_data;
    wire            wr_ena;

    FillMemory DUT(
        .clk(clk),
        .cs_n(cs_n),
        .done(done),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .wr_ena(wr_ena),
        .fill_color(23'b101010100011110001010101)
    );
    
    initial begin
        cs_n = 1;
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        @(posedge clk);
        #14 cs_n = 0;
        @(posedge done) $finish;
    end
endmodule
