//------------------------------------------------------------------------------
// Class: predictor
// Description: UVM predictor that maintains a reference memory model
//              and generates predicted read data for comparison.
//
//              - Receives observed transactions from the monitor via obs_fifo.
//              - Updates its internal reference memory for write operations.
//              - For read operations, generates expected data and sends it
//                to the comparator through predictor_2_comparator_port.
//------------------------------------------------------------------------------
class predictor extends uvm_agent;

  // Register this class with the UVM factory
  `uvm_component_utils(predictor)
 
//-- Ports and internal variables
 
  // Reference model of memory used for prediction
  logic [WIDTH - 1: 0] verif_mem [0: LENGTH - 1];

  // Temporary transaction used for predicted data
  mem_op predicted_data = new();
  
  // TLM ports:
  // - predictor_2_comparator_port: sends predicted transactions to comparator
  // - obs_fifo: receives observed transactions from monitor
  uvm_put_port #(mem_op) predictor_2_comparator_port;
  uvm_tlm_analysis_fifo #(mem_op) obs_fifo;
  
//-- Constructor

  function new(string name = "predictor", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
//-- Build phase

  //create TLM ports
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    predictor_2_comparator_port = new("predictor_2_comparator_port", this);
    obs_fifo = new("obs_fifo", this);
  endfunction : build_phase
  
//-- Run phase

  // - Waits for transactions from the monitor (via obs_fifo).
  // - On write: updates the reference memory.
  // - On read: generates expected transaction with predicted data,
  //            then sends it to the comparator for checking.
  task run_phase (uvm_phase phase);
    mem_op cln;
    mem_op d_transaction;
    forever begin
      // Blocking get from FIFO (waits for monitor transaction)
      obs_fifo.get(d_transaction);

      if (d_transaction.write && d_transaction.enable) begin
        // WRITE: update reference memory model
        verif_mem[d_transaction.address] = d_transaction.data_reg;
      end
      else if (~d_transaction.write && d_transaction.enable) begin
        // READ: generate expected result from reference memory
        predicted_data.address  = d_transaction.address;
        predicted_data.data_reg = verif_mem[d_transaction.address];
        predicted_data.write    = d_transaction.write;
        predicted_data.enable   = d_transaction.enable;

        // Clone before sending to comparator
        $cast(cln, predicted_data.clone());
        predictor_2_comparator_port.put(cln);
      end
    end 
  endtask : run_phase

endclass : predictor
