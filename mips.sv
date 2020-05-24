// PIPELINE STRUCTURE


module pipeline();


parameter  add_r=6'd0;
parameter  add_imm=6'd1;
parameter  sub_r=6'd2;
parameter  sub_imm=6'd3;
parameter  mul_r=6'd4;
parameter  mul_imm=6'd5;
parameter  or_r=6'd6;
parameter  or_imm=6'd7;
parameter  and_r=6'd8;
parameter  and_imm=6'd9;
parameter  xor_r=6'd10;
parameter  xor_imm=6'd11;
parameter  load_i=6'd12;
parameter  store_i=6'd13;
parameter  bz_i=6'd14;
parameter  beq_i=6'd15;
parameter  jr_i=6'd16;
parameter  halt=6'd17;


bit [31:0]registers[32];
bit [31:0]ALU[32];
bit [7:0]memory[4096];
bit [31:0]pc;
bit [31:0]IR;
bit [31:0]temp_pc;


struct               {

  bit [31:0]Ir;
  bit [5:0]opcode;
  bit [4:0]Rs_add;
  bit [4:0]Rt_add;
  bit [4:0]Rd_add;
  bit [15:0]R_imm;

  bit [31:0]Rs;
  bit [31:0]Rt;
  bit [31:0]Rd;
  bit [15:0]imm;


                       } instruction_line[5];

struct               {

  bit [31:0]Ir;
  bit [5:0]opcode;
  bit [4:0]Rs_add;
  bit [4:0]Rt_add;
  bit [4:0]Rd_add;
  bit [15:0]R_imm;

  bit [31:0]Rs;
  bit [31:0]Rt;
  bit [31:0]Rd;
  bit [15:0]imm;


                       } temp_struct;



int instruction_stage[5];

//flags
bit dh_1 = 1;
bit dh_2 = 1;
int DH_1, DH_2;
bit temp3 = 1;

//TEMP VALUES
int i=0;
int count=0;
int fd;
int FE;
int DEC;
int EX;
int MEM;
int WB;
int stage;
bit [4:0] temp_reg_1, temp_reg_2, temp_reg_3;

//FINAL VALUES
int instruction_count;
int arithmetic;
int logical;
int memory_access;
int control_transfer;



//-------------------- Memory fill --------------------------------------------//

 initial begin : file_block

        fd = $fopen ("./sample_memory_image", "r");
		$display("file_block %d",fd);
  if(fd == 0)
	begin
		disable file_block;
	end
  
  while (!($feof(fd))) begin
    $fscanf(fd, "%h",IR);
	//$display("%h",IR);
	{memory[i], memory[i+1], memory[i+2], memory[i+3]}=IR;
    //$display("%8h%8h%8h%8h",memory[i], memory[i+1], memory[i+2], memory[i+3]);
	i=i+4;
   

    end
	$fclose(fd);
	$display("file_block=%d",fd);
  #6000;
  $finish();
  

end : file_block



//-------------------- clock generation --------------------------------------------//

bit clk=0;

always #20 clk=~clk;

//-------------------- clock interval --------------------------------------------//

always@(posedge clk)
	begin
	count=count+1;
	$display("clock_count %d",count);	
	end

//---------------------- Instruction fetch stage ----------------------------------//



always@(posedge clk)
	begin
	
		
				if((stage==0 || stage==1 || stage==2 || stage==3 || stage==4) && dh_2  == 1 && dh_1 == 1 )
					begin
					
                        $display("IS=FETCH"); 
                        instruction_line[0].Ir = {memory[pc], memory[pc+1], memory[pc+2], memory[pc+3]};
						$display("new");
						$display("%h",instruction_line[0].Ir);
						//$display("%d",instruction_stage[0]);
			            pc=pc+4;
						FE=1;
						//instruction_line[1]=instruction_line[0];
					end




