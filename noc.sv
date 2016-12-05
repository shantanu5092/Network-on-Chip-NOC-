//`include "fifo_i.sv"

module mem32x64(input bit clk,input logic [7:0] waddr,
    input logic [99:0] wdata, input bit write,
    input logic [7:0] raddr, output logic [99:0] rdata);

logic [99:0] mem[0:175];

logic [99:0] rdatax;

logic [99:0] w0,w1,w2,w3,w4,w5,w6,w7;

assign rdata = rdatax;

always @(*) begin
  rdatax <= #2 mem[raddr];
end

always @(posedge(clk)) begin
  if(write) begin
    mem[waddr]<=#2 wdata;
  end
end

endmodule
   
module FIFO(clk, rst, push, data_in, pop ,data_out , fifo_full, fifo_empty);

input bit clk, rst, push, pop ;        // push = write     // pop = read
input  logic [99:0] data_in;
output logic [99:0] data_out;
output bit fifo_full, fifo_empty;


logic [7:0] write_address;
logic [7:0] read_address;
logic [7:0] fifo_count;

// generate internal write address
always@(posedge clk or posedge rst)

if (rst)
    write_address <= #1 'b0;  // 256 locations
else
    if (push == 1'b1 && (!fifo_full))                   // if write = 1 and if fifo is NOT full then perform write operation
        write_address <= #1 write_address + 1'b1;

// generate internal read address pointer
always@(posedge clk or posedge rst)
if (rst)
    read_address <= #1 'b0; // 256 locations
else
    if (pop == 1'b1 && (!fifo_empty))                   // if read = 1 and if fifo is NOT empty then perform read operation
        read_address <= #1 read_address +1'b1;

// generate FIFO count
// increment on push, decrement on pop
always@(posedge clk or posedge rst)
if (rst)
    fifo_count <= #1 'b0;   // 256 locations
else
    if (push== 1'b1 && pop == 1'b0 && (!fifo_full))
        fifo_count <= #1 (fifo_count + 1);        // increment counter if write
else
    if (push== 1'b0 && pop == 1'b1 && (!fifo_empty))               // decrement counter if read
        fifo_count <= #1 (fifo_count - 1);

// generate FIFO signals

assign fifo_full  =  (read_address == write_address+1)? 1'b1:1'b0; //(fifo_count == 8'b11111111)?1'b1:1'b0;
assign fifo_empty =   (read_address == write_address) ? 1'b1:1'b0; //(fifo_count == 8'b00000000)?1'b1:1'b0;

// connect RAM

mem32x64 mem1 (clk,write_address,data_in,push,read_address,data_out);

endmodule

module noc(nocif n, crc_if c);

// These are the states defined in terms of parameter for state machine -1

  parameter idle_st 	    = 4'b0000;  //=0
  parameter src_id_st 	    = 4'b0001;  //=1
  parameter addr_st_1 	    = 4'b0010;  //=2
  parameter addr_st_2 	    = 4'b0011;  //=3
  parameter addr_st_3 	    = 4'b0100;  //=4
  parameter addr_st_4 	    = 4'b0101;  //=5
  parameter len_st          = 4'b0110;  //=6
  parameter write_data_st_1 = 4'b0111;  //=7
  parameter write_data_st_2 = 4'b1000;  //=8
  parameter write_data_st_3 = 4'b1001;  //=9
  parameter write_data_st_4 = 4'b1010;  //=10
  parameter testing_st	    = 4'b1011;  //=11

  //parameter read_data_st  = 4'b1000;  //=8

// These are the states defined in terms of parameter for state machine -2

  parameter idle_st_2 	    = 3'b000;  //=0
  parameter read_st_2_1     = 3'b001;  //=1
  parameter read_st_2_2     = 3'b010;  //=2
  parameter read_st_2_3     = 3'b011;  //=3
  parameter write_st_2      = 3'b100;  //=4

// Variable declaration for state machine -1 

  logic [99:0] data_in_fifo, data_out_fifo;
  logic [31:0] addr;
  logic [31:0] wr_data;
  logic [7:0]  length;
  logic [7:0]  DataW;
  logic [7:0]  ctrl_main, ctrl_main_flop;
  logic [7:0]  source_id;
  logic [3:0]  present_state, next_state;		// Number of possible state values is 16.
  bit          len;
  bit 	       push, pop;

/*
  ;
  , addr_flop;
  logic [31:0] wr_data, wr_data_flop;
  
  , return_id;
  
  logic [2:0]  cntr; 					// cntr = counter for address bytes; cntr1 = counter for write bytes.
  
  
  bit 	       flag_exp, flag_src_id, flag_addr;

  bit 	       fifo_full, fifo_empty;
*/

// Variable declaration for state machine -2

  logic [2:0]  present_state_2, next_state_2;
  logic [7:0]  source_id_2, return_id_2;
  logic [7:0]  ctrl_main_2;
  logic [31:0] addr_2, addr_2_flop;
  logic [31:0] data_2;
  logic [7:0]  length_2;
  logic [31:0] temp1, temp2, temp3, temp4;

// Variable declaration for state machine -3


// Instantiation of a FIFO

  FIFO f1 (n.clk, n.rst, push, data_in_fifo, pop, data_out_fifo, fifo_full, fifo_empty);

  //fifo f1 (data_in_fifo, data_out_fifo, RW, n.clk, n.rst);

  //fifo f2 (data_in_fifo, data_out_fifo, 1'b0, n.clk, n.rst);

//------------------------------------------------------code starts from here----------------------------------------------------------------
  
  //assign DataWs    = n.DataW;					// This is the 8-bit data(common register) that comes from the testbench to NOC.
  //assign CmdW      = n.CmdW;					// This is the 9th bit-> bit[8] of the data that comes to NOC from the testbench. 

// This is always @posedge block for state machine -1

/*********************ISSUE****************
  The major issue in this design is that if CmdW (personal) is used then the state machine does not respond to it. 
*******************************************
*/

  always@(posedge n.clk or posedge n.rst)
    begin
      if(n.rst)
        begin
	  DataW	 	  = 0;
	  //CmdW 	  = 0;
	  ctrl_main_flop  = 0;
	  addr_2_flop     = 0;
	  present_state   = idle_st;
	  present_state_2 = idle_st_2;
	end
      else
	begin
	  DataW 	  = n.DataW;
	  //CmdW	  = n.CmdW;
	  ctrl_main_flop  = ctrl_main;
	  addr_2_flop     = addr_2;
	  present_state   = next_state;
	  present_state_2 = next_state_2;
	end
    end


// This is the combinational block for state machine -1
//-----------------------------------------------------
  always@(*)
    begin
      case(present_state)
      idle_st:		// This is state = 0
	begin
	  if(n.CmdW == 1)
	    begin
	      ctrl_main = DataW;

	      if	(DataW[7:5] == 3'b000) next_state = idle_st;
	      else 
		begin
		  next_state 	= src_id_st;
		  len	     	= DataW[4];
	      	end
	    end

	  push		= 0;  //-----------this is changed 2
	  //pop			= 1;
	end

      src_id_st:	// This is state = 1
	begin
	  source_id	= DataW;
	  next_state	= addr_st_1;
	end

      addr_st_1:	// This is state = 2
	begin
	  addr[7:0]	= DataW;
	  next_state	= addr_st_2;
	end

      addr_st_2:	// This is state = 3
	begin
	  addr[15:8]	= DataW;
	  next_state	= addr_st_3;
	end

      addr_st_3:	// This is state = 4
	begin
	  addr[23:16]	= DataW;
	  next_state	= addr_st_4;
	end

      addr_st_4:	// This is state = 5
	begin
	  addr[31:24]	= DataW;
	  next_state	= len_st;
	end

      len_st:		// This is state = 6
	begin
	  length	= DataW;

	  if      	(ctrl_main_flop[7:5] == 3'b001)		// READ
	      begin
	 	push	        = 1;
		//pop		= 0;  //--------This is changed
		data_in_fifo	= {12'b0, ctrl_main, source_id, addr, length, 32'b0};
		next_state     	= idle_st;
	      end
	    else if	(ctrl_main_flop[7:5] == 3'b011)		// WRITE
	      begin
		next_state     = write_data_st_1;
	      end
	end

      write_data_st_1:		// This is state = 7
	begin
	  wr_data[7:0]		= DataW;
	  next_state		= write_data_st_2;
	end

      write_data_st_2:		// This is state = 8
	begin
	  wr_data[15:8]		= DataW;
	  next_state		= write_data_st_3;
	end

      write_data_st_3:		// This is state = 9
	begin
	  wr_data[23:16]	= DataW;
	  next_state		= write_data_st_4;
	end

      write_data_st_4:		// This is state = 10
	begin
	  wr_data[31:24]	= DataW;
	  push			= 1;
	  //pop 			= 0;  //---------------this is changed
	  data_in_fifo	  	= {12'b0, ctrl_main, source_id, addr, length, wr_data};
	  next_state		= idle_st;
	  //next_state		= testing_st;
	end
/*
      testing_st:
	begin
	  push			= 0;
	  pop 			= 1;
	  //RW			= 0;
	  //output1		= data_out_fifo;
	  next_state		= idle_st;
	end
*/

      endcase
    end

//*********This is the second state machine that takes data from the FIFO and writes in the CRC block depending upon the address*****************
// This state machine will generate signals for the CRC block which was earlier generated by the test-bench.

  always@(*)
    begin
      case(present_state_2)
	idle_st_2:
	  begin
	    //push		= 0;  //---------------this is changed
	    pop			= 1;
	    c.Sel		= 0;

	    ctrl_main_2    = data_out_fifo[87:80];		
	    source_id_2    = data_out_fifo[79:72];		
	    addr_2         = data_out_fifo[71:40];
	    length_2	   = data_out_fifo[39:32];
	    data_2	   = data_out_fifo[31:0];
	    
	    if		(ctrl_main_2[7:5] == 3'b001) next_state_2 = read_st_2_1;	// This is a read
	    else if	(ctrl_main_2[7:5] == 3'b011) next_state_2 = write_st_2;		// This is a write
	    else 				     next_state_2 = idle_st_2;		// This is an idle

	    //temp4		= c.data_rd;
	  end

	read_st_2_1:
	  begin
	    c.RW		= 0;
	    c.Sel		= 1;
	    c.addr 		= addr_2_flop;
	    temp1		= c.data_rd;

	    if (length_2 == 8'h04)	next_state_2 = idle_st_2;
	    else
	      begin
		addr_2		= addr_2_flop + 4;
	 	next_state_2 	= read_st_2_2;
	      end
	  end

	read_st_2_2:
	  begin
	    c.addr		= addr_2_flop;
	    temp2		= c.data_rd;

	    if (length_2 == 8'h08)	next_state_2 = idle_st_2;
	    else
	      begin
		addr_2		= addr_2_flop + 4;
		next_state_2	= read_st_2_3;
	      end
	  end

	read_st_2_3:
	  begin
	    c.addr		= addr_2_flop;
	    temp3		= c.data_rd;

	    next_state_2	= idle_st_2;
	  end

	write_st_2:					
  	  begin
	    c.addr	   = addr_2_flop;
	    c.RW	   = 1;
	    c.Sel	   = 1;
	    c.data_wr	   = data_2;

	    next_state_2   = idle_st_2;
	  end

      endcase
    end

endmodule
