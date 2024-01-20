module pumpa (clk, ir_pumpa, pumpa_switch, dioda_punjenje);

	input clk;
	input ir_pumpa;
	
	output pumpa_switch;
	output dioda_punjenje;
	reg pumpa_switch;
	reg dioda_punjenje;
	
	reg[35:0] StepCounter = 32'b0;
	parameter[35:0] vrijeme_punjenja = 32'd700_000_000; //10s proracunat
	parameter[35:0] vrijeme_cekanja = 32'd400_000_000; //8s

	initial	  
	begin
		StepCounter <= 32'b0;
		pumpa_switch <= 1'b1; //obrnuta logika na releju
		dioda_punjenje <= 1'b1; //dioda sija kada je pumpa iskljucena
	end

	always @(posedge clk) 
	begin
		//---------------------PUNJENJE FLASE----------------------
		if ((ir_pumpa == 1'b0) && (StepCounter < vrijeme_punjenja))
		begin
			pumpa_switch <= 1'b0; //pumpa upaljena (obrnuta logika)
			dioda_punjenje <= 1'b0; //dioda ugasena kada pumpa radi
			StepCounter <= StepCounter + 1'b1;
		end
		
		//-----PUMPA UGASENA, CEKANJE DA SE FLASA POMJERI ISPRED IR SENZORA-----
		else if((ir_pumpa == 1'b0) && (StepCounter >= vrijeme_punjenja) && (StepCounter < (vrijeme_punjenja + vrijeme_cekanja)))
		begin
			pumpa_switch <= 1'b1; //pumpa ugasena (obrnuta logika)
			dioda_punjenje <= 1'b1; //dioda upaljena kada pumpa ne radi
			StepCounter <= StepCounter + 31'b1; 
			
			if (StepCounter == (vrijeme_cekanja + vrijeme_punjenja))
			begin
				pumpa_switch <= 1'b1; //pumpa ugasena (obrnuta logika)
				dioda_punjenje <= 1'b1; //dioda upaljena kada pumpa ne radi
				StepCounter <=32'b0;
			end	
		end
	end
	
endmodule 