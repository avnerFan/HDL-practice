//------------------------------------------------------------------------------
// Module: af_memory
// Description: Parameterized synchronous memory with separate read/write control.
//              Supports configurable word and memory size. On reset, all memory
//              locations are initialized to all 1s. Read data is registered.
// Parameters:
//   WORD_LENGTH   - Width of each memory word (default: 8)
//   MEMORY_LENGTH - Number of memory entries (default: 8)
//------------------------------------------------------------------------------

module af_memory #(
  parameter                              WORD_LENGTH   = 8,
  parameter                              MEMORY_LENGTH = 8
) (
  input                                  clk,
  input                                  enable,
  input                                  rd_wr,
  input                                  rst,                // sync active high reset                
  
  input   [$clog2(MEMORY_LENGTH) - 1: 0] addr,
  input   [WORD_LENGTH - 1: 0          ] wr_data,
  
  output  [WORD_LENGTH - 1: 0          ] rd_data
);
  
  integer                                i;
  
  reg     [WORD_LENGTH - 1: 0          ] memo_out;
  reg     [WORD_LENGTH - 1: 0          ] out_temp;
  reg     [WORD_LENGTH - 1: 0          ] memo [0:MEMORY_LENGTH - 1];
  
  assign rd_data = rd_wr ? out_temp: {WORD_LENGTH{1'bz}};
     
  always @(posedge clk) begin
    if (rst) begin
      memo_out <= {WORD_LENGTH{1'b1}};
      for (i = 0; i < MEMORY_LENGTH; i = i + 1) begin
        memo[i] <= {WORD_LENGTH{1'b1}};
        
      end
      
    end else if (enable) begin
      if (rd_wr) begin // read
        memo_out <= memo[addr];
        
      end else begin  // write
        memo[addr] <= wr_data;
      end
       
    end
    
  end // always
  
  always @(posedge clk) begin
    if (rst) begin 
      out_temp <= {WORD_LENGTH{1'b1}};
      
    end else begin
      out_temp <= memo_out;
      
    end
    
  end // always
  
endmodule
