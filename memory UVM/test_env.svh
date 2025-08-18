//------------------------------------------------------------------------------
// Class: test_env
// Description: UVM environment that instantiates and connects all verification
//              components needed for the memory DUT testbench.
//
//              Components:
//                - driver: drives DUT signals
//                - tester: generates stimulus
//                - monitor: observes DUT activity
//                - predictor: maintains reference model
//                - comparator: checks DUT output against predicted values
//                - coverage: collects functional coverage
//
//              Communication:
//                - tester <-> driver connected via tester2driver_fifo
//                - predictor <-> comparator connected via predictor2comparator_fifo
//                - monitor broadcasts to predictor, comparator, and coverage
//------------------------------------------------------------------------------
class test_env extends uvm_env;
  
  // Register this class with the UVM factory
  `uvm_component_utils(test_env)
  
  // Environment subcomponents
  driver     drv;
  tester     tst;
  monitor    mnt;
  predictor  prd;
  comparator cmpr;
  coverage   cov;

  // TLM FIFOs for communication
  uvm_tlm_fifo #(mem_op) tester2driver_fifo;
  uvm_tlm_fifo #(mem_op) predictor2comparator_fifo;
  
  // Constructor
  function new(string name = "test_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  // Build phase: create components and FIFOs
  virtual function void build_phase(uvm_phase phase);
    drv  = driver   ::type_id::create("drv",  this);
    tst  = tester   ::type_id::create("tst",  this);
    mnt  = monitor  ::type_id::create("mnt",  this);
    prd  = predictor::type_id::create("prd",  this);
    cmpr = comparator::type_id::create("cmpr",this);
    cov  = coverage ::type_id::create("cov",  this);

    tester2driver_fifo        = new("tester2driver_fifo");
    predictor2comparator_fifo = new("predictor2comparator_fifo");
  endfunction : build_phase
  
  // Connect phase: hook up ports and exports
  virtual function void connect_phase(uvm_phase phase);
    // Tester -> Driver (via FIFO)
    tst.tester_2_driver_port.connect(tester2driver_fifo.put_export);
    drv.driver_2_dut_port.connect(tester2driver_fifo.get_export);

    // Predictor -> Comparator (via FIFO)
    prd.predictor_2_comparator_port.connect(predictor2comparator_fifo.put_export);
    cmpr.comparator_2_predictor_port.connect(predictor2comparator_fifo.get_export);

    // Monitor broadcasts observed transactions
    mnt.ap_monitor_to_predictor.connect(prd.obs_fifo.analysis_export);
    mnt.ap_monitor_to_comparator.connect(cmpr.obs_fifo.analysis_export);
    mnt.ap_monitor_to_predictor.connect(cov.obs_fifo.analysis_export);
  endfunction : connect_phase
  
endclass : test_env
