// PIPELINE STRUCTURE


module pipeline();


parameter  add_i=6'd0;
parameter  add_imm=6'd1;
parameter  sub_i=6'd2;
parameter  sub_imm=6'd3;
parameter  mul_i=6'd4;
parameter  mul_imm=6'd5;
parameter  or_i=6'd6;
parameter  or_imm=6'd7;
parameter  and_i=6'd8;
parameter  and_imm=6'd9;
parameter  xor_i=6'd10;
parameter  xor_imm=6'd11;
parameter  load_i=6'd12;
parameter  store_i=6'd13;
parameter  bz_i=6'd14;
parameter  beq_i=6'd15;
parameter  jr_i=6'd16;
parameter  halt_i=6'd17;


bit [31:0]registers[32];
bit [7:0]memory[4096];
bit [31:0]pc;


struct               {

  bit [31:0]Ir;
  bit [5:0]opcode;
  bit [4:0]Rs_add;
  bit [4:0]Rt_add;
  bit [4:0]Rd_add;

  bit [31:0]Rs;
  bit [31:0]Rt;
  bit [31:0]Rd;
  bit [16:0]imm;

  bit [31:0]x_inst;
  bit [31:0]registers[32];

                       } instruction_line[5];



bit [3:0] instruction_stage[5];

int i=0;


//-------------------- Memory fill --------------------------------------------//

 initial begin : file_block

        fd = $fopen ("./sample_memory_image", "r");
  
  if(fd ==0)
    disable file_block;
  
  while (!($feof(fd))) begin
    $fscanf(fd, "%8h%8h%8h%8h",memory[i], memory[i+1], memory[i+2], memory[i+3]);
     i=i+1;
   begin

  end

    end

  #6000;
  $finish();
  $fclose(fd);

end : file_block



//-------------------- clock generation --------------------------------------------//

bit clk=0;

always #10 clk=~clk;



//---------------------- Instruction fetch stage ----------------------------------//



always@(posedge clk)

 begin

      for(i=0; i<5; i++)

          begin

               if(instruction_stage[i]==0)

                       begin
                          
                        instruction_line[i].ir = pc;
			            pc=pc+4;
                        instruction_stage[i]=1;
 
                       end
           end

 end




//---------------------- Instruction decode stage ----------------------------------//



always@(posedge clk)

 begin

      for(i=0; i<5; i++)

          begin

               if(instruction_stage[i]==1)

                       begin
                          
                        instruction_line[i].opcode = instruction_line[i].Ir[31:26];
                        instruction_stage[i]=2;
                       
		       end
           end

 end




//---------------------- Instrecution execute stage ----------------------------------//
