module af_memory_tb ();
  
  reg clk, enable, rd_wr, rst;
  reg [7:0] wr_data;
  reg [2:0] addr;
  
  wire [7:0] rd_data;
  
  integer i;
  
  af_memory dut (
    .clk(clk),
    .enable(enable),
    .rd_wr(rd_wr),
    .rst(rst),
    .addr(addr),
    .wr_data(wr_data),
    .rd_data(rd_data)
  );
  
  // main test
  initial begin
    
    #20 -> reset_en;
    @ (reset_done);
    #20;
    
    // default memory value check
    @ (negedge clk);
    mem_read(3'b000);
    
    #20;
    
    // write and read to all memory locations
    for (i = 0; i < 8; i = i + 1) begin
      mem_write (i, i);
      
    end // write for loop
    
    for (i = 0; i < 8; i = i + 1) begin
      mem_read (i);
      
    end // read for loop
    
    #20;
    
    // alternate write and read every cycle with valid enable
    enable = 1;
    for (i = 0; i < 8; i = i + 1) begin
      @ (negedge clk);
      rd_wr = 0;
      addr = i;
      wr_data = i;
      @ (negedge clk);
      rd_wr = ~rd_wr;
      
    end // for loop

    
    
    // reset between write and read
    mem_write(3'b000, 8'h00);
    -> reset_en;
    @ (reset_done);
    mem_read(3'b000);
    
    // random inputs
    repeat (10) begin
      random_mem_op;
    end
    
    @ (negedge clk);
    #20 -> terminate_sim;
    
  end // initial - main test
  
  task mem_write (
    input [2:0] address,
    input [7:0] data   
  );
    
    begin
      @ (negedge clk);
      enable = 1'b1;
      rd_wr = 1'b0;
      addr = address;
      wr_data = data;
      @ (negedge clk);
      enable = 1'b0;
      
    end
    
  endtask // mem_write
  
  task mem_read (
    input [2:0] address
  );
    
    begin
      @ (negedge clk);
      enable = 1'b1;
      rd_wr = 1'b1;
      addr = address;
      @ (negedge clk);
      enable = 1'b0;
    end
    
  endtask // mem_read
  
  task random_mem_op ();
    begin
      @ (negedge clk);
      enable = $random;
      rd_wr = $random;
      addr = $random;
      wr_data = $random;
    end
  endtask // random_mem_op
  
  
  // predictor
  wire [7:0] ref_rd_data;
  reg  [7:0] ref_memo_out;
  reg  [7:0] ref_out_temp;
  reg  [7:0] ref_memo       [0:7];
  
  assign ref_rd_data = rd_wr? ref_out_temp: {8{1'bz}};
  
  always @(posedge clk) begin
    if (rst) begin
      ref_memo_out <= {8{1'b1}};
      for (i = 0; i < 8; i = i + 1) begin
        ref_memo[i] <= {8{1'b1}};
        
      end // for loop
      
    end else if (enable) begin
      if (rd_wr) begin // read
        ref_memo_out <= ref_memo[addr];
        
      end else begin  // write
        ref_memo[addr] <= wr_data;
      end
       
    end // if not rst and enable
    
  end // always
  
  always @(posedge clk) begin
    if (rst) begin 
      ref_out_temp <= {8{1'b1}};
      
    end else begin
      ref_out_temp <= ref_memo_out;
      
    end
    
  end // always
  
  
  
  // comparator
  always @(posedge clk) begin
    if (ref_rd_data != rd_data) begin
      $display ("DUT Error at time %d", $time);
      $display ("Expected rd_data $d, simulated rd_data %d", ref_rd_data, rd_data);
    end
  end
  
  // clock generator
  initial begin         
    clk = 0;
    #10 forever #10 clk = ~clk;
  end
   
  // reset assertion
  event reset_en;
  event reset_done;
  initial begin
    forever begin
      @ reset_en;
      @ (negedge clk);
      rst = 1;
      @ (negedge clk);
      rst = 0;
      -> reset_done;
    end
  end 
  
  // finish assertion
  event terminate_sim;
  initial begin
    @ terminate_sim;
    #20 $finish;
  end
  
  // dump
  initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
  end
  
  // monitor
  initial begin
    $display ("\t  \ttime \t clk \t rst \t enable  addr \t wr_data  rd_data");
    $monitor ("%d \t %b \t %b \t %b \t %d \t %d \t %d", $time, clk, rst, enable, addr, wr_data, rd_data);
  end
  
endmodule
