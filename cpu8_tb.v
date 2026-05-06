`timescale 1ns/1ps

module cpu8_tb;

reg clk;
reg reset;


cpu8 uut (
    .clk(clk),
    .reset(reset)
);


always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;

    #10 reset = 0;

   
    #100;

    $stop;
end


initial begin
    $monitor("T=%0t | PC=%d | R1=%d | R2=%d | MEM[22]=%d",
        $time,
        uut.pc,
        uut.RF.R[1],
        uut.RF.R[2],
        uut.DM.memory[8'h22]
    );
end

endmodule