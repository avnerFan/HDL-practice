//------------------------------------------------------------------------------
// Class: memory_tst
// Description: UVM test that instantiates the test environment (test_env).
//              This test serves as an entry point for running memory-related
//              verification. It relies on the environment to connect and
//              configure driver, comparator, and other UVM components.
//------------------------------------------------------------------------------
class memory_tst extends uvm_test;
  
  // Register this class with the UVM factory
  `uvm_component_utils(memory_tst)

  // Environment instance
  test_env t_env;
    
  //-- Constructor
  // Initializes the test with its name and parent
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
    
  //-- Build phase
  // Creates the test environment (t_env) using the factory
  virtual function void build_phase(uvm_phase phase);
    t_env = test_env::type_id::create("t_env", this);
  endfunction : build_phase
  
endclass : memory_tst
