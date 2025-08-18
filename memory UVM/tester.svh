//------------------------------------------------------------------------------
// Class: tester
// Description: UVM agent responsible for generating and sending memory
//              transactions to the driver.
//
//              Responsibilities:
//                - Randomizes and creates memory requests (mem_op)
//                - Sends transactions to the driver through a put_port
//                - Raises/lowers phase objection to control simulation run time
//
// Notes:
//   - Currently generates 1000 randomized memory operations
//   - Contains commented-out code for directed write/read sequences
//------------------------------------------------------------------------------
class tester extends uvm_agent;

  // Register with UVM factory
  `uvm_component_utils(tester)
  
  // Port to send transactions to driver
  uvm_put_port #(mem_op) tester_2_driver_port;
  
  //--------------------------------------------------------------------------
  // Constructor
  //--------------------------------------------------------------------------
  function new(string name = "tester", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  //--------------------------------------------------------------------------
  // Build Phase
  // Description: Allocate put_port for driver connection
  //--------------------------------------------------------------------------
  virtual function void build_phase (uvm_phase phase);
    tester_2_driver_port = new("tester_2_driver_port", this);
  endfunction : build_phase
  
  //--------------------------------------------------------------------------
  // Run Phase
  // Description:
  //   - Raises objection to keep simulation alive
  //   - Generates and randomizes memory requests
  //   - Clones and sends them to driver
  //   - Drops objection when finished
  //--------------------------------------------------------------------------
  task run_phase (uvm_phase phase);
    mem_op cln;
    mem_op mem_req = new();
    
    // Keep simulation alive while generating traffic
    phase.raise_objection(this);
    
    // Example stimulus: 1000 randomized requests
    for (int i = 0; i < 1000; i++) begin
      mem_req.randomize();
      $cast(cln, mem_req.clone);  // clone transaction
      tester_2_driver_port.put(cln);
    end
    
    // Uncomment for directed sequences:
    //  - Writes with increasing data/address
    //  - Reads with predictable address/data mapping
    //
    // for (int i = 0; i < LENGTH; i++) begin
    //   mem_req.data_reg = i;
    //   mem_req.address  = i;
    //   mem_req.write    = 1;  // write op
    //   mem_req.enable   = 1;
    //   $cast(cln, mem_req.clone);
    //   tester_2_driver_port.put(cln);
    // end
    
    // Done generating stimulus
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : tester