//---------------------- Instruction decode stage ----------------------------------//



				if((stage==1 || stage==2 || stage==3 || stage==4) && FE==1 && dh_2  == 1 && dh_1 == 1)
					begin
					$display("IS=DECODE%d",count);
						instruction_line[1].opcode = instruction_line[1].Ir[31:26];
						if ((instruction_line[1].opcode == add_r ) ||
							(instruction_line[1].opcode == sub_r)  ||
							(instruction_line[1].opcode == mul_r)  ||
							(instruction_line[1].opcode == or_r)   ||
							(instruction_line[1].opcode == and_r)  ||
							(instruction_line[1].opcode == xor_r))
							begin
								instruction_line[1].Rs = registers[instruction_line[1].Ir[25:21]];
								instruction_line[1].Rt = registers[instruction_line[1].Ir[20:16]];
								//instruction_line[i].Rd = registers[instruction_line[i].Ir[15:11]];	
								instruction_line[1].Rs_add = instruction_line[1].Ir[25:21];
								instruction_line[1].Rt_add = instruction_line[1].Ir[20:16];
								instruction_line[1].Rd_add = instruction_line[1].Ir[15:11];	
								$display("%b",instruction_line[1].Rs_add);
								$display("%b",instruction_line[1].Rt_add);
								$display("%b",instruction_line[1].Rd_add);
								instruction_count=instruction_count+1;
								if(instruction_line[1].Rd_add == 5'b00000)
									begin
										instruction_line[1].opcode = 6'b111111;
										registers[0] = '0;
										temp_reg_1=instruction_line[1].Rd_add;
									end
							end
							
						else if ((instruction_line[1].opcode == add_imm) ||
								 (instruction_line[1].opcode == sub_imm) ||
								 (instruction_line[1].opcode == mul_imm) || 
								 (instruction_line[1].opcode == or_imm)  || 
								 (instruction_line[1].opcode == and_imm) || 
								 (instruction_line[1].opcode == xor_imm) || 
								 (instruction_line[1].opcode == load_i)  || 
								 (instruction_line[1].opcode == store_i) || 
								 (instruction_line[1].opcode == beq_i))
							begin
								instruction_line[1].Rs = registers[instruction_line[1].Ir[25:21]];
								instruction_line[1].Rt = registers[instruction_line[1].Ir[20:16]];
								instruction_line[1].Rs_add = instruction_line[1].Ir[25:21];
								instruction_line[1].Rt_add = instruction_line[1].Ir[20:16];
								instruction_line[1].imm = instruction_line[1].Ir[15:0];
								$display("%b",instruction_line[1].Rs_add);
								$display("%b",instruction_line[1].Rt_add);
								$display("%b",instruction_line[1].imm);
								$display("%b",instruction_line[1].opcode);
								instruction_count=instruction_count+1;
								if(instruction_line[1].Rt_add == 5'b00000)
									begin
										instruction_line[1].opcode = 6'b111111;
										registers[0] = '0;
										temp_reg_1=instruction_line[1].Rt_add;
									end
							end
							
						else if ((instruction_line[1].opcode == bz_i) ||
								 (instruction_line[1].opcode == jr_i))
							begin
								instruction_line[1].Rs_add = instruction_line[1].Ir[25:21];
								instruction_line[1].imm = instruction_line[1].Ir[15:0];
								$display("%b",instruction_line[1].Rs_add);
								$display("%b",instruction_line[1].imm);
								$display("%b",instruction_line[1].opcode);
								instruction_count=instruction_count+1;
								temp_reg_1=instruction_line[1].Rt_add;
							end
							
						else if (instruction_line[1].opcode == halt)
							begin
								//no_op
								$display("HALT");
								instruction_count=instruction_count+1;
							end
						//instruction_line[2]=instruction_line[1];
						DEC=1;
					end   
	

//---------------------- Instruction execute stage ----------------------------------//

				if(( stage==2 || stage==3 || stage==4) && DEC==1 && dh_2  == 1 && dh_1 == 1)
					begin
						$display("IS=EXECUTE%d",count);
						case(instruction_line[2].opcode)
								add_r:	
										begin
										//ADD_R(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].Rt_add].Rt,ALU[1][i]);
										ALU[1] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].Rt[instruction_line[2].Rt_add];
										$display("ADDR=%d",ALU[1]);
										temp_reg_2=instruction_line[2].Rd_add;
										arithmetic=arithmetic+1;
										end
								add_imm:	
										begin
										//ADD_I(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].R_imm].imm,ALU[i]);
										ALU[2] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].imm;
										$display("Rs=%d",instruction_line[2].Rs[instruction_line[2].Rs_add]);
										$display("Imm=%d",instruction_line[2].imm);
										$display("ADDI=%d",ALU[2]);
										arithmetic=arithmetic+1;
										temp_reg_2=instruction_line[2].Rt_add;
										end
								sub_r:	
										begin
										//SUB_R(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].Rt_add].Rt,ALU[i]);
										ALU[3] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].Rt[instruction_line[2].Rt_add];
										$display("SUBR=%d",ALU[3]);
										temp_reg_2=instruction_line[2].Rd_add;
										arithmetic=arithmetic+1;
										end
								sub_imm:
										begin
										//SUB_I(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].R_imm].imm,ALU[i]);
										ALU[4] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].imm;
										$display("SUBI=%d",ALU[4]);
										arithmetic=arithmetic+1;
										temp_reg_2=instruction_line[2].Rt_add;
										end
								mul_r:
										begin
										//MUL_R(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].Rt_add].imm,ALU[i]);
										ALU[5] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].Rt[instruction_line[2].Rt_add];
										$display("MULR=%d",ALU[5]);
										temp_reg_2=instruction_line[2].Rd_add;
										arithmetic=arithmetic+1;
										end
								mul_imm:
										begin
										//MUL_I(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].R_imm].imm,ALU[i]);
										ALU[6] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].imm;
										$display("MULI=%d",ALU[6]);
										arithmetic=arithmetic+1;
										temp_reg_2=instruction_line[2].Rt_add;
										end
								or_r:
										begin
										//OR_R(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].Rt_add].imm,ALU[i]);
										ALU[7] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].Rt[instruction_line[2].Rt_add];
										$display("ORR=%d",ALU[7]);
										temp_reg_2=instruction_line[2].Rd_add;
										logical=logical+1;
										end
								or_imm:
										begin
										//OR_I(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].R_imm].imm,ALU[i]);
										ALU[8] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].imm;
										$display("ORI=%d",ALU[8]);
										temp_reg_2=instruction_line[2].Rt_add;
										logical=logical+1;
										end
								and_r:
										begin
										//AND_R(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].Rt_add].imm,ALU[i]);
										ALU[9] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].Rt[instruction_line[2].Rt_add];
										$display("ANDR=%d",ALU[9]);
										temp_reg_2=instruction_line[2].Rd_add;
										logical=logical+1;
										end
								and_imm:
										begin
										//AND_I(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].R_imm].imm,ALU[i]);
										ALU[10] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].imm;
										$display("ANDI=%d",ALU[10]);
										temp_reg_2=instruction_line[2].Rt_add;
										logical=logical+1;
										end
								xor_r:
										begin
										//XOR_R(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].Rt_add].imm,ALU[i]);
										ALU[11] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].Rt[instruction_line[2].Rt_add];
										$display("XORR=%d",ALU[11]);
										temp_reg_2=instruction_line[2].Rd_add;
										logical=logical+1;
										end
								xor_imm:
										begin
										//XOR_I(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].R_imm].imm,ALU[i]);
										ALU[12] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].imm;
										$display("XORI=%d",ALU[12]);
										logical=logical+1;
										temp_reg_2=instruction_line[2].Rt_add;
										end
								load_i:
										begin
										//LOAD_I(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].R_imm].imm,ALU[i]);
										ALU[13] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].imm;
										//$display("LOADI=%d",memory[ALU[13]];
										memory_access=memory_access+1;
										temp_reg_2=instruction_line[2].Rt_add;
										end
								store_i:
										begin
										//STORE_I(instruction_line[instruction_line[i].Rs_add].Rs,instruction_line[instruction_line[i].R_imm].imm,ALU[i]);
										ALU[14] = instruction_line[2].Rs[instruction_line[2].Rs_add] + instruction_line[2].imm;
										//$display("STOREI=%d",memory[ALU[14]];
										memory_access=memory_access+1;
										temp_reg_2=instruction_line[2].Rt_add;
										end
								bz_i:
										begin
										if(instruction_line[2].Rs[instruction_line[2].Rs_add] == 0)
											begin
												$display("BEFORE BRANCH	pc=%h",pc-8);
												$display("IR=%h",instruction_line[2].Ir);
												temp_pc=pc-8;
												temp_pc=temp_pc+(instruction_line[2].imm*4);
												//instruction_line[2].Ir = {memory[temp_pc], memory[temp_pc+1], memory[temp_pc+2], memory[temp_pc+3]};
												$display("AFTER BRANCH	pc=%h",temp_pc);
												//$display("IR=%h",instruction_line[2].Ir);
												control_transfer=control_transfer+1;
												instruction_line[2].opcode = 6'b111111;
												instruction_line[1].opcode = 6'b111111;
												instruction_line[0].opcode = 6'b111111;
											end
										else
											control_transfer=control_transfer+1;
										end				
								beq_i:
										begin
										if(instruction_line[2].Rs[instruction_line[2].Rs_add] == instruction_line[2].Rt[instruction_line[2].Rt_add])
											begin
												$display("BEFORE BRANCH	pc=%h",pc-8);
												//$display("IR=%h",instruction_line[i].Ir);
												temp_pc=pc-8;
												temp_pc=temp_pc+(instruction_line[2].imm*4);
												$display("AFTER BRANCH	pc=%h",temp_pc);
												//$display("IR=%h",instruction_line[i].Ir);
												control_transfer=control_transfer+1;
												instruction_line[2].opcode = 6'b111111;
												instruction_line[1].opcode = 6'b111111;
												instruction_line[0].opcode = 6'b111111;
											end	
										else
											control_transfer=control_transfer+1;
										end
								jr_i:
										begin
										instruction_line[2].opcode = 6'b111111;
										instruction_line[1].opcode = 6'b111111;
										instruction_line[0].opcode = 6'b111111;
										$display("BEFORE JUMP pc=%h",pc);
										//$display("IR=%h",instruction_line[i].Ir);
										pc=registers[instruction_line[2].Rs_add];
										$display("AFTER BRANCH	pc=%h",pc);
										$display("Rs_add=%b",instruction_line[2].Rs_add);
										control_transfer=control_transfer+1;
										end
								halt:
										begin
										//no assignments
										$display("HALT");
										end
						endcase
						if(temp_reg_2==temp_reg_1) 
							begin
								dh_2=0;
								temp3=0;
								$display("test");
							end
						else
							begin
								dh_2=1;
							end
						EX=1;
						
						//instruction_line[3]=instruction_line[2];
					end

