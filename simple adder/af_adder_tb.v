module af_adder_tb ();
  
  reg  [3:0] in_a, in_b;
  reg        enable, clock, reset;
  
  wire [3:0] sum;
  
  reg  [3:0] ref_sum;
  reg  [3:0] temp_ref_sum;
  
  // adder instantiation
  af_adder #(
    .WIDTH(4)
  ) dut (
    .in_a(in_a),
    .in_b(in_b),
    .enable(enable),
    .clock(clock),
    .reset(reset),
    .sum(sum)
  );
  
  // main test
  initial begin
    
    #20 -> reset_en;
    @ (reset_done);
    #20;
    
    fork
      
      repeat (10) begin
        @ (negedge clock);
        in_a = $random;
      end
      
      repeat (10) begin
        @ (negedge clock);
        in_b = $random;
      end
      
      repeat (10) begin
        @ (negedge clock);
        enable = $random;
      end
      
    join
    
    -> terminate_sim;
    
  end
  
  //predictor
  always @(posedge clock) begin
    
    if (reset) begin
      temp_ref_sum <= 4'b0000;
      
    end else begin
      if (enable) begin
        temp_ref_sum <= in_a + in_b;
      end
    end
  end // always
  
  always @(posedge clock) begin
    if (reset) begin
      ref_sum <= 4'b0000;
    end else begin
      ref_sum <= temp_ref_sum;
    end
  end
  
  //comparator
  always @(posedge clock) begin
    if (ref_sum != sum) begin
      $display ("DUT Error at time %d", $time);
      $display ("Expected sum $d, simulated sum %d", ref_sum, sum);
    end
  end
  
  // clock generator
  initial begin         
    clock = 0;
    #10 forever #10 clock = ~clock;
  end
   
  // reset assertion
  event reset_en;
  event reset_done;
  initial begin
    forever begin
      @ reset_en;
      @ (negedge clock);
      reset = 1;
      @ (negedge clock);
      reset = 0;
      -> reset_done;
    end
  end 
  
  // finish assertion
  event terminate_sim;
  initial begin
    @ terminate_sim;
    #20 $finish;
  end
  
  
  initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
  end
  
  // monitor
  initial begin
    $display ("\t  \ttime \t clock \t reset \t enable  in_a \t in_b \t sum");
    $monitor ("%d \t %b \t %b \t %b \t %d \t %d \t %d", $time, clock, reset, enable, in_a, in_b, sum);
  end  
  
endmodule // af_adder_tb
