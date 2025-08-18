// TODO: Define a parent class for mem_op if needed
//        The idea is to send to the comparator only the subset of fields
//        required for comparison (instead of the full mem_op).
//        Alternatively, mem_op can extend uvm_sequence_item directly.

//------------------------------------------------------------------------------
// Interface: memory_if
// Description: Provides a parameterized interface to connect a memory DUT
//              with testbench components. It defines signals for memory
//              operations, bus behavior, clock generation, and modports
//              for DUT and testbench sides.
//------------------------------------------------------------------------------
interface memory_if #(
  parameter WIDTH  = 32,   // Data width
  parameter LENGTH = 32    // Address space length
);

  //-- Signals
  logic  [WIDTH - 1: 0]          data_bus;     // Bi-directional data bus
  logic  [WIDTH - 1: 0]          mem_data_out; // DUT -> output data
  logic  [WIDTH - 1: 0]          wr_data_reg;  // Testbench -> write data
  logic  [$clog2(LENGTH) - 1: 0] address;      // Address lines
  logic                          clock;        // Clock signal
  logic                          write;        // Write enable (1=write, 0=read)
  logic                          enable;       // Operation enable

  //-- Data bus behavior
  // Drive write data during write operations,
  // drive memory output during read operations,
  // otherwise set bus to high impedance.
  assign data_bus = (write && enable)   ? wr_data_reg :
                    (~write && enable) ? mem_data_out :
                                         {WIDTH{1'bz}};
  
  //-- Clock generation
  // Generates a free-running clock with 10 time units period.
  initial begin 
    clock = 0;
    forever begin
      #5 clock = ~clock;
    end
  end
  
  //-- Modports
  // Define directional access for DUT and tester (driver/sequencer)
  
  // DUT-side modport (DUT reads/writes signals)
  modport mem_mp (
    inout   data_bus,
    output  mem_data_out,
    input   address,
    input   clock,
    input   write,
    input   enable
  );
  
  // Testbench-side modport (driver/tester controls signals)
  modport tester_mp (
    output  wr_data_reg,
    output  address,
    input   clock,
    output  write,
    output  enable
  );
  
endinterface : memory_if


//------------------------------------------------------------------------------
// Module: memory
// Description: Simple synchronous memory model.
//              Implements a memory array that supports read and write
//              operations driven by the memory_if interface.
//------------------------------------------------------------------------------
module memory #(
  // Parameters
  parameter LENGTH   = 32, // Memory depth
  parameter WIDTH    = 32  // Memory word width
)(
  memory_if.mem_mp m       // Interface connection (DUT modport)
);
  
  //-- Internal variables
  // Memory array: LENGTH words, each WIDTH bits wide
  logic [WIDTH - 1:0] memo [0:LENGTH-1];
  
  //-- Memory behavior
  // On rising clock edge:
  //   - If write+enable -> store data_bus into memory
  //   - Else if read+enable -> drive mem_data_out with memory contents
  always @ (posedge m.clock) begin
    if (m.write && m.enable) begin
      memo[m.address] <= m.data_bus;
    end
    else if (~m.write && m.enable) begin
      m.mem_data_out <= memo[m.address];
    end
  end

endmodule : memory


