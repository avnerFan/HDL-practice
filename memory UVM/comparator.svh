//------------------------------------------------------------------------------
// Class: comparator
// Description: This UVM agent compares observed memory operations against
//              predicted values to verify memory component behavior.
//
//              It receives actual memory operations via an analysis FIFO
//              and predicted operations via a get port. On a read operation,
//              it compares both and reports mismatches.
//------------------------------------------------------------------------------

class comparator extends uvm_agent;

  // Register this class with the UVM factory
  `uvm_component_utils(comparator)
  
//-- Ports and internal variables

  // Get port to receive predicted memory operations (from predictor)
  uvm_get_port #(mem_op) comparator_2_predictor_port;
  
  // Analysis FIFO to receive observed memory operations (from monitor)
  uvm_tlm_analysis_fifo #(mem_op) obs_fifo;

  // Variables to store the actual and predicted responses
  mem_op actual_rsp, predicted_rsp;
  
//-- Constructor

  // Initializes the component with optional name and parent
  function new(string name = "comparator", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new
 
//-- Build phase

  // Constructs ports and analysis FIFO 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the get port and analysis FIFO
    comparator_2_predictor_port = new("comparator_2_predictor_port", this);
    obs_fifo = new("obs_fifo", this);
  endfunction : build_phase
 
//-- Run phase

  // Continuously compares actual and predicted memory operations 
  task run_phase(uvm_phase phase);
    forever begin
      // Wait for a memory operation from the observation FIFO
      obs_fifo.get(actual_rsp);

      // Check only read operations that are enabled
      if (~actual_rsp.write && actual_rsp.enable) begin

        // Get predicted response from the predictor
        comparator_2_predictor_port.get(predicted_rsp);

        // Compare the predicted and actual data
        if (!actual_rsp.mem_op_compare(predicted_rsp)) begin
          // Report mismatch as a UVM error
          `uvm_error("Run phase",$sformatf("in address %0d prd data is %0d but act data is %0d",actual_rsp.address,predicted_rsp.data_reg,actual_rsp.data_reg),UVM_LOW);
        end
      end
    end
  endtask
  
endclass : comparator
