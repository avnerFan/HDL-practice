// top memory UVM tb

`include "uvm_macros.svh"
`include "memory_pkg.svh"

module top;
  import uvm_pkg::*;
  import memory_pkg::*;
  
  //instantiation
  memory_if mi();
  memory dut(mi.mem_mp);
  
  //main-test run
  initial begin
    memory_pkg::global_mif = mi;
    run_test("memory_tst");
  end
  
  // Dump waves
  initial begin
    $dumpvars(0, top);
  end
  
endmodule //top
