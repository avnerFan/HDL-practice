class test_env extends uvm_env;
  
  `uvm_component_utils(test_env)
  
  driver drv;
  tester tst;
  monitor mnt;
  predictor prd;
  comparator cmpr;
  coverage cov;
  uvm_tlm_fifo #(mem_op) tester2driver_fifo;
  //predictor-comparartor tlm fifo
  uvm_tlm_fifo #(mem_op) predictor2comparator_fifo;
  
  function new(string name = "test_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    drv = driver::type_id::create("drv", this);
    tst = tester::type_id::create("tst",this);
    mnt = monitor::type_id::create("mnt",this);
    prd = predictor::type_id::create("prd", this);
    cmpr = comparator::type_id::create("cmpr", this);
    cov = coverage::type_id::create("cov",this);
    tester2driver_fifo = new("tester2driver_fifo");
    predictor2comparator_fifo = new("predictor2comparator_fifo");
    // observe ports
  endfunction : build_phase
  
  virtual function void connect_phase(uvm_phase phase);
    //observe ports
    tst.tester_2_driver_port.connect(tester2driver_fifo.put_export);
    drv.driver_2_dut_port.connect(tester2driver_fifo.get_export);
    prd.predictor_2_comparator_port.connect(predictor2comparator_fifo.put_export);
    cmpr.comparator_2_predictor_port.connect(predictor2comparator_fifo.get_export);
    mnt.ap_monitor_to_predictor.connect(prd.obs_fifo.analysis_export);
    mnt.ap_monitor_to_comparator.connect(cmpr.obs_fifo.analysis_export);
    mnt.ap_monitor_to_predictor.connect(cov.obs_fifo.analysis_export);
  endfunction : connect_phase
  
endclass : test_env
