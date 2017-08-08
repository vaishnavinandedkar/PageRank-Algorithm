module noc_router_project_req 
(input clk, input reset, 
 input writeE, 
 input writeW, 
 input writeS,
 input writeN, //write ports
 input [20:0] dataInE, 
 input [20:0] dataInW, 
 input [20:0] dataInS,
 input [20:0] dataInN, //write data ports
 output  [20:0] dataOutE,
 output  [20:0] dataOutW,
 output  [20:0] dataOutS,
 output  [20:0] dataOutN, //output ports
 output  fullE, 
 output   almost_fullE, 
 output   fullW, 
 output   almost_fullW, 
 output   fullS, 
 output   almost_fullS,
 output   fullN, 
 output   almost_fullN //full outputs from FIFOs
 );


wire readE, readW, readS, readN; //output from arbiter, input to FIFO
wire [20:0] dataOutFifoE, dataOutFifoW, dataOutFifoN,dataOutFifoS; //output from FIFO, input to arbiter
wire emptyE, almost_emptyE, emptyW, almost_emptyW, emptyS, almost_emptyS, emptyN, almost_emptyN; //output from FIFO, input to arbiter
wire [20:0] dataOutE_temp, dataOutW_temp, dataOutS_temp, dataOutN_temp; //output from arbiter, input to outport 

fifo_improved_project_req fifoE_req (clk,  reset,  writeE,  readE, dataInE, dataOutFifoE, fullE, almost_fullE, emptyE, almost_emptyE);

fifo_improved_project_req fifoW_req (clk,  reset,  writeW,  readW, dataInW, dataOutFifoW, fullW, almost_fullW, emptyW, almost_emptyW);

fifo_improved_project_req fifoS_req (clk,  reset,  writeS,  readS, dataInS, dataOutFifoS, fullS, almost_fullS, emptyS, almost_emptyS);

fifo_improved_project_req fifoN_req (clk,  reset,  writeN,  readN, dataInN, dataOutFifoN, fullN, almost_fullN, emptyN, almost_emptyN);

arbiter_req a(clk, reset, emptyE, almost_emptyE, dataOutFifoE, 
                      emptyW, almost_emptyW, dataOutFifoW,  
                      emptyS, almost_emptyS, dataOutFifoS,
                      emptyN, almost_emptyN, dataOutFifoN, 
                      readE, readW, readS, readN, 
		      dataOutE_temp, dataOutW_temp, dataOutS_temp, dataOutN_temp); 

 
outport_req o(clk, reset, dataOutE_temp, dataOutW_temp, dataOutS_temp, dataOutN_temp, dataOutE, dataOutW, dataOutS, dataOutN);

endmodule

module outport_req (input clk, input reset, 
	       input [20:0] dataOutE_temp, input [20:0] dataOutW_temp, input [20:0] dataOutS_temp, input [20:0] dataOutN_temp,
	       output reg [20:0] dataOutE, output reg [20:0] dataOutW, output reg [20:0] dataOutS, output reg [20:0] dataOutN);


always @ (posedge clk, posedge reset)begin

	if (reset) begin
		dataOutE <= 0;
		dataOutW <= 0;
		dataOutS <= 0;
		dataOutN <= 0;
	end
	else begin
		dataOutE <= dataOutE_temp;
	        dataOutW <= dataOutW_temp;
                dataOutS <= dataOutS_temp;
                dataOutN <= dataOutN_temp;
	end	
	
end

endmodule 	  


//this one does not dequeue items that are not transmitted
module arbiter_req (input clk, input reset, 
	        input emptyE, input almost_emptyE, input [20:0] dataInFifoE,
		input emptyW, input almost_emptyW, input [20:0] dataInFifoW,
		input emptyS, input almost_emptyS, input [20:0] dataInFifoS,
		input emptyN, input almost_emptyN, input [20:0] dataInFifoN,
		output reg readE, output reg readW, output reg readS, output reg readN,
		output reg [20:0] dataOutE_temp, output reg [20:0] dataOutW_temp, output reg [20:0] dataOutS_temp, output reg [20:0] dataOutN_temp);

localparam East = 2'b00, West = 2'b01, South = 2'b10, North = 2'b11;

