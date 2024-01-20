module stepper_traka (clk, ir_zatvaranje, ir_pumpa, motor_traka1, motor_traka2);
    
	input clk;
	input ir_zatvaranje;
	input ir_pumpa;
  
	output[3:0] motor_traka1; 
	output[3:0] motor_traka2;
	
	reg[3:0] motor_traka1; 
	reg[3:0] motor_traka2;
	reg[1:0] step1, step2;
	reg[31:0] StepCounter = 32'b0;
	
	parameter[31:0] step_delay = 32'd200000;	//250HZ
	parameter[31:0] vrijeme_zatvaranja = 32'd227_600_000; //vrijeme dovoljno da se flasa zatvori
	parameter[31:0] vrijeme_punjenja = 32'd750_000_000; //11s proracuat
	parameter input_angle = 3000; 
	
	integer angle = 0;
	integer blokiranje_zatvaranje = 0;
	integer blokiranje_pumpa = 0;

	initial	  
	begin 
		step1 <= 3'b0;
		step2 <= 3'b0;
		StepCounter <= 32'b0;
		motor_traka1 <= 4'b0000;
		motor_traka2 <= 4'b0000;
	end
	
	always @(posedge clk) 
	begin
	
	//-------------BESKONACNA VRTNJA TRAKE-------------
		if ((ir_zatvaranje == 1'b1) && (ir_pumpa == 1'b1) && (blokiranje_zatvaranje == 0) && (blokiranje_pumpa == 0))
		begin
			StepCounter <= StepCounter + 31'b1; 
					
			if (StepCounter >= step_delay)
			begin
				StepCounter <= 31'b0;
				step1 <= step1 - 1;
				step2 <= step2 - 1;
				
				//---------motor1---------
				case (step1) 
				0: motor_traka1 <= 4'b1100;
				1: motor_traka1 <= 4'b0110;
				2: motor_traka1 <= 4'b0011;
				3: motor_traka1 <= 4'b1001;						
				endcase 
				//---------motor2---------
				case (step2) 
				0: motor_traka2 <= 4'b1100;
				1: motor_traka2 <= 4'b0110;
				2: motor_traka2 <= 4'b0011;
				3: motor_traka2 <= 4'b1001;						
				endcase 
			end
		end
		
		//---------------------------PUMPA--------------------------
		//-----------------TRAKA STOJI, PUNJENJE FLAŠE--------------
		else if((ir_pumpa == 1'b0) && (StepCounter < vrijeme_punjenja) && (blokiranje_pumpa == 0))
		begin
			StepCounter <= StepCounter + 1'b1;
			motor_traka1 <= 4'b0000;
			motor_traka2 <= 4'b0000;
		end
		//------------------FLAŠA NAPUNJENA-------------------------
		else if ((ir_pumpa == 1'b0) && (StepCounter == vrijeme_punjenja) && (blokiranje_pumpa == 0))
		begin
			blokiranje_pumpa = 1;
			StepCounter <= 31'b0;					
		end
		
		//-----POMICANJE FLAŠE ISPRED IR SENZORA NAKON PUNJENJA-----
		else if(blokiranje_pumpa == 1)
		begin
			StepCounter <= StepCounter + 31'b10;
			if (StepCounter >= step_delay)
			begin
				StepCounter <= 31'b0;
				if (angle < input_angle) 
				begin
					step1 <= step1 - 1;
					step2 <= step2 - 1;
					angle <= angle + 1;
					
					//---------motor1---------
					case (step1) 
					0: motor_traka1 <= 4'b1100;
					1: motor_traka1 <= 4'b0110;
					2: motor_traka1 <= 4'b0011;
					3: motor_traka1 <= 4'b1001;						
					endcase 
					
					//---------motor2---------
					case (step2) 
					0: motor_traka2 <= 4'b1100;
					1: motor_traka2 <= 4'b0110;
					2: motor_traka2 <= 4'b0011;
					3: motor_traka2 <= 4'b1001;						
					endcase 
				end
				
				//----RESETOVANJE UGLA I NASTAVAK BESKONACNE VRTNJE TRAKE----
				else if(angle == input_angle)
				begin
					angle = 0;
					blokiranje_pumpa = 0;
				end
			end
		end
		
		//-------------------------ZATVARANJE-------------------------
		//-----------------TRAKA STOJI, ZATVARANJE FLAŠE--------------
		else if ((ir_zatvaranje == 1'b0) && (StepCounter < vrijeme_zatvaranja) && (blokiranje_zatvaranje == 0))
		begin
			StepCounter <= StepCounter + 31'b1;
			motor_traka1 <= 4'b0000;
			motor_traka2 <= 4'b0000;
		end
		
		//-------------------FLAŠA ZATVORENA---------------------------
		else if ((ir_zatvaranje == 1'b0) && (StepCounter == vrijeme_zatvaranja) && (blokiranje_zatvaranje == 0))
		begin
			blokiranje_zatvaranje = 1;
			StepCounter <= 31'b0;
		end
		
		//------POMICANJE FLAŠE ISPRED IR SENZORA NAKON ZATVARANJA-----
		else if (blokiranje_zatvaranje == 1)
		begin
			StepCounter <= StepCounter + 31'b10;
			if (StepCounter >= step_delay)
			begin
				StepCounter <= 31'b0;
				if (angle < input_angle) 
				begin
					step1 <= step1 - 1;
					step2 <= step2 - 1;
					angle <= angle + 1;
					
					//---------motor1---------
					case (step1) 
					0: motor_traka1 <= 4'b1100;
					1: motor_traka1 <= 4'b0110;
					2: motor_traka1 <= 4'b0011;
					3: motor_traka1 <= 4'b1001;						
					endcase 
					
					//---------motor2---------
					case (step2) 
					0: motor_traka2 <= 4'b1100;
					1: motor_traka2 <= 4'b0110;
					2: motor_traka2 <= 4'b0011;
					3: motor_traka2 <= 4'b1001;						
					endcase 
				end
				
				//----RESETOVANJE UGLA I NASTAVAK BESKONACNE VRTNJE TRAKE----
				else if(angle == input_angle)
				begin
					angle = 0;
					blokiranje_zatvaranje = 0;
					
				end
			end
		end
		
	end
endmodule 