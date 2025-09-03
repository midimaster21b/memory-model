package mem_pkg;

   // Strobe/Keep: pack or skip disabled strb/keep bits?
   class mem_model #(parameter
		     BASE_ADDR = 0,
		     ADDR_WIDTH = 32,
		     LENGTH = 1024,
		     BYTE_ORDER="MSB",
		     FAIL_ON_MISMATCH = 0,
		     PACK_KEEP = 1
		     );

      local logic [7:0] buffer[LENGTH-1:0]        = '{default: 8'b0};
      local logic [7:0] expect_buffer[LENGTH-1:0] = '{default: 8'b0};

      longint write_address        = 0;
      longint write_expect_address = 0;
      longint read_address         = 0;
      longint read_expect_address  = 0;
      
      function new();
      endfunction // new

      /////////////////////////////////////////////////////////////////////////
      // Expectation functions for establishing what should be written to the
      // buffer region and what should be read.
      /////////////////////////////////////////////////////////////////////////
      function write_expect(
			    input longint address,
			    input [7:0] data[],
			    input strb[] = '{default: 1}
			    );
	 int num_bytes = data.size();

	 // Strobe/Keep size should equal the number of bytes supplied
	 assert(strb.size() == num_bytes);

	 if(PACK_KEEP == '1) begin
	    // Strobe packs the enabled bytes
	    int y=0;

	    for(int x=0; x<num_bytes; x++) begin
	       if(strb[x] == '1) begin
		  expect_buffer[address+y] = data[x];
		  y++;
	       end
	    end

	 end else begin // if (PACK_KEEP == '1)
	    // Strobe simply skips the disabled bytes
	    for(int x=0; x<num_bytes; x++) begin
	       if(strb[x] == '1) begin
		  expect_buffer[address+x] = data[x];
	       end
	    end
	 end // else: !if(PACK_KEEP == '1)
      endfunction // write_expect


      /////////////////////////////////////////////////////////////////////////
      // Functions for writing to the memory region
      /////////////////////////////////////////////////////////////////////////
      function write(input longint address, input [7:0] data[], input strb[] = '{default: 1});
	 int num_bytes = data.size();

	 // Strobe/Keep size should equal the number of bytes supplied
	 assert(strb.size() == num_bytes);

	 if(PACK_KEEP == '1) begin
	    // Strobe packs the enabled bytes
	    int y=0;
	    for(int x=0; x<num_bytes; x++) begin
	       if(strb[x] == '1) begin
		  buffer[address+y] = data[x];
		  y++;
	       end
	    end

	 end else begin // if (PACK_KEEP == '1)
	    // Strobe simply skips the disabled bytes
	    for(int x=0; x<num_bytes; x++) begin
	       if(strb[x] == '1) begin
		  buffer[address+x] = data[x];
	       end
	    end
	 end // else: !if(PACK_KEEP == '1)
      endfunction // write
	       
      
      /////////////////////////////////////////////////////////////////////////
      // Functions for reading from memory
      /////////////////////////////////////////////////////////////////////////
      function read(input longint address, input longint length);
	 // TODO

      endfunction // read

      
      
