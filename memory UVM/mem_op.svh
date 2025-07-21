class mem_op extends uvm_transaction;
  `uvm_object_utils(mem_op)
  
   rand logic  [WIDTH - 1: 0]          data_reg;
   rand logic  [$clog2(LENGTH) - 1: 0] address;
   rand logic                          write;
   rand logic                          enable;
  
  function new(string name = "");
    super.new(name);
  endfunction : new
  
  function bit mem_op_compare(mem_op op);
    return ((data_reg===op.data_reg) && (address===op.address) && (write===op.write) &&                                 (enable===op.enable));
  endfunction : mem_op_compare
  
  virtual function void do_copy(uvm_object rhs);
    mem_op RHS;
    super.do_copy(rhs);
    $cast(RHS,rhs);
    data_reg = RHS.data_reg;
    address = RHS.address;
    write = RHS.write;
    enable = RHS.enable;
  endfunction : do_copy
  
endclass : mem_op
