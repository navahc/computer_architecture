module trace_maker();
  int i;
  bit [5:0] a=1;
  bit [31:0] d;
  bit [4:0] Rs=0;
  bit [4:0] Rt=3;
  bit [4:0] Rd=1;
  bit [15:0] imm=3;
  bit [10:0] unused=3;
  bit instruction_format=1;
  
  initial begin
    if (instruction_format==0)
		begin
          	d={a,Rs,Rt,Rd,unused};
        	$display("%h",d);
			for (i=0;i<32;i++)
				begin
				if (i==Rs)
					begin
						$display("Rs=R%d",i);
						break;
					end
				end
			for (i=0;i<32;i++)
				begin
				if (i==Rt)
					begin
						$display("Rt=R%d",i);
						break;
					end
				end
			for (i=0;i<32;i++)
				begin
				if (i==Rd)
					begin
						$display("Rd=R%d",i);
						break;
					end
				end
 		 end
    else
		begin
          	d={a,Rs,Rt,imm};
        	$display("%h",d);
			for (i=0;i<32;i++)
				begin
				if (i==Rs)
					begin
						$display("Rs=R%d",i);
						break;
					end
				end
			for (i=0;i<32;i++)
				begin
				if (i==Rt)
					begin
						$display("Rt=R%d",i);
						break;
					end
				end
			for (i=0;i<32;i++)
				begin
				if (i==imm)
					begin
						$display("imm=%d",i);
						break;
					end
				end
 		 end
  end
endmodule