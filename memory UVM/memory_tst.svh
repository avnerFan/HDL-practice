class memory_tst extends uvm_test;
  
  `uvm_component_utils(memory_tst)
  test_env t_env;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    
    virtual function void build_phase(uvm_phase phase);
      t_env = test_env::type_id::create("t_env", this);
    endfunction : build_phase
  
endclass : memory_tst
