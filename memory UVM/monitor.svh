//------------------------------------------------------------------------------
// Class: monitor
// Description: UVM monitor that observes DUT signals via the memory interface
//              and broadcasts captured transactions to other components.
//
//              - Collects observed transactions from the memory interface.
//              - Sends transactions to predictor (for expected value generation).
//              - Sends transactions to comparator (for checking read results).
//------------------------------------------------------------------------------
class monitor extends uvm_agent;

  // Register this class with the UVM factory
  `uvm_component_utils(monitor)

  // Virtual interface handle to connect with DUT
  virtual interface memory_if mif;
    
  // Constructor
  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  // Analysis ports:
  // - ap_monitor_to_predictor: forwards transactions to predictor
  // - ap_monitor_to_comparator: forwards transactions to comparator
  uvm_analysis_port #(mem_op) ap_monitor_to_predictor;
  uvm_analysis_port #(mem_op) ap_monitor_to_comparator;
    
  // Build phase: connect virtual interface and create analysis ports
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mif = memory_pkg::global_mif;
    ap_monitor_to_predictor  = new("ap_monitor_to_predictor", this);
    ap_monitor_to_comparator = new("ap_monitor_to_comparator", this);
  endfunction : build_phase
    
  // Run phase:
  // - Continuously samples signals at every positive clock edge.
  // - Captures transaction information into a mem_op object.
  // - Clones the transaction before broadcasting to ensure data integrity.
  // - Sends write transactions only to predictor.
  // - Sends read transactions to both predictor and comparator.
  task run_phase(uvm_phase phase);
    mem_op monitor_data = new(), c_monitor_data;
    forever begin
      @(posedge mif.clock);
      #1; // allow signals to stabilize

      // Capture signals into transaction
      monitor_data.data_reg = mif.data_bus;
      monitor_data.address  = mif.address;
      monitor_data.write    = mif.write;
      monitor_data.enable   = mif.enable;

      // Clone the object before broadcasting
      $cast(c_monitor_data, monitor_data.clone());

      // Send to connected components
      if (mif.write)
        ap_monitor_to_predictor.write(c_monitor_data);
      else begin
        ap_monitor_to_predictor.write(c_monitor_data);
        ap_monitor_to_comparator.write(c_monitor_data);
      end
    end
  endtask

endclass : monitor
