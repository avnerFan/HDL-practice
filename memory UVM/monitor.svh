class monitor extends uvm_agent;
  `uvm_component_utils(monitor)
  virtual interface memory_if mif;
    
  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
    uvm_analysis_port #(mem_op) ap_monitor_to_predictor;
    uvm_analysis_port #(mem_op) ap_monitor_to_comparator;
    
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mif = memory_pkg::global_mif;
    ap_monitor_to_predictor = new("ap_monitor_to_predictor", this);
    ap_monitor_to_comparator = new("ap_monitor_to_comparator",this);
  endfunction : build_phase
    
  task run_phase(uvm_phase phase);
    mem_op monitor_data = new(), c_monitor_data;
    forever begin
      @(posedge mif.clock);
      #1;
      monitor_data.data_reg = mif.data_bus;
      monitor_data.address = mif.address;
      monitor_data.write = mif.write;
      monitor_data.enable = mif.enable;
      $cast(c_monitor_data, monitor_data.clone());
      if (mif.write)
        ap_monitor_to_predictor.write(c_monitor_data);
      else begin
        ap_monitor_to_predictor.write(c_monitor_data);
        ap_monitor_to_comparator.write(c_monitor_data);
      end
    end
  endtask
endclass
