//------------------------------------------------------------------------------
// Class: coverage
// Description: This UVM agent is responsible for collecting functional coverage
//              on observed memory operations. It receives transactions via an
//              analysis FIFO and samples a covergroup for each transaction.
//
//              Collected items include write flag, address, enable signal,
//              data value, and cross-coverage between them.
//------------------------------------------------------------------------------

class coverage extends uvm_agent;

  // Register this class with the UVM factory
  `uvm_component_utils(coverage)
  
//-- Ports and internal variables

  // Analysis FIFO to receive observed memory operations (from monitor)
  uvm_tlm_analysis_fifo #(mem_op) obs_fifo;

  // Storage for incoming observed transaction
  mem_op obs_data = new();
  
//-- Covergroup definition

  // Covergroup to collect coverage on memory operations
  covergroup my_cg;
    option.per_instance = 1;

    // Coverpoints on key transaction fields
    coverpoint obs_data.write;
    coverpoint obs_data.address;
    coverpoint obs_data.enable;
    coverpoint obs_data.data_reg;

    // Cross coverage between key control signals
    cross obs_data.write, obs_data.address, obs_data.enable;
  endgroup
  
//-- Constructor

  // Initializes the component and covergroup
  function new(string name = "coverage", uvm_component parent = null);
    super.new(name, parent);
    my_cg = new();
    endfunction : new
  
//-- Build phase

  // Constructs the analysis FIFO
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    obs_fifo = new("obs_fifo", this);
  endfunction : build_phase

//-- Run phase
  
  // Continuously samples the covergroup on incoming transactions
  task run_phase(uvm_phase phase);
    
    forever begin
      // Wait for a memory transaction from the FIFO
      obs_fifo.get(obs_data);

      // Sample the covergroup
      my_cg.sample();
    end
  endtask
  
endclass : coverage
