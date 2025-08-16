//------------------------------------------------------------------------------
// Class: driver
// Description: This UVM agent drives memory operations onto the DUT interface.
//              It receives memory operation requests via a get port and writes
//              them to the virtual memory interface.
//
//              The driver continuously samples the requests and applies them
//              to the interface signals on each clock edge.
//------------------------------------------------------------------------------

class driver extends uvm_agent;

  // Register this class with the UVM factory
  `uvm_component_utils(driver)

  //-- Virtual interface
  // Interface to drive memory signals
  virtual interface memory_if mif;
  
  //-- Constructor
  // Initializes the driver component with optional name and parent
  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
    
  //-- Ports
  // Get port to receive memory operation requests from the sequencer/driver
  uvm_get_port #(mem_op) driver_2_dut_port;
    

  //-- Build phase
  // Constructs ports and binds the global memory interface
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mif = memory_pkg::global_mif;
    driver_2_dut_port = new("driver_2_dut_port", this);
  endfunction : build_phase 
    
  //-- Run phase
  // Continuously drives memory operations onto the interface
  task run_phase(uvm_phase phase);
    mem_op req;  // Temporary variable to store a single memory operation
    forever begin 
      @(negedge mif.clock);  // Synchronize to negative clock edge

      // Clear interface signals
      mif.write  = 0;
      mif.enable = 0;

      // Check if a new request is available from the port
      if (driver_2_dut_port.try_get(req)) begin
        // Drive memory interface signals based on the request
        mif.wr_data_reg = req.data_reg;
        mif.address     = req.address;
        mif.write       = req.write;
        mif.enable      = req.enable;
      end
    end
      
  endtask 
 
endclass : driver
