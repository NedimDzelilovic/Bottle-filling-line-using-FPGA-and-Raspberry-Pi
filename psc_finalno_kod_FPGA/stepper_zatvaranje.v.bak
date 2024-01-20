//***********VERZIJA TRI ( sa datim uglom ) ****************
module stepper_zatvaranje(clk, ir_zatvaranje, StepMotor1, StepMotor2);
    
	input clk;
	input ir_zatvaranje;
  
	output[3:0] StepMotor1; 
	output[3:0] StepMotor2; 
     
	reg[3:0] StepMotor1;
	reg[3:0] StepMotor2;
	reg[1:0] step1, step2; 
	reg[31:0] StepCounter = 32'b0;
	reg[2:0] brojac_kraj = 3'b0; 
	parameter[31:0] StepLockOut = 32'd200000;		//250HZ
	parameter[2:0] kraj = 3'd1138;

	parameter	input_angle = 569;
	parameter	dir = 0;
	
	integer angle = 0;
 
	initial	  
		begin 
			StepMotor1 <= 4'b0;
			StepMotor2 <= 4'b0;
			step1 <= 3'b0;
			step2 <= 3'b0;
			StepCounter <= 32'b0;
			brojac_kraj <=3'b0;
			//angle = input_angle;
		end
			
	always @(posedge clk) 
	begin
	
		if ((ir_zatvaranje == 1'b1) && (brojac_kraj < kraj))
		begin
		
			StepCounter <= StepCounter + 31'b1 ; 
					
			if (StepCounter >= StepLockOut)
			begin
				StepCounter <=32'b0;
				brojac_kraj <= brojac_kraj + 1'b1;	
				
				if (angle <= input_angle) 
				begin
					step1 <= step1 - 1;
					step2 <= step2 + 1;
					angle <= angle + 1;
					
					case (step1) 
					0: StepMotor1 <= 4'b1100;
					1: StepMotor1 <= 4'b0110;
					2: StepMotor1 <= 4'b0011;
					3: StepMotor1 <= 4'b1001;						
					endcase 
						
					case (step2) 
					0: StepMotor2 <= 4'b1100;
					1: StepMotor2 <= 4'b0110;
					2: StepMotor2 <= 4'b0011;
					3: StepMotor2 <= 4'b1001;						
					endcase 
				end
				
				else if ((angle > input_angle) && (angle < (2 * input_angle)))
				begin
					step1 <= step1 + 1;
					step2 <= step2 - 1;
					angle <= angle + 1;

					case (step1) 
					0: StepMotor1 <= 4'b1100;
					1: StepMotor1 <= 4'b0110;
					2: StepMotor1 <= 4'b0011;
					3: StepMotor1 <= 4'b1001;						
					endcase 
						
					case (step2) 
					0: StepMotor2 <= 4'b1100;
					1: StepMotor2 <= 4'b0110;
					2: StepMotor2 <= 4'b0011;
					3: StepMotor2 <= 4'b1001;						
					endcase 
				end
			end
		end 
	end 
 endmodule