reg [1:0] rrcounter;


always @(posedge clk, posedge reset) begin
if(reset) 
rrcounter=0;
else
rrcounter=rrcounter+1;
//if(rrcounter==2)
//rrcounter=3;
end


reg [20:0] dataE, dataW, dataS, dataN; 
reg [20:0] dataInPrevE, dataInPrevW, dataInPrevS, dataInPrevN; //stores data that was not transmitted

reg retainE, retainW, retainS, retainN;
reg retainPrevE, retainPrevW, retainPrevS, retainPrevN;

reg readE_temp, readW_temp, readS_temp, readN_temp;

reg portE, portW, portS, portN;
reg grantedE, grantedW, grantedS, grantedN;

//generates data at the dataInFifo* ports
always @ (posedge clk, posedge reset) begin

	if (reset) begin
		readE_temp <=1'b0;
		readW_temp <=1'b0;
		readS_temp <=1'b0;
		readN_temp <=1'b0;
	end
	else begin
		if ((almost_emptyE & readE) | (emptyE) )
			readE_temp <= 1'b0;
		else 
			readE_temp <= 1'b1;

		if ((almost_emptyW & readW) | (emptyW) )
			readW_temp <= 1'b0;
		else 
			readW_temp <= 1'b1;

		if ((almost_emptyS & readS) | (emptyS) )
			readS_temp <= 1'b0;
		else 
			readS_temp <= 1'b1;

		if ((almost_emptyN & readN) | (emptyN) )
			readN_temp <= 1'b0;
		else 
			readN_temp <= 1'b1;

	end

end

always @ (*) begin
	readE = readE_temp & (~retainE);
	readW = readW_temp & (~retainW);
	readS = readS_temp & (~retainS);
	readN = readN_temp & (~retainN);
end



always @ (posedge clk, posedge reset) begin
	if (reset) begin
		dataInPrevE <= 0;
		retainPrevE <= 0;
		dataInPrevW <= 0;
		retainPrevW <= 0;
		dataInPrevS <= 0;
		retainPrevS <= 0;
		dataInPrevN <= 0;
		retainPrevN <= 0;
	end
	else begin
		dataInPrevE <= dataE;//dataInFifoE;
		retainPrevE <= retainE;
		dataInPrevW <= dataW;//dataInFifoW;
		retainPrevW <= retainW;
		dataInPrevS <= dataS;//dataInFifoS;
		retainPrevS <= retainS;
		dataInPrevN <= dataN;//dataInFifoN;
		retainPrevN <= retainN;
	end
end 

always @ (*) begin

	dataE = retainPrevE? dataInPrevE: dataInFifoE;
	dataW = retainPrevW? dataInPrevW: dataInFifoW;
	dataS = retainPrevS? dataInPrevS: dataInFifoS;
	dataN = retainPrevN? dataInPrevN: dataInFifoN;

end

//Looks at data at the dataInFifo* ports and pushes them to the output
//crossbar + outputreg
always @ (*) begin
	portE=0;
	portW=0;
	portS=0;
	portN=0;

	grantedE=0; //Updated, but note that the original code was fine for static priority.
	retainE=0;

	grantedW=0;
	retainW=0;

	grantedS=0;
	retainS=0;

	grantedN=0;
	retainN=0;

	//Highest priority
	//Always granted if it needs a port



