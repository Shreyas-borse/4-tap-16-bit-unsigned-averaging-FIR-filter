// hybrid Finite Impulse Filter, two's complement data
// Computes weighted average of N most recent samples
//   of a signal.
// Version #1: no rescaling
module FIRH(
  input signed[7:0] xIn,
  input clk,
  output logic signed[15:0] yOutH);
  
logic signed[ 7:0] h  [7];  // coefficients

initial begin                 // specify fixed coefs.
  h[0] = -2;                  //   could also have been variables
  h[1] = 0;
  h[2] = 34;
  h[3] = 64;                  // center of truncated sync function
  h[4] = 34;
  h[5] = 0;                   // half-band filter has zero crossings
  h[6] = -2;                  //   @ all odd-numbered taps except
end                           //  center

logic signed[ 7:0] dinQ[5];
logic signed[15:0] soutQ[5];

always @(posedge clk) begin
  dinQ[0] <= xIn;
  yOutH   <= soutQ[1];
end

stage #(.h0(-2), .h1(0)) s1(.din(dinQ[0]), .sin(soutQ[2]), .clk, .dout(dinQ[1]), .sout(soutQ[1]));
stage #(.h0(34), .h1(64)) s2(.din(dinQ[1]), .sin(soutQ[3]), .clk, .dout(dinQ[2]), .sout(soutQ[2]));
stage #(.h0(34), .h1(0)) s3(.din(dinQ[2]), .sin(soutQ[4]), .clk, .dout(dinQ[3]), .sout(soutQ[3]));
stage #(.h0(-2), .h1(0)) s4(.din(dinQ[3]), .sin(16'b0), .clk, .dout(), .sout(soutQ[4]));

endmodule



module stage #(parameter h0=0, h1=0) (
  input signed[ 7:0] din,
  input signed[15:0] sin,
  input             clk,
  output logic signed[ 7:0] dout,
  output logic signed[15:0] sout);

  always @(posedge clk)	begin
    dout <= din;
	sout <= din*h0 + dout*h1 + sin;
  end


endmodule