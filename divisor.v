module divisor
#(parameter W=8, CBIT=8)
(
	input clk,reset_n,
	input start,
	input [W-1:0] dvnd,dvsr,
	output reg ready,
	output [W-1:0] rem,quo
);
localparam [1:0]
idle=2'b00,
op=2'b01,
last=2'b10,
done=2'b11;

reg [1:0] current_state,next_state;
reg [W-1:0] rh_reg,rh_next,rl_reg,rl_next,rh_tmp;
reg [W-1:0] d_reg,d_next;
reg [CBIT-1:0] n_reg,n_next;
reg q_bit;

always @(posedge clk or negedge reset_n)
begin
	if(!reset_n)
	begin
		current_state<=idle;
		rh_reg<=0;
		rl_reg<=0;
		d_reg<=0;
		n_reg<=0;
	end
	else
	begin
		current_state<=next_state;
		rh_reg<=rh_next;
		rl_reg<=rl_next;
		d_reg<=d_next;
		n_reg<=n_next;
	end
end

always @(*)
begin
	next_state=current_state;
	ready=0;
	rh_next=rh_reg;
	rl_next=rl_reg;
	n_next=n_reg;
	d_next=d_reg;
	case(current_state)
		idle:
		begin
			ready=1;
			if(start)
			begin
				rh_next=0;
				rl_next=dvnd;
				d_next=dvsr;
				n_next=CBIT;
				next_state=op;
			end
		end
		op:
		begin
			rl_next={rl_reg[W-2:0],q_bit};
			rh_next={rh_tmp[W-2:0],rl_reg[W-1]};
			n_next=n_reg-1;
			if(n_next==1)
				next_state= last;
		end
		last:
		begin
			rl_next={rl_reg[W-2:0], q_bit};
			rh_next=rh_tmp;
			next_state = done;
		end
		done:
		begin
			next_state = done;
		end
		default:
			next_state = idle;
	endcase
end
always @*
begin
	if(rh_reg>=d_reg)
	begin
		rh_tmp = rh_reg - d_reg;
		q_bit=1;
	end
	else
	begin
		rh_tmp = rh_reg;
		q_bit=0;
	end
end
assign quo=rl_reg;
assign rem = rh_reg;
endmodule