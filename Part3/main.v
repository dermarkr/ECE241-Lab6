//Sw[7:0] data_in

//KEY[0] synchronous reset when pressed
//KEY[1] go signal

//LEDR displays result
//HEX0 & HEX1 also displays result

module main(SW, KEY, CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;

    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire resetn;
    wire go;
	 wire [4:0] divisor;
	 wire [8:0] dividend;
	 wire ld_r, lShift, sub, copy, add;
	 wire [8:0] dividend_out;
	 wire [4:0] divisor_out; 
		
	 wire [5:0] currentstate, nextstate;
    assign go = ~KEY[1];
    assign resetn = KEY[0];
	 
	 assign divisor = {1'b0, SW[3:0]};
	 assign dividend = {5'b00000, SW[7:4]};

control c0(	.clk(CLOCK_50),
				.resetn(resetn),
				.go(go),
				.ld_r(ld_r),
				.lShift(lShift),
				.sub(sub),
				.copy(copy),
				.add(add),
				.current_state(currentstate),
				.next_state(nextstate));
				
datapath d0(.clk(CLOCK_50),
				.resetn(resetn),
				.dividend_in(dividend),
				.divisor_in(divisor),
				.lShift(lShift),
				.sub(sub),
				.copy(copy),
				.add(add),
				.ld_r(ld_r),
				.dividend(dividend_out[8:0]),
				.divisor( divisor_out[3:0])
				); 


    hex_decoder H0(
        .hex_digit(SW[3:0]), 
        .segments(HEX0)
        );
        
    hex_decoder H1(
        .hex_digit(SW[7:4]), 
        .segments(HEX2)
        );
		  
    hex_decoder H2(
        .hex_digit(dividend_out[3:0]), 
        .segments(HEX4)
        );

    hex_decoder H3(
        .hex_digit(dividend_out[7:4]), 
        .segments(HEX5)
        );
		  
    hex_decoder H4(
        .hex_digit('b0000), 
        .segments(HEX1)
        );
		  
    hex_decoder H5(
        .hex_digit('b0000), 
        .segments(HEX3)
        );

endmodule      
                



module datapath(
    input clk,
    input resetn,
    input [8:0] dividend_in,
	 input [4:0] divisor_in,
    input lShift, sub, copy, add,
    input ld_r,
	 output reg [8:0] dividend,
	 output reg [4:0] divisor
    );
    

    
    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            dividend <= 8'b0; 
            divisor <= 5'b0; 
		   end
		   else if(ld_r)
			begin
				dividend <= dividend_in;
				divisor <= divisor_in;   
         end
		   else if(lShift)
				dividend[8:0] <= {dividend[7:0], dividend[8]};
			else if(sub)
				dividend[8:4] <= dividend[8:4] - divisor[4:0];
			else if(copy)
				dividend[0] <= ~dividend[8];
			else if(add)
				dividend[8:4] <= dividend[8:4] + divisor[4:0];				
    end
 

endmodule

module control(
    input clk,
    input resetn,
    input go,
    output reg  ld_r, lShift, sub, copy, add,
	 output reg [5:0] current_state, next_state
    );
    
    localparam  	S_LOAD_Div       	= 6'b000000,
						S_LOAD_Div_Wait  	= 6'b000001,
						S_Shift  	     	= 6'b000010,
						S_Shift_Wait     	= 6'b000011,
						S_Sub		      	= 6'b000100,
						S_Sub_Wait		 	= 6'b000101,
						S_Copy			 	= 6'b000110,
						S_Copy_Wait		 	= 6'b000111,
						S_Add			 		= 6'b001000,
						S_Add_Wait		 	= 6'b001001,
						S_Shift1  	     	= 6'b001010,
						S_Shift_Wait1     = 6'b001011,
						S_Sub1		      = 6'b001100,
						S_Sub_Wait1		 	= 6'b001101,
						S_Copy1			 	= 6'b001110,
						S_Copy_Wait1		= 6'b001111,
						S_Add1			 	= 6'b010000,
						S_Add_Wait1		 	= 6'b010001,
						S_Shift2  	     	= 6'b010010,
						S_Shift_Wait2     = 6'b010011,
						S_Sub2		      = 6'b010100,
						S_Sub_Wait2		 	= 6'b010101,
						S_Copy2			 	= 6'b010110,
						S_Copy_Wait2		= 6'b010111,
						S_Add2			 	= 6'b011000,
						S_Add_Wait2		 	= 6'b011001,
						S_Shift3  	     	= 6'b011010,
						S_Shift_Wait3     = 6'b011011,
						S_Sub3		      = 6'b011100,
						S_Sub_Wait3		 	= 6'b011101,
						S_Copy3			 	= 6'b011110,
						S_Copy_Wait3		= 6'b011111,
						S_Add3			 	= 6'b100000,
						S_Add_Wait3		 	= 6'b100001;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
               S_LOAD_Div: 		next_state = go ? S_LOAD_Div_Wait : S_LOAD_Div; 
               S_LOAD_Div_Wait: 	next_state = go ? S_LOAD_Div_Wait : S_Shift; 
               S_Shift: 			next_state = S_Shift_Wait;
               S_Shift_Wait:		next_state = S_Sub;
					S_Sub:	 			next_state = S_Sub_Wait;
					S_Sub_Wait:			next_state = S_Copy;
					S_Copy:	 			next_state = S_Copy_Wait;
					S_Copy_Wait:		next_state = S_Add; 
					S_Add:				next_state = S_Add_Wait;
					S_Add_Wait:			next_state = S_Shift1;
					S_Shift1: 			next_state = S_Shift_Wait1;
               S_Shift_Wait1:		next_state = S_Sub1;
					S_Sub1:	 			next_state = S_Sub_Wait1;
					S_Sub_Wait1:		next_state = S_Copy1;
					S_Copy1:	 			next_state = S_Copy_Wait1;
					S_Copy_Wait1:		next_state = S_Add1; 
					S_Add1:				next_state = S_Add_Wait1;
					S_Add_Wait1:		next_state = S_Shift2;
					S_Shift2: 			next_state = S_Shift_Wait2;
               S_Shift_Wait2:		next_state = S_Sub2;
					S_Sub2:	 			next_state = S_Sub_Wait2;
					S_Sub_Wait2:		next_state = S_Copy2;
					S_Copy2:	 			next_state = S_Copy_Wait2;
					S_Copy_Wait2:		next_state = S_Add_Wait; 
					S_Add2:				next_state = S_Add_Wait2;
					S_Add_Wait2:		next_state = S_Shift3;
					S_Shift3: 			next_state = S_Shift_Wait3;
               S_Shift_Wait3:		next_state = S_Sub3;
					S_Sub3:	 			next_state = S_Sub_Wait3;
					S_Sub_Wait3:		next_state = S_Copy3;
					S_Copy3:	 			next_state = S_Copy_Wait3;
					S_Copy_Wait3:		next_state = S_Add3; 
					S_Add3:				next_state = S_Add_Wait3;
					S_Add_Wait3:		next_state = S_Add_Wait3;
            default:     			next_state = S_LOAD_Div;
        endcase
    end // state_table
   

	always @(*)
    begin: enable_signals

			ld_r = 1'b0;
			lShift = 1'b0;
			sub 	= 1'b0;
			copy	= 1'b0;
			add	= 1'b0;


			case (current_state)
            S_LOAD_Div: begin
               ld_r	= 1'b1;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
               end
				S_LOAD_Div_Wait: begin
               ld_r	= 1'b1;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Shift: begin
					ld_r 	= 1'b0;
					lShift= 1'b1;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Shift_Wait: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Sub: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b1;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Sub_Wait: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Copy: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b1;
					add	= 1'b0;
					end
				S_Copy_Wait: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Add: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b1;
					end
				S_Add_Wait: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Shift1: begin
					ld_r 	= 1'b0;
					lShift= 1'b1;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Shift_Wait1: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Sub1: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b1;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Sub_Wait1: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Copy1: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b1;
					add	= 1'b0;
					end
				S_Copy_Wait1: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Add1: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b1;
					end
				S_Add_Wait1: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Shift2: begin
					ld_r 	= 1'b0;
					lShift= 1'b1;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Shift_Wait2: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Sub2: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b1;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Sub_Wait2: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Copy2: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b1;
					add	= 1'b0;
					end
				S_Copy_Wait2: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Add2: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b1;
					end
				S_Add_Wait2: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Shift3: begin
					ld_r 	= 1'b0;
					lShift= 1'b1;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Shift_Wait3: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Sub3: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b1;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Sub_Wait3: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Copy3: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b1;
					add	= 1'b0;
					end
				S_Copy_Wait3: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
				S_Add3: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b1;
					end
				S_Add_Wait3: begin
					ld_r 	= 1'b0;
					lShift= 1'b0;
					sub 	= 1'b0;
					copy	= 1'b0;
					add	= 1'b0;
					end
			endcase
    end // enable_signals
	   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
			if(!resetn)
			begin
            current_state <= S_LOAD_Div;
			end
			else
            current_state <= next_state;
    end // state_FFS
endmodule


module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule