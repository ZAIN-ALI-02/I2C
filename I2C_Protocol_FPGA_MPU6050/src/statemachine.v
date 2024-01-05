`include"I2C_master2.v"

module I2C_master_statemachine (
    input wire clk,                // Clock input
    input wire reset,              // Reset input 
    input wire [2:0] selector,
    input wire SDA_in,

    output wire SCL,
    output  wire SDA_out,
    output wire  Tristate  
    
);
localparam idle = 3'b000;
localparam write_first   =  3'b001;
localparam write_second  =  3'b011;
localparam read_first  =  3'b100;
localparam read_second =  3'b110;

   reg [2:0] current_state;
   reg [6:0] address;       // Addresses of the registers
   reg [7:0] data_in;       // Data to be sent
   reg read_write , rst = 0;          // Read_write signal
   reg enable;             //  enable signal
   reg [7:0] address_of_reg;


  always @(posedge clk or posedge reset) 
    begin
        if (reset)begin
                  current_state <= idle;
                  rst <= 1;
          end 
        else 
           begin
            rst <= 0;
                current_state = selector;
          end     
    end

    always @(*) begin
      if (rst)begin
            data_in = 0;
            address_of_reg = 0;
            address = 0;  
            read_write = 0; 
            enable = 0;    


      end
      else begin
       data_in = data_in;
       address_of_reg = address_of_reg;
       address =  address;  
       read_write = read_write;
       enable = enable;
      end
      
    case (current_state)
    idle : begin   // 000
    address = 7'b000_0000;
    address_of_reg =  8'h00;
    enable = 0;
    read_write = 0;
   end
    write_first : begin   // 001
    address = 7'b110_1000;
    address_of_reg =  8'h6B;
    data_in = 8'b0000_0000;
    enable = 1;
    read_write = 0;
   end
    write_second : begin   // 011
    address = 7'b110_1000;
    address_of_reg =  8'h1B;
    data_in = 8'b0000_0000;
    enable = 1;
    read_write = 0;
   end
    read_first : begin   // 100
    address = 7'b110_1000;
    address_of_reg =  8'h44;
    enable = 1;
    read_write = 1;
   end
    read_second : begin   // 110
    address = 7'b110_1000;
    address_of_reg =  8'h43;
    enable = 1;
    read_write = 1;          
   end
   default  begin
    address = 7'b000_0000;
    address_of_reg =  8'h00;
    enable = 0;
    read_write = 0;
   end
    endcase
    end


I2C_master dut_master (
    .clk(clk),
    .reset(reset),
    .SDA_in(SDA_in),
    .address(address),
    .data_in(data_in),
    .read_write(read_write),
    .enable(enable),
    .address_of_reg(address_of_reg),
    .SDA_out(SDA_out),
    .SCL(SCL),
    .Tristate(Tristate)
);
endmodule