//---------------------- Mem stage ----------------------------------//

				if((stage==3 || stage==4) && EX==1 && dh_1==1)
					begin	
						$display("IS=MEM%d",count); 
						case(instruction_line[3].opcode)
								load_i:
										begin
										registers[instruction_line[3].Rt_add] = memory[ALU[14]];
										temp_reg_3=instruction_line[3].Rt_add;
										end
								store_i:
										begin
										memory[ALU[15]] = registers[instruction_line[3].Rt_add];
										end
						endcase
						if(temp3==1)
							begin
								if(temp_reg_3==temp_reg_1) 
									begin
										dh_1=0;
									end
								else
									begin
										dh_1=1;
									end
							end
						else
							begin
								dh_1=1;
								temp3=1'b1;
							end
							MEM=1;
						//instruction_line[4]=instruction_line[3];
					end   

//---------------------- Writeback stage ----------------------------------//

				if((stage==4) && MEM==1)
					begin
						$display("IS=WRITEBACK%d",count); 
						case(instruction_line[4].opcode)
								add_r:	
										begin
										registers[instruction_line[4].Rd_add]=ALU[1];
										$display("ADDR=%d%d",registers[instruction_line[4].Rd_add],instruction_line[4].Rd_add);
										end
								add_imm:	
										begin
										registers[instruction_line[4].Rt_add]=ALU[2];
										$display("ADDI=%d",registers[instruction_line[4].Rt_add]);
										$display("ADDI=%d",instruction_line[4].Rt_add);
										end
								sub_r:	
										begin
										registers[instruction_line[4].Rd_add]=ALU[3];
										$display("SUBR=%d",registers[instruction_line[4].Rd_add]);
										end
								sub_imm:
										begin
										registers[instruction_line[4].Rt_add]=ALU[4];
										$display("SUBI=%d",registers[instruction_line[4].Rt_add]);
										end
								mul_r:
										begin
										registers[instruction_line[4].Rd_add]=ALU[5];
										$display("MULR=%d",registers[instruction_line[4].Rd_add]);
										end
								mul_imm:
										begin
										registers[instruction_line[4].Rt_add]=ALU[6];
										$display("MULI=%d",registers[instruction_line[4].Rt_add]);
										end
								or_r:
										begin
										registers[instruction_line[4].Rd_add]=ALU[7];
										$display("ORR=%d",registers[instruction_line[4].Rd_add]);
										end
								or_imm:
										begin
										registers[instruction_line[4].Rt_add]=ALU[8];
										$display("ORI=%d",registers[instruction_line[4].Rt_add]);
										end
								and_r:
										begin
										registers[instruction_line[4].Rd_add]=ALU[9];
										$display("ANDR=%d",registers[instruction_line[4].Rd_add]);
										end
								and_imm:
										begin
										registers[instruction_line[4].Rt_add]=ALU[10];
										$display("ANDI=%d",registers[instruction_line[4].Rt_add]);
										end
								xor_r:
										begin
										registers[instruction_line[4].Rd_add]=ALU[11];
										$display("XORR=%d",registers[instruction_line[4].Rd_add]);
										end
								xor_imm:
										begin
										registers[instruction_line[4].Rt_add]=ALU[12];
										$display("XORI=%d",registers[instruction_line[4].Rt_add]);
										end
								load_i:
										begin
										registers[instruction_line[4].Rt_add]=memory[ALU[13]];
										$display("LOADI=%d",registers[instruction_line[4].Rt_add]);
										end
								halt:
										begin
										$display("END OF SIMULATION");
										$stop;
										end
						endcase
						end
					
					if(dh_2  == 0)
						begin
							instruction_line[4]=instruction_line[3];
							instruction_line[3]=instruction_line[2];
							instruction_line[2].opcode=6'b111111;
							registers[0]='0;
							DH_2=DH_2+1;
							$display("		STALL2");
							if(DH_2==3)
								begin
								dh_2=1;
								DH_2=0;
								end
						end
						
					else if(dh_1 == 0)
						begin
							instruction_line[4]=instruction_line[3];
							instruction_line[3].opcode=6'b111111;
							registers[0]='0;
							DH_1=DH_1+1;
							$display("		STALL1");
							if(DH_1==2)
								begin
								dh_1=1;
								DH_1=0;
								end
							//MEM = 1;
						end
						
					else
						begin
							instruction_line[4]=instruction_line[3];
							instruction_line[3]=instruction_line[2];
							instruction_line[2]=instruction_line[1];
							instruction_line[1]=instruction_line[0];
							registers[0]='0;
							$display("ADDR=%d",instruction_line[4].Rt_add);
							$display("		NO_STALL");
						end
					
