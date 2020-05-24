module concatenate();
  int i;
  bit [5:0] a;
  bit [25:0] c;
  bit [31:0] d;
  
  initial begin
    for (i=0;i<18;i++)
      begin
        a=i;
        d={a,c};
        $display("%h",d);
      end
  end
endmodule