if(rrcounter == 3) begin
	
	if (dataE[0]==1) begin
		if (dataE[2:1]==East) begin
			dataOutE_temp = dataE;
			portE = 1;
		end
		if (dataE[2:1]==West) begin
			dataOutW_temp = dataE;
			portW = 1;
		end
		if (dataE[2:1]==South) begin
			dataOutS_temp = dataE;
			portS=1;
		end
		
		if (dataE[2:1]==North) begin
			dataOutN_temp = dataE;
			portN=1;
		end
	end

	if (dataW[0]==1) begin
		if ((dataW[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataW;
			portE = 1;
			grantedW=1; 
		end
		if ((dataW[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataW;
			portW = 1;
			grantedW=1;
		end
		if ((dataW[2:1]==South)&(~portS)) begin
			dataOutS_temp = dataW;
			portS=1;
			grantedW=1;
		end
		
		if ((dataW[2:1]==North)&(~portN)) begin
			dataOutN_temp = dataW;
			portN=1;
			grantedW=1;
		end
		if(grantedW==0)
			retainW=1;
	end

	if (dataS[0]==1) begin
		if ((dataS[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataS;
			portE = 1;
			grantedS=1; 
		end
		if ((dataS[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataS;
			portW = 1;
			grantedS=1;
		end
		if ((dataS[2:1]==South)&(~portS)) begin
			dataOutS_temp = dataS;
			portS=1;
			grantedS=1;
		end
		
		if ((dataS[2:1]==North)&(~portN)) begin
			dataOutN_temp = dataS;
			portN=1;
			grantedS=1;
		end
		if(grantedS==0)
			retainS=1;
	end
	
	
	if (dataN[0]==1) begin
		if ((dataN[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataN;
			portE = 1;
			grantedN=1; 
		end
		if ((dataN[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataN;
			portW = 1;
			grantedN=1;
		end
		if ((dataN[2:1]==South)&(~portS)) begin
			dataOutS_temp = dataN;
			portS=1;
			grantedN=1;
		end
		
		if ((dataN[2:1]==North)&(~portN)) begin
			dataOutN_temp = dataN;
			portN=1;
			grantedN=1;
		end
		if(grantedN==0)
			retainN=1;
	end
	
	
end

if(rrcounter == 2) begin
	
	if (dataW[0]==1) begin
		if (dataW[2:1]==East) begin
			dataOutE_temp = dataW;
			portE = 1;
		end
		if (dataW[2:1]==West) begin
			dataOutW_temp = dataW;
			portW = 1;
		end
		if (dataW[2:1]==South) begin
			dataOutS_temp = dataW;
			portS=1;
		end
		
		if (dataW[2:1]==North) begin
			dataOutN_temp = dataW;
			portN=1;
		end
	end

	if (dataS[0]==1) begin
		if ((dataS[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataS;
			portE = 1;
			grantedS=1; 
		end
		if ((dataS[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataS;
			portW = 1;
			grantedS=1;
		end
		if ((dataS[2:1]==South)&(~portS)) begin
			dataOutS_temp = dataS;
			portS=1;
			grantedS=1;
		end
		
		if ((dataS[2:1]==North)&(~portN)) begin
			dataOutN_temp = dataS;
			portN=1;
			grantedS=1;
		end
		if(grantedS==0)
			retainS=1;
	end

	if (dataN[0]==1) begin
		if ((dataN[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataN;
			portE = 1;
			grantedN=1; 
		end
		if ((dataN[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataN;
			portW = 1;
			grantedN=1;
		end
		if ((dataN[2:1]==South)&(~portS)) begin
			dataOutS_temp = dataN;
			portS=1;
			grantedN=1;
		end
		
		if ((dataN[2:1]==North)&(~portN)) begin
			dataOutN_temp = dataN;
			portN=1;
			grantedN=1;
		end
		if(grantedN==0)
			retainN=1;
	end
	
	

	if (dataE[0]==1) begin
		if ((dataE[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataE;
			portE = 1;
			grantedE=1; 
		end
		if ((dataE[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataE;
			portW = 1;
			grantedE=1;
		end
		if ((dataE[2:1]==South)&(~portS)) begin
			dataOutS_temp = dataE;
			portS=1;
			grantedE=1;
		end
		
		if ((dataE[2:1]==North)&(~portN)) begin
			dataOutN_temp = dataE;
			portN=1;
			grantedE=1;
		end
		if(grantedE==0)
			retainE=1;
	end
	
	
end
if(rrcounter == 1) begin
	
	if (dataS[0]==1) begin
		if (dataS[2:1]==East) begin
			dataOutE_temp = dataS;
			portE = 1;
		end
		if (dataS[2:1]==West) begin
			dataOutW_temp = dataS;
			portW = 1;
		end
		if (dataS[2:1]==South) begin
			dataOutS_temp = dataS;
			portS=1;
		end
		
		if (dataS[2:1]==North) begin
			dataOutN_temp = dataS;
			portN=1;
		end
	end

	if (dataN[0]==1) begin
		if ((dataN[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataN;
			portE = 1;
			grantedN=1; 
		end
		if ((dataN[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataN;
			portW = 1;
			grantedN=1;
		end
		if ((dataN[2:1]==South)&(~portN)) begin
			dataOutS_temp = dataN;
			portS=1;
			grantedN=1;
		end
		
		if ((dataN[2:1]==North)&(~portN)) begin
			dataOutN_temp = dataN;
			portN=1;
			grantedN=1;
		end
		if(grantedN==0)
			retainN=1;
	end

	if (dataE[0]==1) begin
		if ((dataE[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataE;
			portE = 1;
			grantedE=1; 
		end
		if ((dataE[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataE;
			portW = 1;
			grantedE=1;
		end
		if ((dataE[2:1]==South)&(~portS)) begin
			dataOutS_temp = dataE;
			portS=1;
			grantedE=1;
		end
		
		if ((dataE[2:1]==North)&(~portN)) begin
			dataOutN_temp = dataE;
			portN=1;
			grantedE=1;
		end
		if(grantedE==0)
			retainE=1;
	end
	
	
	if (dataW[0]==1) begin
		if ((dataW[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataW;
			portE = 1;
			grantedW=1; 
		end
		if ((dataW[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataW;
			portW = 1;
			grantedW=1;
		end
		if ((dataW[2:1]==South)&(~portS)) begin
			dataOutS_temp = dataW;
			portS=1;
			grantedW=1;
		end
		
		if ((dataW[2:1]==North)&(~portN)) begin
			dataOutN_temp = dataW;
			portN=1;
			grantedW=1;
		end
		if(grantedW==0)
			retainW=1;
	end
	
	
end
if(rrcounter == 0) begin
	
	if (dataN[0]==1) begin
		if (dataN[2:1]==East) begin
			dataOutE_temp = dataN;
			portE = 1;
		end
		if (dataN[2:1]==West) begin
			dataOutW_temp = dataN;
			portW = 1;
		end
		if (dataN[2:1]==South) begin
			dataOutS_temp = dataN;
			portS=1;
		end
		
		if (dataN[2:1]==North) begin
			dataOutN_temp = dataN;
			portN=1;
		end
	end

	if (dataE[0]==1) begin
		if ((dataE[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataE;
			portE = 1;
			grantedE=1; 
		end
		if ((dataE[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataE;
			portW = 1;
			grantedE=1;
		end
		if ((dataE[2:1]==South)&(~portS)) begin
			dataOutS_temp = dataE;
			portS=1;
			grantedE=1;
		end
		
		if ((dataE[2:1]==North)&(~portN)) begin
			dataOutN_temp = dataE;
			portN=1;
			grantedE=1;
		end
		if(grantedE==0)
			retainE=1;
	end

	if (dataW[0]==1) begin
		if ((dataW[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataW;
			portE = 1;
			grantedW=1; 
		end
		if ((dataW[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataW;
			portW = 1;
			grantedW=1;
		end
		if ((dataW[2:1]==South)&(~portS))begin
			dataOutS_temp = dataW;
			portS=1;
			grantedW=1;
		end
		
		if ((dataW[2:1]==North)&(~portN)) begin
			dataOutN_temp = dataW;
			portN=1;
			grantedW=1;
		end
		if(grantedW==0)
			retainW=1;
	end
	
	
	if (dataS[0]==1) begin
		if ((dataS[2:1]==East)&(~portE)) begin
			dataOutE_temp = dataS;
			portE = 1;
			grantedS=1; 
		end
		if ((dataS[2:1]==West)&(~portW)) begin
			dataOutW_temp = dataS;
			portW = 1;
			grantedS=1;
		end
		if ((dataS[2:1]==South)&(~portS)) begin
			dataOutS_temp = dataS;
			portS=1;
			grantedS=1;
		end
		
		if ((dataS[2:1]==North)&(~portN)) begin
			dataOutN_temp = dataS;
			portN=1;
			grantedS=1;
		end
		if(grantedS==0)
			retainS=1;
	end
	
	
end
end
		
endmodule
