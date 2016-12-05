module crc(crc_if m);
 
// Variables declaration
  logic [31:0] crc_data1,crc_data, crc_poly, crc_ctrl, seed, seed1,test1;
  bit flag, r;
  bit p,was,tcrc;
  bit [1:0] tot,totr;
  bit fxor;
 // logic [31:0] data_rd_f;
  
 assign was = crc_ctrl[25];
 assign tcrc = crc_ctrl[24];
 assign tot = crc_ctrl[31:30];
 assign totr = crc_ctrl[29:28];
 assign fxor = crc_ctrl[26];

  //assign data_rd_f = 32'h0000_1234;

//***********************************
//  Main program starts here
//***********************************
  
	//always @(posedge cif.clk)
	//  begin
	//    if(cif.rst)
	//      begin
	//	seed_1     <= 0;
	//	crc_data_1 <= 0;
	////	p          <= 0;
	//      end
	//    else
	//      begin
	//        if(p!=1)                 // This condition has been written because when the address change then crc_data_1 value also changes with the new value.
	//          begin
	//            seed_1     <= seed;
	//	        crc_data_1 <= crc_data;
	//          end 
	//	    
	//	
	//      end
	//  end   
//============================================================


  always @(*) begin				// This block is written for the read operation.
    
   if(m.Sel)
      begin
        if     (!m.RW && m.addr == 32'h4003_2000) m.data_rd = crc_data1; 
        else if(!m.RW && m.addr == 32'h4003_2004) m.data_rd = crc_poly; 
        //else if(!m.RW && m.addr == 32'h4003_2008) m.data_rd = crc_ctrl;
  	else m.data_rd = crc_ctrl;
      end
    else m.data_rd = 32'h0000_1234;
  end

  always@(posedge m.clk or posedge m.rst)
    begin
      if(m.rst)
		begin
		  crc_data = 32'hffff_ffff;
		  crc_data1 = 32'hffff_ffff;
		  seed1 = 32'hffff_ffff;
		  crc_poly = 32'h0000_1021;
		  crc_ctrl = 32'h0000_0000;
		end
	 else
         if(m.Sel) begin
		begin
                
          
		  if(m.addr == 32'h4003_2000)
			begin
			  if(m.RW == 0)		// This is a read operation. But nothing goes in here because everything goes from the always@(*) block.
				begin
                                  p = 0;
				  //cif.data_rd = crc_data; // this is a problem that needs to be solved.

				end
			  else
				begin
				  crc_data = m.data_wr;

//-----------------------------------------------------------------------------------------------------------------------
// An extra block for FXOR calculation is added here.

				

//-----------------------------------------------------------------------------------------------------------------------
                  
                case(tot)
                  2'b00: begin crc_data = crc_data; end
                  2'b01: crc_data = {crc_data[24],crc_data[25],crc_data[26],crc_data[27],crc_data[28],crc_data[29],crc_data[30],crc_data[31],crc_data[16],crc_data[17],crc_data[18],crc_data[19],crc_data[20],crc_data[21],crc_data[22],crc_data[23],crc_data[08],crc_data[09],crc_data[10],crc_data[11],crc_data[12],crc_data[13],crc_data[14],crc_data[15],crc_data[00],crc_data[01],crc_data[02],crc_data[03],crc_data[04],crc_data[05],crc_data[06],crc_data[07]};
                  2'b10: crc_data = {crc_data[00],crc_data[01],crc_data[02],crc_data[03],crc_data[04],crc_data[05],crc_data[06],crc_data[07],crc_data[08],crc_data[09],crc_data[10],crc_data[11],crc_data[12],crc_data[13],crc_data[14],crc_data[15],crc_data[16],crc_data[17],crc_data[18],crc_data[19],crc_data[20],crc_data[21],crc_data[22],crc_data[23],crc_data[24],crc_data[25],crc_data[26],crc_data[27],crc_data[28],crc_data[29],crc_data[30],crc_data[31]};
                  2'b11: crc_data = {crc_data[07],crc_data[06],crc_data[05],crc_data[04],crc_data[03],crc_data[02],crc_data[01],crc_data[00],crc_data[15],crc_data[14],crc_data[13],crc_data[12],crc_data[11],crc_data[10],crc_data[09],crc_data[08],crc_data[23],crc_data[22],crc_data[21],crc_data[20],crc_data[19],crc_data[18],crc_data[17],crc_data[16],crc_data[31],crc_data[30],crc_data[29],crc_data[28],crc_data[27],crc_data[26],crc_data[25],crc_data[24]};
                endcase
                    test1 = crc_data;
		                if(tcrc) begin
				  if(!was) begin
				    for(int i=0; i<32; i++)
				    begin
				      if(seed[31]==0)
				      begin
				  	  seed = seed << 1;
				  	  seed[0] = crc_data[31];
				  	  crc_data = crc_data << 1;
				      end
				      else
				      begin
				  	seed = seed << 1;
				  	seed[0] = crc_data[31];
				  	crc_data = crc_data << 1;
				  	seed  = seed ^ crc_poly;
	         		      end
				    end
				    crc_data = seed;
                                  end
      				  else 
                                  begin
 				    seed = crc_data;
              			  end
                                  crc_data = seed;
                                end
                                else
                                begin
				  if(!was) begin
			            for(int i=0; i<32; i++)
				    begin
			              if(seed1[15]==0)
				      begin
					seed1[15:0] = {seed1[14:0],crc_data[31]};
					crc_data   = crc_data << 1;
				      end
				      else
				      begin
					seed1[15:0] = {seed1[14:0],crc_data[31]};
					crc_data = crc_data << 1;
					seed1[15:0]  = seed1[15:0] ^ crc_poly[15:0];
				      end
				    end
				    crc_data = {16'b0, seed1[15:0]}; 
                                  end
      				  else begin
 				    seed1 = {16'b0, crc_data[15:0]};
              			  end
                                    crc_data = {16'b0, seed1[15:0]};
                                end
				end
                                      crc_data1 = crc_data;

				if(fxor == 1'b1)
				  begin
				    if(tcrc == 1'b1)
				      begin
			 	        crc_data1 = crc_data1 ^ 32'hffff_ffff;
				      end
				    else
				      begin
				        crc_data1 = crc_data1 ^ 32'h0000_ffff;
					/*
				        if(totr == 2'b10)
				          begin
					    crc_data1 = crc_data1 ^ 32'hffff_0000;
				        end
				        else if(totr == 2'b11)
				          begin
					    crc_data1 = crc_data1 ^ 32'hffff_0000;
				          end
				        else
				          begin
					    crc_data1 = crc_data1 ^ 32'h0000_ffff;
				          end */
				      end
				  end
				else
				  begin
				    crc_data1 = crc_data1;
				  end


                case(totr)
                  2'b00: begin end
                  2'b01: begin crc_data1= {crc_data1[24],crc_data1[25],crc_data1[26],crc_data1[27],crc_data1[28],crc_data1[29],crc_data1[30],crc_data1[31],crc_data1[16],crc_data1[17],crc_data1[18],crc_data1[19],crc_data1[20],crc_data1[21],crc_data1[22],crc_data1[23],crc_data1[08],crc_data1[09],crc_data1[10],crc_data1[11],crc_data1[12],crc_data1[13],crc_data1[14],crc_data1[15],crc_data1[00],crc_data1[01],crc_data1[02],crc_data1[03],crc_data1[04],crc_data1[05],crc_data1[06],crc_data1[07]}; end
                  2'b10: begin crc_data1 = {crc_data1[00],crc_data1[01],crc_data1[02],crc_data1[03],crc_data1[04],crc_data1[05],crc_data1[06],crc_data1[07],crc_data1[08],crc_data1[09],crc_data1[10],crc_data1[11],crc_data1[12],crc_data1[13],crc_data1[14],crc_data1[15],crc_data1[16],crc_data1[17],crc_data1[18],crc_data1[19],crc_data1[20],crc_data1[21],crc_data1[22],crc_data1[23],crc_data1[24],crc_data1[25],crc_data1[26],crc_data1[27],crc_data1[28],crc_data1[29],crc_data1[30],crc_data1[31]};end
                  2'b11: begin crc_data1 = {crc_data1[07],crc_data1[06],crc_data1[05],crc_data1[04],crc_data1[03],crc_data1[02],crc_data1[01],crc_data1[00],crc_data1[15],crc_data1[14],crc_data1[13],crc_data1[12],crc_data1[11],crc_data1[10],crc_data1[09],crc_data1[08],crc_data1[23],crc_data1[22],crc_data1[21],crc_data1[20],crc_data1[19],crc_data1[18],crc_data1[17],crc_data1[16],crc_data1[31],crc_data1[30],crc_data1[29],crc_data1[28],crc_data1[27],crc_data1[26],crc_data1[25],crc_data1[24]};end
                endcase
			end
		  else if(m.addr == 32'h4003_2004)
			begin
			  
			  if(m.RW == 0)		// This is a read operation. But nothing goes in here because everything goes from the always@(*) block.
				begin
				 /// cif.data_rd = crc_poly;
				end
			  else
				begin
				  crc_poly    = m.data_wr;
				end

			end
		  else if(m.addr == 32'h4003_2008)
			begin
			  
			  if(m.RW == 0)		// This is a read operation. But nothing goes in here because everything goes from the always@(*) block.
			 	begin
				end
			  else
				begin
				  crc_ctrl    = m.data_wr;
				end

			end

	     end	
	end
    end

endmodule
