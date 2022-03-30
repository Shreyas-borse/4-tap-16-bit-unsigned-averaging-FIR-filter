// Finite Impulse Filter, two's complement data
// Computes weighted average of N most recent samples
//   of a signal.
// Version #1: no rescaling
module FIRC(
  input signed[7:0] xIn,
  input clk,
  output logic signed[15:0] yOutC);
  
logic signed[15:0] ad;
logic signed[ 7:0] xQ [7];  // registered incoming data -- tapped delay line
logic signed[15:0] p  [7];  // intermediate products
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
// sliding history of most recent inputs -- shift reg
always @(posedge clk) begin
  xQ[0] <= xIn;				  // bring in newest data sample
  for(int i=1; i<7; i++)	  
    xQ[i] <= xQ[i-1];		  // move the others along by one tap each
end  
// multipliers  
always_comb
  for(int j=0; j<7; j++)
    p[j] = xQ[j] * h[j];
// big adder tree, also combinational      
always_comb begin
  ad = 0;
  for(int k=0; k<7; k++)
    ad = ad + p[k];
end  

always @(posedge clk)
  yOutC <= ad;                // register the output
// What's wrong?
//  1) output delay (clock to Q)    
//  2) output scaling   
endmodule

// test bench
module tb_fir;
  
bit               clk;
bit signed [ 7:0] xIn;// = 64;
wire signed[15:0] yOutC, yOutT, yOutH;  

FIRC c1(.*);  				   // instantiate DUT
FIRT t1(.*);
FIRH h1(.*);

always begin
 #5ns clk = 1;
 #5ns clk = 0;
end

initial begin
  #200ns xIn = 64;	           // inject 1-clock impulse
  #10ns  xIn = 0;
  #500ns $stop;
end 
  
endmodule