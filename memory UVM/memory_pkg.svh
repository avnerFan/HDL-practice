//------------------------------------------------------------------------------
// Package: memory_pkg
// Description: This package contains all the UVM components and related files
//              for the memory verification environment. It serves as a central
//              include point for sequence items, drivers, monitors, predictors,
//              comparators, coverage, and the test environment.
//
//              The package also declares a global virtual interface handle
//              that can be shared across agents and components for driving
//              and monitoring DUT signals.
//------------------------------------------------------------------------------

package memory_pkg;

  // Import UVM library
  import uvm_pkg::*;

//-- Parameters

  parameter WIDTH = 32;  // Width of memory data bus
  parameter LENGTH = 32; // Number of memory locations

//-- Include UVM macros and component files

  `include "uvm_macros.svh"
  `include "mem_op.svh"
  `include "tester.svh"
  `include "driver.svh"
  `include "monitor.svh"
  `include "predictor.svh"
  `include "comparator.svh"
  `include "coverage.svh"
  `include "test_env.svh"
  `include "memory_tst.svh"

//-- Global Virtual Interface

  // Shared virtual interface handle for the memory interface.
  // All components can bind to this to drive or monitor signals.
  virtual interface memory_if global_mif;

endpackage : memory_pkg
