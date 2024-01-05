`include"slave.v"

module I2C_master (
    input wire clk,                // Clock input
    input wire reset,              // Reset input 
    input wire enable,             // Enable to start operation
    input wire read_write,          
    input wire [7:0] data_in,      // Data to be sent
    input wire [6:0] address,
    input wire [7:0] address_of_reg,
    output reg SCL,
    input  wire SDA_in, 
    output  wire SDA_out      
);

localparam IDLE             =  3'b000;
localparam START            =  3'b001;
localparam ADD_OF_SLAVE     =  3'b010;
localparam ADD_OF_REGISTER  =  3'b011;
localparam DATA             =  3'b101;
localparam PRE_STOP         =  3'b111;
localparam STOP             =  3'b110;
localparam SR               =  3'b100;


reg [7:0] data_register_1 = 0;
reg [7:0] slave_reg = 8'b0000_0000;
reg [2:0] current_state , next_state;
reg [7:0] shift_reg = 8'b0000_0000;
reg [3:0] shift_count = 4'b0000;
reg [1:0] clk_count = 2'b10;
reg [1:0] ack_cnt = 2'b00;
reg sda , add_cnt_8_m = 0  , reg_cnt_8_m = 0  , data_cnt_8_m = 0  , data_cnt_m = 0 , ack_cnt_m = 0 , data_cnt = 0 , 
data_cnt_8 = 0 , data_neg = 0; 


  always @(posedge clk or posedge reset) 
    begin
        if (reset)begin
                  sda = 1'b1;
                  SCL = 1'b1;
                  current_state <= IDLE;
          end 
        else 
           begin
                current_state = next_state ;
                clk_count = clk_count + 1'b1;  
                SCL = !clk_count[0];
          end     
    end

 always @(posedge clk) begin
    case(current_state)
      IDLE : begin   // 000
                next_state =  enable ? START : IDLE ;
                sda = 1'b1;
                SCL = 1'b1;
    end
      START : begin  // 001
              sda = 1'b0;
              if (SCL == 1)
              next_state = current_state;
              else
              next_state = ADD_OF_SLAVE;
                shift_reg[7:1] = address;
                shift_reg[0] = read_write;
   end
      ADD_OF_SLAVE  : begin  // 010
      
              if (!SCL)begin
                  if (shift_count == 8)
                  add_cnt_8_m = 1;
                  //
                  if (add_cnt_8_m)begin
                   sda <= 1'b1;
                    shift_count = shift_count + 1'b1;
                  end
                  else begin
                  sda <= shift_reg[7];
                  shift_count = shift_count + 1'b1;
                  shift_reg = {shift_reg[6:0], 1'b0};
                  end
             if (shift_count == 9)
                 shift_count = 1'b0;
            else
            begin
                 next_state = current_state;
         end
       end
       if (SCL)begin
                 if (add_cnt_8_m)
                 if (SDA_in == 0) begin
                  if (read_write == 1)
                  next_state = DATA;
                else
                 next_state = ADD_OF_REGISTER;
                 shift_reg = address_of_reg;
         end
            else 
                 next_state =  IDLE ;
       end
   end
         ADD_OF_REGISTER : begin // 011
                if (!SCL)begin
                   add_cnt_8_m = 0;
                  if (shift_count == 8)
                  reg_cnt_8_m = 1;
                  else
                  reg_cnt_8_m = 0;
                  if (reg_cnt_8_m)begin
                    sda <= 1'b1;
                    shift_count = shift_count + 1'b1;
                  end
                  else begin
                  sda <= shift_reg[7];
                  shift_count = shift_count + 1'b1;
                  shift_reg = {shift_reg[6:0], 1'b0};
                  end
             if (shift_count == 9)
                 shift_count = 1'b0;
         
            else
            begin
                 next_state = current_state;
         end
       end
       if (SCL)begin
                 if (reg_cnt_8_m)
                 if (SDA_in == 0) begin
                 if (read_write == 1)
                  next_state = SR;
                else
                 next_state = DATA;
                 shift_reg = data_in;
         end
            else 
                 next_state =  IDLE ;
       end
          
      end

      SR : begin
              SCL = 1;
              sda = 0;
              if (SCL == 0)
              next_state = current_state;
              else
              next_state = ADD_OF_SLAVE;
              shift_reg[7:1] = address;
              shift_reg[0] = read_write;
       
      end

      DATA : begin // 101
      
             if (read_write == 1)begin
              if (SCL)begin
             shift_reg = {shift_reg[6:0],SDA_in};
             shift_count = shift_count + 1'b1;
            if (shift_count == 9)begin
               data_cnt = 1'b1;
               ack_cnt  = ack_cnt + 1;
               shift_count = 0;

      end
      else
      data_cnt = 1'b0;

          if (shift_count == 8)begin
               data_cnt_8 = 1;
               data_register_1 = shift_reg;
          end
          else
          data_cnt_8 = 0;
              
     
     if (data_cnt) begin
         // SDA_out = 1'b0;
          next_state = DATA;
            
     
          if (ack_cnt == 3)begin
              next_state = STOP;     
          end
     end
      else
      next_state = current_state;
    end

          if (!SCL)begin
          if (data_cnt_8)
          sda <= 0;
          else
          sda <= 1;
          end
          if (!SCL)begin
            
          if (data_cnt_8)begin
          if (ack_cnt == 2'b10)
          sda <= 1;
          else
          sda <= 0;
          end
          end
     end
   


      if  (read_write == 0)begin
              if (!SCL)begin
                reg_cnt_8_m = 0;
                add_cnt_8_m = 0;
            if (shift_count == 8)
                  data_cnt_8_m = 1;
                  else
                  data_cnt_8_m = 0;
                  if (data_cnt_8_m)begin
                    sda <= 1'b1;
                    shift_count = shift_count + 1'b1;
                  end
                  else begin
                  sda <= shift_reg[7];
                  shift_count = shift_count + 1'b1;
                  shift_reg = {shift_reg[6:0], 1'b0};
                  end
                 if (shift_count == 9)begin
                 shift_count = 1'b0;
                 ack_cnt  = ack_cnt + 1;
                 end
            else
            begin
                 next_state = current_state;
         end
      end
       if (SCL)begin
                 if (data_cnt_8_m)
                 if (SDA_in == 0) begin
                    if(ack_cnt == 3)begin
                    next_state = PRE_STOP;
                    end
                    else
                 next_state = DATA;
                 shift_reg = data_in;
                 
         end
            else 
                 next_state =  IDLE ;
       end
      end
      end
     
      PRE_STOP : begin // 111
         data_cnt_8_m = 0;
         sda = 0 ;
         next_state = STOP;
         end

         STOP : begin // 110
         next_state = IDLE;
         SCL = 1 ;
    
         end

     default : begin 
         next_state = IDLE ;
         end
    endcase
  end

assign SDA_out = sda;



endmodule