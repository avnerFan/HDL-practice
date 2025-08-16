//------------------------------------------------------------------------------
// Class: mem_op
// Description: This UVM transaction class represents a memory operation.
//              It encapsulates data, address, write enable, and valid enable
//              signals. It provides methods for comparison and copying
//              transactions between objects.
//------------------------------------------------------------------------------

class mem_op extends uvm_transaction;

  // Register this class with the UVM factory
  `uvm_object_utils(mem_op)
  
  //-- Transaction fields
  
  rand logic  [WIDTH - 1: 0]          data_reg;   // Memory data value (WIDTH bits)
  rand logic  [$clog2(LENGTH) - 1: 0] address;    // Memory address (calculated based on LENGTH)
  rand logic                          write;      // Write flag: 1 for write operation, 0 for read
  rand logic                          enable;     // Enable flag: indicates if the operation is valid
  
  //-- Constructor
  // Initializes the transaction object with an optional name
  function new(string name = "");
    super.new(name);
  endfunction : new
  
  //-- Compare function
  // Returns 1 if all fields of this transaction match another transaction
  function bit mem_op_compare(mem_op op);
    return ((data_reg === op.data_reg) &&
            (address  === op.address) &&
            (write    === op.write) &&
            (enable   === op.enable));
  endfunction : mem_op_compare
  
  //-- Copy function
  // Copies all fields from another mem_op object to this one
  virtual function void do_copy(uvm_object rhs);
    mem_op RHS;
    super.do_copy(rhs);
    $cast(RHS,rhs);    // Cast generic uvm_object to mem_op
    data_reg = RHS.data_reg;
    address  = RHS.address;
    write    = RHS.write;
    enable   = RHS.enable;
  endfunction : do_copy
  
endclass : mem_op
