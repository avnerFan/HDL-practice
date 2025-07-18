/* This module implements a synchronous adder that operates on two input values, in_a and in_b, under the control of an enable signal. It receives five inputs: clock, reset, in_a, in_b, and enable. When the enable signal is high, the module adds the values of in_a and in_b, and the result is output as sum on the next rising edge of the clock. If enable is low, the output sum retains its previous value. The reset signal resets the output to a default value (zero).*/

module af_adder #(
  parameter WIDTH = 32
) (
  input      [WIDTH - 1:0] in_a,
  input      [WIDTH - 1:0] in_b,
  input                    enable,
  input                    clock,
  input                    reset,        //sync active high reset
  
  output reg [WIDTH - 1:0] sum
);

  reg        [WIDTH - 1:0] temp_sum;

  always @(posedge clock) begin

    if (reset) begin
      temp_sum <= {WIDTH{1'b0}};

    end else begin
      if (enable) begin
        temp_sum <= in_a + in_b;

      end

    end

  end // always

  always @(posedge clock) begin

    if (reset) begin
      sum <= {WIDTH{1'b0}};

    end else begin
      sum <= temp_sum;

    end

  end // always

endmodule // af_adder
