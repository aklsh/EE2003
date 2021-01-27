// Filename        : seq-mult.v
//
// Description     : Sequential multiplier
// Authors         : Nitin Chandrachoodan, Akilesh Kannan

// This implementation corresponds to a sequential multiplier, but
// most of the functionality is missing.  Complete the code so that
// the resulting module implements multiplication of two numbers in
// twos complement format.

// All the comments marked with *** correspond to something you need
// to fill in.

// This style of modeling is 'behavioural', where the desired
// behaviour is described in terms of high level statements ('if'
// statements in verilog).  This is where the real power of the
// language is seen, since such modeling is closest to the way we
// think about the operation.  However, it is also the most difficult
// to translate into hardware, so a good understanding of the
// connection between the program and hardware is important.

// Constants
`define width 8
`define ctrwidth 4

module seq_mult (
                 // Outputs
                 p, rdy,
                 // Inputs
                 clk, reset, a, b
                );

    // control and clock signals
    input clk, reset;
    output reg rdy;

    // input and output ports
    input [`width-1:0] a, b;
    output reg [2*`width-1:0] p;

    // Register declarations for multiplier, multiplicand
    reg [2*`width-1:0] multiplicand, multiplier;
    reg [`ctrwidth:0] ctr;

    always @(posedge clk or posedge reset) begin
        // check reset - clear everything to 0
        if (reset) begin
            rdy <= 0;                                   // not ready
            p <= 0;                                     // make product 0
            ctr <= 0;                                   // clear counter
            multiplier <= {{`width{a[`width-1]}}, a};   // sign-extend
            multiplicand <= {{`width{b[`width-1]}}, b}; // sign-extend
        end

        // do multiplication
        else begin
            if (ctr < `width<<1) begin
                   /* Logic for sequential multiplication
                    *
                    * Inputs a and b are in twos complement notation
                    *
                    * 1. Set counter and product to 0 initially.
                    * 2. Sign extend a and b to 2*(max(width(a), width(b))) = 2*width_max
                    *       here, a and b are of same width = 8
                    * 3. Set multiplier = sign-extend(a); multiplicand = sign-extend(b)
                    * 4. Do following step for 2*width_max times:
                    *    -  Check value of bit at position (counter) in multiplier:
                    *        = If 0, add 0 to product register.
                    *        = If 1, shift multiplicand left, counter times, and add that to product register.
                    *    - Increment counter
                    * 5. The final product is stored in product register in twos complement notation
                    */
                p <= p + ((multiplier[ctr])?(multiplicand<<ctr):0);
                ctr <= ctr+1;
            end
            else begin
                rdy <= 1; 		// Assert 'rdy' signal to indicate end of multiplication
            end
        end
    end
endmodule // seqmult
