//TODO: define a class that will be the parent of class mem_op in order to send to the comparator only //the information needed for the comparison. (or use sequence item)

// interface
interface memory_if #(
  parameter WIDTH = 32,
  parameter LENGTH = 32
);
  logic  [WIDTH - 1: 0]          data_bus;
  logic  [WIDTH - 1: 0]          mem_data_out;
  logic  [WIDTH - 1: 0]          wr_data_reg;  
  logic  [$clog2(LENGTH) - 1: 0] address;
  logic                          clock;
  logic                          write;
  logic                          enable;
  
  assign data_bus = (write && enable) ? wr_data_reg : (~write && enable) ? mem_data_out : {WIDTH{1'bz}};
  
  //clock generation
  initial begin 
    clock = 0;
    forever begin
      #5 clock = ~clock;
    end
  end
  
  //direction definition
  modport mem_mp (
    inout   data_bus,
    output  mem_data_out,
    input   address,
    input   clock,
    input   write,
    input   enable
  );
  
  modport tester_mp (
    output  wr_data_reg,
    output  address,
    input   clock,
    output  write,
    output  enable
  );
  
endinterface : memory_if

//main module
module memory #(
  //parameters
  parameter LENGTH   = 32,
  parameter WIDTH    = 32
)(
  memory_if.mem_mp m
);
  
  //internal variables
  logic [WIDTH - 1: 0] memo [0 : LENGTH - 1];
  
  //logic
  always @ (posedge m.clock) begin
    if (m.write && m.enable) begin
      memo[m.address] <=  m.data_bus;
    end
    else if (~m.write && m.enable) begin
      m.mem_data_out <= memo[m.address];
    end
  end
endmodule : memory
