module top(clk,
				ir_zatvaranje, 
				ir_pumpa,
				motor_zatvaranje1, 
				motor_zatvaranje2, 
				motor_traka1, 
				motor_traka2,
				pumpa_switch,
				dioda_punjenje,
				);

	input clk;
	input ir_zatvaranje;
	input ir_pumpa;
	
	output [3:0] motor_zatvaranje1; 
	output [3:0] motor_zatvaranje2;
	output [3:0] motor_traka1;
	output [3:0] motor_traka2;
	output pumpa_switch;
	output dioda_punjenje;
		
	stepper_zatvaranje step_motor_zatvaranje (
		.clk (clk),
		.ir_zatvaranje (ir_zatvaranje),
		.motor_zatvaranje1 (motor_zatvaranje1),
		.motor_zatvaranje2 (motor_zatvaranje2)
		);
		
	stepper_traka step_motor_traka (
		.clk (clk),
		.ir_zatvaranje (ir_zatvaranje),
		.ir_pumpa(ir_pumpa),
		.motor_traka1 (motor_traka1),
		.motor_traka2 (motor_traka2)
		);
		
	pumpa pumpa (
		.clk(clk),
		.ir_pumpa(ir_pumpa),
		.pumpa_switch(pumpa_switch),
		.dioda_punjenje(dioda_punjenje)
		);

endmodule 