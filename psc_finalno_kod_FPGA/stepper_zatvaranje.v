module stepper_zatvaranje(clk, ir_zatvaranje, motor_zatvaranje1, motor_zatvaranje2);
    
	input clk;
	input ir_zatvaranje;
  
	output[3:0] motor_zatvaranje1; 
	output[3:0] motor_zatvaranje2;
     
	reg[3:0] motor_zatvaranje1;
	reg[3:0] motor_zatvaranje2;
	reg[1:0] step1, step2; 
	reg[31:0] StepCounter = 32'b0;
	
	parameter	[31:0] step_delay = 32'd200000;	//250HZ
	parameter	[31:0] vrijeme_cekanja = 32'd300_000_000; //6s
	parameter	input_angle = 850; 
	
	integer angle;
 
	initial	  
		begin 
			step1 <= 3'b0;
			step2 <= 3'b0;
			StepCounter <= 32'b0;
			angle = 0;
			motor_zatvaranje1 <= 4'b0000;
			motor_zatvaranje2 <= 4'b0000;
		end
			
	always @(posedge clk) 
	begin
		//------------CIJELI PROCES ZATVARANJA FLASE-------------
		if ((ir_zatvaranje == 1'b0) && (angle < (2*input_angle)))
		begin
			StepCounter <= StepCounter + 31'b1; 
					
			if (StepCounter >= step_delay)
			begin
				StepCounter <=32'b0;
				
				//--------SPUSTANJE MEHANIZMA ZA ZATVARANJE--------
				if (angle < input_angle) 
				begin
					step1 <= step1 - 1;
					step2 <= step2 + 1;
					angle <= angle + 1;
					
					//---------motor1---------
					case (step1) 
					0: motor_zatvaranje1 <= 4'b1100;
					1: motor_zatvaranje1 <= 4'b0110;
					2: motor_zatvaranje1 <= 4'b0011;
					3: motor_zatvaranje1 <= 4'b1001;						
					endcase
					
					//---------motor2---------
					case (step2) 
					0: motor_zatvaranje2 <= 4'b1100;
					1: motor_zatvaranje2 <= 4'b0110;
					2: motor_zatvaranje2 <= 4'b0011;
					3: motor_zatvaranje2 <= 4'b1001;						
					endcase 
				end
				
				else if (angle == input_angle)
				begin
					step1 <= 0;
					step2 <= 0;
					angle <= angle + 1;
				end
				
				//--------PODIZANJE MEHANIZMA ZA ZATVARANJE--------
				else if ((angle > input_angle) && (angle < (2 * input_angle)))
				begin
					step1 <= step1 + 1;
					step2 <= step2 - 1;
					angle <= angle + 1;
					
					//---------motor1---------
					case (step1) 
					0: motor_zatvaranje1 <= 4'b1100;
					1: motor_zatvaranje1 <= 4'b0110;
					2: motor_zatvaranje1 <= 4'b0011;
					3: motor_zatvaranje1 <= 4'b1001;		
					
					endcase 
					//---------motor2---------
					case (step2) 
					0: motor_zatvaranje2 <= 4'b1100;
					1: motor_zatvaranje2 <= 4'b0110;
					2: motor_zatvaranje2 <= 4'b0011;
					3: motor_zatvaranje2 <= 4'b1001;						
					endcase 
				end
			end
		end
		
		//-----BLOKIRANJE SPUSTANJA MEHANIZMA DOK SE ZATVORENA FLASA NE POMJERI ISPRED IR SENZORA-----
		else if ( angle >= (2 * input_angle))
		begin
			motor_zatvaranje1 <= 4'b0000;
			motor_zatvaranje2 <= 4'b0000;
			
			StepCounter <= StepCounter + 31'b1;
			
			if (StepCounter == vrijeme_cekanja)
			begin
				angle <= 0;
				StepCounter <=32'b0;
			end	
		end
	end 
 endmodule