if(stage<4)
	begin
		stage=stage+1;
		$display("stage=%d",stage);
	end
else
	begin
		stage=4;
		$display("stage=%d",stage);
	end
	
	end
	
final
	begin
			$display( "The number of clock cycles  : %d" , count );
			$display( "The contents of Registers are : %p" , registers);
			$display ( "The value of PC : %d" , pc );
			$display( "INSTRUCTION COUNT : %d" , instruction_count );
			$display( "ARITHMETIC INSTRUCTIONS : %d" , arithmetic);
			$display( "LOGICAL INSTRUCTIONS : %d" , logical);
			$display( "MEMORY ACCESS INSTRUCTIONS : %d" , memory_access);
			$display( "CONTROL TRANSFER INSTRUCTIONS : %d" , control_transfer);
	end

endmodule
/*
//---------------------- Functions for computations ----------------------------------//
function void ADD_R(input bit [31:0]a , input bit [31:0]b , output bit [31:0]c );
	
		c=a+b;
	
endfunction	

function void ADD_I(input bit [31:0]a , input bit [15:0]b , output bit [31:0]c );
	
		c=a+b;
	
endfunction	

function void SUB_R(input bit [31:0]a , input bit [31:0]b , output bit [31:0]c );
	
		c=a-b;
		
endfunction	

function void SUB_I(input bit [31:0]a , input bit [15:0]b , output bit [31:0]c );
	
		c=a-b;
		
endfunction	

function void MUL_R(input bit [31:0]a , input bit [31:0]b , output bit [31:0]c );
	
		c=a*b;
	
endfunction

function void MUL_I(input bit [31:0]a , input bit [15:0]b , output bit [31:0]c );
	
		c=a*b;
	
endfunction

function void OR_R(input bit [31:0]a , input bit [31:0]b , output bit [31:0]c );
	
		c=a|b;
		
endfunction

function void OR_I(input bit [31:0]a , input bit [15:0]b , output bit [31:0]c );
	
		c=a|b;
		
endfunction

function void AND_R(input bit [31:0]a , input bit [31:0]b , output bit [31:0]c );
	
		c=a&b;
		
endfunction

function void AND_I(input bit [31:0]a , input bit [15:0]b , output bit [31:0]c );
	
		c=a&b;
		
endfunction	

function void XOR_R(input bit [31:0]a , input bit [31:0]b , output bit [31:0]c );
	
		c=a^b;
		
endfunction
	
function void XOR_I(input bit [31:0]a , input bit [15:0]b , output bit [31:0]c );
	
		c=a^b;
		
endfunction	
*/

	
