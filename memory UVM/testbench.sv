//------------------------------------------------------------------------------
// Module: top
// Description: Top-level SystemVerilog testbench for memory DUT using UVM.
//
//              Responsibilities:
//                - Instantiates DUT and interface
//                - Binds interface to DUT
//                - Makes interface globally available to UVM components
//                - Kicks off the UVM test ("memory_tst")
//                - Dumps waveforms for debugging
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
`include "memory_pkg.svh"

module top;

  // Import UVM and testbench package definitions
  import uvm_pkg::*;
  import memory_pkg::*;
  
  // Interface instantiation (shared between DUT and testbench)
  memory_if mi();

  // DUT instantiation, bound to interface modport
  memory dut(mi.mem_mp);
  
  // Main test run: set global interface and start UVM test
  initial begin
    memory_pkg::global_mif = mi;      // provide interface to UVM components
    run_test("memory_tst");           // run test defined in memory_pkg
  end
  
  // Waveform dumping for debugging
  initial begin
    $dumpvars(0, top);
  end
  
endmodule : top
