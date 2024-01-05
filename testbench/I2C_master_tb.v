`timescale 1ns / 1ps
`include"I2C_master2.v"

module I2C_master_tb;
    initial begin
        $dumpfile("I2C_master_tb.vcd");
        $dumpvars(0,I2C_master_tb); 
    end

   reg clk;                 // Clock input
   reg d_ack;
   reg a_ack;
   reg reset;               // Reset input 
   reg [6:0] address;       // Addresses of the registers
   reg [7:0] data_in;       // Data to be sent
   reg read_write;          // Read_write signal
   reg enable;             //  enable signal
   wire SCL;
   wire SDA_in;
   wire SDA_out;
   reg [7:0] address_of_reg;


// Instantiate the uart module    

slave dut_slave (
    .clk(clk),
    .reset(reset),
    .SCL(SCL),
    .SDA_out(SDA_in),
    .SDA_in(SDA_out)
);

I2C_master dut_master (
    .clk(clk),
    .reset(reset),
    .address(address),
    .data_in(data_in),
    .read_write(read_write),
    .enable(enable),
    .SCL(SCL),
    .SDA_out(SDA_out),
    .SDA_in(SDA_in),
    .address_of_reg(address_of_reg)
);

// Clock generation (20 MHz clock)
always begin
    #25 clk = ~clk;
end

// Testbench initialization
initial begin
    clk = 1;
    a_ack = 1 ;
    d_ack =0;
    reset = 1;
    read_write = 1;
    enable = 0;
    address = 7'b0000000;
    data_in = 8'b00000000;
    address_of_reg = 8'b00000000;
    #50 
    reset = 0;
    read_write = 0;
    address = 7'b101_0110;
   address_of_reg =  8'b1010_0110;
    data_in = 8'b1010_0110;
    #100
     enable = 1;
     reset = 0;
     #300
     enable = 0;
     #1000
      read_write = 1;
     #1445
      data_in = 8'b1110_0010;
      
 #905
  data_in = 8'b0110_1010;
 #500
data_in = 8'b00000000;
   //  enable = 1;
    // End simulation
    #5000
    $finish;
end

    endmodule