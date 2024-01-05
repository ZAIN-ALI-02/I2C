`timescale 1ns / 1ps

`include"statemachine.v"

module I2C_master_tb;
    initial begin
        $dumpfile("I2C_master_tb.vcd");
        $dumpvars(0,I2C_master_tb); 
    end

   reg clk;                 // Clock input
   reg reset;               // Reset input 
   reg SDA_in;
   reg [2:0] selector;


// Instantiate the uart module    

I2C_master_statemachine dut_statemachine(
    .clk(clk),
    .reset(reset),
    .selector(selector),
    .SDA_in(SDA_in)
);

// Clock generation (20 MHz clock)
always begin
    #25 clk = ~clk;
end

// Testbench initialization
initial begin
    SDA_in = 0;
    clk = 1;
    reset = 1;
    #50 
    reset = 0;
    selector = 3'b000;
    #1000
    selector = 3'b001; // write 
    #2500
    SDA_in = 1;
    #400
    selector = 3'b000;
    #3000
     selector = 3'b011; // write 
     SDA_in = 0;
    #2500
    SDA_in = 1;
     #400
    selector = 3'b000;
    #3000
    selector = 3'b100; // read
    SDA_in = 0;
    #3300
     SDA_in = 1;
    #400
    selector = 3'b000;
    #3000
    selector = 3'b110; // read
     SDA_in = 0;
    #3700
     SDA_in = 1;
     #200

    selector = 3'b000;
   
    // End simulation
    #50000
    $finish;
end
    endmodule