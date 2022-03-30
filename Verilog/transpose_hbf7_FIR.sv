// transpose Finite Impulse Filter, two's complement data
// Computes weighted average of N most recent samples
//   of a signal.
// Version #1: no rescaling
module FIRT(
  input signed[7:0] xIn,
  input clk,
  output logic signed[15:0] yOutT);
  
logic signed[ 7:0] xQ;      // single register for data in
logic signed[15:0] ad [7];  // registered adder -- tapped delay line
logic signed[15:0] p0;      // first intermediate product 
logic signed[15:0] p  [7];  // intermediate products
logic signed[15:0] pQ [7];  // intermediate product register outputs
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
// capture data input
always @(posedge clk) 
  xQ <= xIn;				  // bring in newest data sample

// multipliers -- as in canonical, except same xQ for all  
always_comb
  p0 = xQ * h[0];

always_comb
  for(int j=1; j<7; j++)
    p[j] = xQ * h[j] + pQ[j-1];

// advance summation delay line
always @(posedge clk)  begin
  pQ[0] <= p0; 
  for(int k=1; k<7; k++) 
    pQ[k] <= p[k];
end

assign yOutT = pQ[6];
    
// What's wrong?
//  1) output delay (clock to Q)    
//  2) output scaling   
endmodule
