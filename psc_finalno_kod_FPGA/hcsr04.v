module hcsr04(clk, trig, echo, motor_pregrada);

input clk;
input echo;

output trig;
output[3:0] motor_pregrada;

reg[1:0] step1;
reg[3:0] motor_pregrada; 
reg[31:0] StepCounter = 32'b0;

reg trig_value = 1'b0;
reg [21:0] counter = 22'd00_0000_0000_0000_0000_0000;
reg [18:0] echo_counter = 19'd000_0000_0000_0000_0000;
reg [19:0] delay_counter = 20'd0000_0000_0000_0000_0000;

parameter[31:0] step_delay = 32'd200000;	//250HZ
parameter input_angle = 200; //ugao za pregradu

integer angle = 0;
integer blokiranje_senzor = 0;

always @(posedge clk )
begin
	//------------IMPULS NA TRIG PINU U TRAJANJU OD 10us------------
	counter<=counter+1'b1;
	if(counter<=500)
		begin
		trig_value <=1'b1;
		end
	else
	
		//-----RESETOVANJE TRIG PINA I OSLUSKIVANJE NA ECHO PINU-----
		begin
		trig_value <= 1'b0;
		if(echo)
			begin
				echo_counter<=echo_counter+1'b1;
				
				//------UKOLIKO SE DETEKTUJE VRIJEDNOST 10,5cm - 13cm FLASA NIJE DOBRO ZATVORENA------
				if((echo_counter > 4'd30882) && (echo_counter < 4'd38235) && (blokiranje_senzor == 0))
				begin
					blokiranje_senzor = 1;
				end
				
				//	--------------------PREGRADA KOJA BLOKIRA PROLAZAK DEFEKTNE FLASE-------------------
				if (blokiranje_senzor == 1)
				begin
					StepCounter <= StepCounter + 31'b1; 
							
					if (StepCounter >= step_delay)
					begin
						StepCounter <=32'b0;
						
						//	------------POKRETANJE PREGRADE KOJA BLOKIRA PROLAZAK DEFEKTNE FLASE----------
						if (angle <= input_angle) 
						begin
							step1 <= step1 - 1;
							angle <= angle + 1;
							
							//motor
							case (step1) 
							0: motor_pregrada <= 4'b1100;
							1: motor_pregrada <= 4'b0110;
							2: motor_pregrada <= 4'b0011;
							3: motor_pregrada <= 4'b1001;						
							endcase 
						end
						
						//	------------VRACANJE PREGRADE KOJA BLOKIRA PROLAZAK DEFEKTNE FLASE----------
						else if ((angle > input_angle) && (angle < (2 * input_angle)))
						begin
							step1 <= step1 + 1;
							angle <= angle + 1;
							
							//motor
							case (step1) 
							0: motor_pregrada <= 4'b1100;
							1: motor_pregrada <= 4'b0110;
							2: motor_pregrada <= 4'b0011;
							3: motor_pregrada <= 4'b1001;					
							endcase 
						end
						
						//--------------------------RESETOVANJE UGLA PREGRADE--------------------------
						else if (angle == input_angle)
						begin
							blokiranje_senzor = 0;
							angle <= 0;
							StepCounter <= 0;
						end
					end
				end
			end
		else
		if(echo_counter !== 19'd000_0000_0000_0000_0000)
			begin
			delay_counter <= delay_counter+1;
			if(delay_counter >= 20'b1111_0100_0010_0100_0000)
				begin
				counter <= 22'b00_0000_0000_0000_0000_0000;
				echo_counter <= 19'd000_0000_0000_0000_0000;
				delay_counter <= 20'b0000_0000_0000_0000_0000;
				end
			end
				
		end
end

assign trig = trig_value;

endmodule
