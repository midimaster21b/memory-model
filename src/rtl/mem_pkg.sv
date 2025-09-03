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
      // Burst/Streaming functionality
      /////////////////////////////////////////////////////////////////////////
      /***********************************************************************
       * Burst address functions
       ***********************************************************************/
      function void burst_write_addr(input longint addr);
	 write_address = addr;
      endfunction // burst_write_addr

      function void burst_read_addr(input longint addr);
	 read_address = addr;
      endfunction // burst_read_addr

      /***********************************************************************
       * Burst write functions
       ***********************************************************************/
      function void burst_write_byte(input logic [7:0] data);
	 buffer[write_address] = data[ 7: 0];

	 // If fail on mismatch
	 if(FAIL_ON_MISMATCH != 0) begin
	    if(buffer[write_address] != expect_buffer[write_address]) begin
	       assert(buffer[write_address] == expect_buffer[write_address]);
	       $display("Failed on write to address %x. Expected: %x, Found: %x", write_address, expect_buffer[write_address], buffer[write_address]);
	       $finish;
	    end
	 end

	 write_address++;
      endfunction // burst_write_byte

      function void burst_write_word(input logic[31:0] data);
	 if(BYTE_ORDER == "MSB") begin
	    burst_write_byte(.data(data[ 7: 0]));
	    burst_write_byte(.data(data[15: 8]));
	    burst_write_byte(.data(data[23:16]));
	    burst_write_byte(.data(data[31:24]));
	 end else begin
	    burst_write_byte(.data(data[31:24]));
	    burst_write_byte(.data(data[23:16]));
	    burst_write_byte(.data(data[15: 8]));
	    burst_write_byte(.data(data[ 7: 0]));
	 end // else: !if(BYTE_ORDER == "MSB")
      endfunction // burst_write_word

      /***********************************************************************
       * Burst write expectation functions
       ***********************************************************************/
      function void burst_write_expect_byte(input logic [7:0] data);
	 expect_buffer[write_expect_address++] = data[ 7: 0];
      endfunction // burst_write_expect_byte

      function void burst_write_expect_word(input logic[31:0] data);
	 if(BYTE_ORDER == "MSB") begin
	    burst_write_expect_byte(.data(data[ 7: 0]));
	    burst_write_expect_byte(.data(data[15: 8]));
	    burst_write_expect_byte(.data(data[23:16]));
	    burst_write_expect_byte(.data(data[31:24]));
	 end else begin
	    burst_write_expect_byte(.data(data[31:24]));
	    burst_write_expect_byte(.data(data[23:16]));
	    burst_write_expect_byte(.data(data[15: 8]));
	    burst_write_expect_byte(.data(data[ 7: 0]));
	 end // else: !if(BYTE_ORDER == "MSB")
      endfunction // burst_write_expect_word

      /***********************************************************************
       * Burst read functions
       ***********************************************************************/
      function logic [7:0] burst_read_byte;
	 burst_read_byte[ 7: 0] = buffer[read_address++];
      endfunction // burst_read_byte

      function logic[31:0] burst_read_word;
	 if(BYTE_ORDER == "MSB") begin
	    burst_read_word[ 7: 0] = burst_read_byte();
	    burst_read_word[15: 8] = burst_read_byte();
	    burst_read_word[23:16] = burst_read_byte();
	    burst_read_word[31:24] = burst_read_byte();
	 end else begin
	    burst_read_word[31:24] = burst_read_byte();
	    burst_read_word[23:16] = burst_read_byte();
	    burst_read_word[15: 8] = burst_read_byte();
	    burst_read_word[ 7: 0] = burst_read_byte();
	 end // else: !if(BYTE_ORDER == "MSB")
      endfunction // burst_read_word


      /////////////////////////////////////////////////////////////////////////
      // Addressed functionality
      /////////////////////////////////////////////////////////////////////////
      /***********************************************************************
       * Expectation functions for establishing what should be written to the
       * buffer region and what should be read.
       ***********************************************************************/
      function void write_expect_byte(input logic [ADDR_WIDTH-1:0] addr, input logic [7:0] data);
	 expect_buffer[addr] = data[ 7: 0];
      endfunction // write_expect_byte

      function void write_expect_word(input logic [ADDR_WIDTH-1:0] addr, input logic [31:0] data);
	 if(BYTE_ORDER == "MSB") begin
	    write_expect_byte(.addr(addr  ), .data(data[ 7: 0]));
	    write_expect_byte(.addr(addr+1), .data(data[15: 8]));
	    write_expect_byte(.addr(addr+2), .data(data[23:16]));
	    write_expect_byte(.addr(addr+3), .data(data[31:24]));
	 end else begin
	    write_expect_byte(.addr(addr+3), .data(data[ 7: 0]));
	    write_expect_byte(.addr(addr+2), .data(data[15: 8]));
	    write_expect_byte(.addr(addr+1), .data(data[23:16]));
	    write_expect_byte(.addr(addr  ), .data(data[31:24]));
	 end // else: !if(BYTE_ORDER == "MSB")
      endfunction // write_expect_word

      function logic [7:0] read_expect_byte(input logic [ADDR_WIDTH-1:0] addr);
	 return expect_buffer[addr];
      endfunction // read_expect_byte

      function logic[31:0] read_expect_word(input logic [ADDR_WIDTH-1:0] addr);
	 logic [31:0] retval;
	 if(BYTE_ORDER == "MSB") begin
	    retval [ 7: 0] = read_expect_byte(.addr(addr  ));
	    retval [15: 8] = read_expect_byte(.addr(addr+1));
	    retval [23:16] = read_expect_byte(.addr(addr+2));
	    retval [31:24] = read_expect_byte(.addr(addr+3));
	 end else begin
	    retval [ 7: 0] = read_expect_byte(.addr(addr  ));
	    retval [15: 8] = read_expect_byte(.addr(addr+1));
	    retval [23:16] = read_expect_byte(.addr(addr+2));
	    retval [31:24] = read_expect_byte(.addr(addr+3));
	 end // else: !if(BYTE_ORDER == "MSB")
	 return retval;
      endfunction // read_expect_word

      /***********************************************************************
       * Functions for writing to the memory region
       ***********************************************************************/
      function void write_byte(input logic [ADDR_WIDTH-1:0] addr, input logic [7:0] data);
	 buffer[addr] = data;

	 if(FAIL_ON_MISMATCH != 0) begin
	    assert(buffer[addr] == expect_buffer[addr]);
	 end
      endfunction // write_byte

      function void write_word(input logic [ADDR_WIDTH-1:0] addr, input logic [31:0] data);
	 if(BYTE_ORDER == "MSB") begin
	    write_byte(.addr(addr  ), .data(data[ 7: 0]));
	    write_byte(.addr(addr+1), .data(data[15: 8]));
	    write_byte(.addr(addr+2), .data(data[23:16]));
	    write_byte(.addr(addr+3), .data(data[31:24]));
	 end else begin
	    write_byte(.addr(addr+3), .data(data[ 7: 0]));
	    write_byte(.addr(addr+2), .data(data[15: 8]));
	    write_byte(.addr(addr+1), .data(data[23:16]));
	    write_byte(.addr(addr  ), .data(data[31:24]));
	 end // else: !if(BYTE_ORDER == "MSB")
      endfunction // write_word

      /***********************************************************************
       * Functions for reading from the memory region
       ***********************************************************************/
      function logic [7:0] read_byte(input logic [ADDR_WIDTH-1:0] addr);
	 return buffer[addr];
      endfunction // read_byte

      function logic[31:0] read_word(input logic [ADDR_WIDTH-1:0] addr);
	 logic [31:0] retval;
	 if(BYTE_ORDER == "MSB") begin
	    retval [ 7: 0] = read_byte(.addr(addr  ));
	    retval [15: 8] = read_byte(.addr(addr+1));
	    retval [23:16] = read_byte(.addr(addr+2));
	    retval [31:24] = read_byte(.addr(addr+3));
	 end else begin
	    retval [ 7: 0] = read_byte(.addr(addr  ));
	    retval [15: 8] = read_byte(.addr(addr+1));
	    retval [23:16] = read_byte(.addr(addr+2));
	    retval [31:24] = read_byte(.addr(addr+3));
	 end // else: !if(BYTE_ORDER == "MSB")
      endfunction // read_word

   endclass // mem_model
endpackage // mem_pkg
