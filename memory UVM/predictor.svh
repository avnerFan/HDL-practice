class predictor extends uvm_agent;
  `uvm_component_utils(predictor)
  
  logic [WIDTH - 1: 0] verif_mem [0: LENGTH - 1];
  mem_op predicted_data = new();
  
  uvm_put_port #(mem_op) predictor_2_comparator_port;
  uvm_tlm_analysis_fifo #(mem_op) obs_fifo;
  
  function new(string name = "predictor", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    predictor_2_comparator_port = new("predictor_2_comparator_port", this);
    obs_fifo = new("obs_fifo", this);
  endfunction : build_phase
  
  task run_phase (uvm_phase phase);
    mem_op cln;
    mem_op d_transaction;
    forever begin
      obs_fifo.get(d_transaction);
      if (d_transaction.write && d_transaction.enable) begin
        verif_mem[d_transaction.address] = d_transaction.data_reg;
      end
      else if (~d_transaction.write && d_transaction.enable) begin  //actualy need to send only address and data
        predicted_data.address = d_transaction.address;
        predicted_data.data_reg = verif_mem[d_transaction.address];
        predicted_data.write = d_transaction.write;
        predicted_data.enable = d_transaction.enable;
        $cast(cln, predicted_data.clone());
        predictor_2_comparator_port.put(cln);
      end
    end 
  endtask : run_phase
endclass : predictor
