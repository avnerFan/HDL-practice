class tester extends uvm_agent;
  `uvm_component_utils(tester)
  
  uvm_put_port #(mem_op) tester_2_driver_port;
  
  function new(string name = "tester", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  virtual function void build_phase (uvm_phase phase);
    tester_2_driver_port = new("tester_2_driver_port", this);
  endfunction : build_phase
  
  task run_phase (uvm_phase phase);
    mem_op cln;
    mem_op mem_req = new();
    
    phase.raise_objection(this);
    
    for (int i = 0; i < 1000; i++) begin
      mem_req.randomize();
      //mem_req.data_reg = i;
      //mem_req.address = i;
      //mem_req.write = 1;
      //mem_req.enable = 1;
      $cast(cln, mem_req.clone);
      tester_2_driver_port.put(cln);
      //tester_2_driver_port.put(mem_req);
    end
    
    //for (int i = 0; i < LENGTH; i++) begin
      //mem_req.randomize();
      //mem_req.data_reg = i;
      //mem_req.address = i;
      //mem_req.write = 0;
      //mem_req.enable = 1;
      //$cast(cln, mem_req.clone);
      //tester_2_driver_port.put(cln);
      //tester_2_driver_port.put(mem_req);
    //end
    
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : tester
