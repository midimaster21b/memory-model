import mem_pkg::*;

module mem_model_smoke_tb;

   logic aclk     = 0;
   logic aresetn  = 0;

   mem_model #(.FAIL_ON_MISMATCH(1)) u_mem = new();

   ////////////////////////////////////////////
   // Testbench basics
   ////////////////////////////////////////////
   // Clock signal control
   always #5 aclk = ~aclk;

   // Deassert reset signal
   initial #100 aresetn = 1'b1;


   initial begin
      wait(aresetn == 1'b1);

      /////////////////////////////////////////////////////////////////////////
      // Test specific memory
      /////////////////////////////////////////////////////////////////////////
      // Write expected
      u_mem.write_expect_word(.addr(32'h100), .data(32'hABCD1234));
      u_mem.write_expect_word(.addr(32'h104), .data(32'hAABBCCDD));

      // Write test
      u_mem.write_word(.addr(32'h100), .data(32'hABCD1234)); // Correct

      // Test specific memory failure
      u_mem.write_word(.addr(32'h104), .data(32'h12345678)); // Wrong

      /////////////////////////////////////////////////////////////////////////
      // Test streaming/burst memory
      /////////////////////////////////////////////////////////////////////////
      // Write expected
      u_mem.burst_write_expect_addr(32'h200);
      u_mem.burst_write_expect_word(32'h33445566);
      u_mem.burst_write_expect_word(32'h11223344);

      // Test streaming/burst
      u_mem.burst_write_addr(32'h200);
      u_mem.burst_write_word(32'h33445566); // Correct

      // Test streaming/burst failure
      u_mem.burst_write_word(32'h12345678); // Wrong

      #100;

      $finish;
   end

endmodule // mem_model_smoke_tb
