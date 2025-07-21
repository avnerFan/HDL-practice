class driver extends uvm_agent;
  `uvm_component_utils(driver)
  virtual interface memory_if mif;
  
    function new(string name = "driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new
    
    uvm_get_port #(mem_op) driver_2_dut_port;
    
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mif = memory_pkg::global_mif;
      driver_2_dut_port = new("driver_2_dut_port", this);
    endfunction : build_phase 
    
    task run_phase(uvm_phase phase);
      mem_op req;
      forever begin 
        @(negedge mif.clock);
        mif.write = 0;
        mif.enable = 0;
        if (driver_2_dut_port.try_get(req)) begin
          mif.wr_data_reg = req.data_reg;
          mif.address = req.address;
          mif.write = req.write;
          mif.enable = req.enable;
        end
      end
      
    endtask 
    
endclass : driver
