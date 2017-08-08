//Read more details on the pagerank algorithm here.
//http://www.math.cornell.edu/~mec/Winter2009/RalucaRemus/Lecture3/lecture3.html
//The data in this example are based on the example in the link above.

module pageRank_project #(parameter N=64, WIDTH1=16)
(
input clk,
input reset,
input [N*N-1:0] adjacency,
input [N*WIDTH1-1:0] weights,
output reg [WIDTH1-1:0] node0Val,
output reg [10*WIDTH1-1:0] top10Vals,
output reg  [10*6-1:0] top10IDs,
output reg done
);


reg writeE1, writeW1, writeS1, writeN1;
reg [20:0] dataInE1, dataInW1, dataInS1, dataInN1;
wire [20:0] dataOutE1, dataOutW1, dataOutS1, dataOutN1;
wire fullE1, fullW1, fullS1, fullN1;
wire almost_fullE1, almost_fullW1, almost_fullS1, almost_fullN1;

reg writeE_resp, writeW_resp, writeS_resp, writeN_resp;
reg [20:0] dataInE_resp, dataInW_resp, dataInS_resp, dataInN_resp;
wire [20:0] dataOutE_resp, dataOutW_resp, dataOutS_resp, dataOutN_resp;
wire fullE_resp, fullW_resp, fullS_resp, fullN_resp;
wire almost_fullE_resp, almost_fullW_resp, almost_fullS_resp, almost_fullN_resp;





noc_router_project_req noc_req (.clk(clk), .reset(reset),  
          .writeE(writeE1), .writeW(writeW1), .writeS(writeS1), .writeN(writeN1), //input write ports
          .dataInE(dataInE1), .dataInW(dataInW1), .dataInS(dataInS1), .dataInN(dataInN1), //input write data ports
          .dataOutE(dataOutE1), .dataOutW(dataOutW1), .dataOutS(dataOutS1), .dataOutN(dataOutN1), //output ports
          .fullE(fullE1), .almost_fullE(almost_fullE1), .fullW(fullW1), .almost_fullW(almost_fullW1), .fullS(fullS1), .almost_fullS(almost_fullS1), .fullN(fullN1), .almost_fullN(almost_fullN1) //full outputs from FIFOs
);

noc_router_project_resp noc1_resp (.clk(clk), .reset(reset),  
          .writeE(writeE_resp), .writeW(writeW_resp), .writeS(writeS_resp), .writeN(writeN_resp), //input write ports
          .dataInE(dataInE_resp), .dataInW(dataInW_resp), .dataInS(dataInS_resp), .dataInN(dataInN_resp), //input write data ports
          .dataOutE(dataOutE_resp), .dataOutW(dataOutW_resp), .dataOutS(dataOutS_resp), .dataOutN(dataOutN_resp), //output ports
          .fullE(fullE_resp), .almost_fullE(almost_fullE_resp), .fullW(fullW_resp), .almost_fullW(almost_fullW_resp), .fullS(fullS_resp), .almost_fullS(almost_fullS_resp), .fullN(fullN_resp), .almost_fullN(almost_fullN_resp) 
);


//We will use a 16 bit fixed point representation throughout.
//All values are in the range [0,(2^16-1)/2^16]. 
// For example, the 16 bit value 2'h11 corresponds to (2^16-1)/2^16.

localparam d = 16'h2666;   //d = 0.15
localparam dn = 16'h009a; // d/N : NOTE --- please update based on N
localparam db = 16'hd99a; //1-d: NOTE: --- please update based on d 

reg [WIDTH1-1:0] nodeVal [N-1:0]; //value of each node
reg [WIDTH1-1:0] nodeVal_next0 [N-1:0];
reg [WIDTH1-1:0] nodeVal_next1 [N-1:0]; 
reg [WIDTH1-1:0] nodeVal_next2 [N-1:0]; 
reg [WIDTH1-1:0] nodeVal_next3 [N-1:0];  //next state node value
reg [WIDTH1-1:0] nodeWeight [N-1:0]; //weight of each node
reg adj [N-1:0] [N-1:0]; //adjacency matrix

reg [WIDTH1-1:0] nodeValsort [N-1:0];
reg [WIDTH1-1:0] id1 [N-1:0];

//reg disableE, disableW, disableS, disableN;

reg disableme;
reg [1:0]id;
reg [5:0] sel0;
reg [5:0] sel1;
reg [5:0] sel2;
reg [5:0] sel3;
reg [1:0] port0;
reg [1:0] port1;
reg [1:0] port2;
reg [1:0] port3; //L,E,W//update for 4 ports
reg [1:0] count0;
reg [1:0] count1;
reg [1:0] count2;
reg [1:0] count3;
reg [5:0] dest0; 
reg [5:0] dest1; 
reg [5:0] dest2; 
reg [5:0] dest3; //3 bits of data address// make 4 bits to represent 16 reg.



reg [N-1:0] i,j,k,p,q,r,a,v,c,b,v1,l,y,z,k1,k2,k3,j1,j2,j3,j4,j5,j6,j7,j8,b1;
reg [N-1:0] count_1;
integer sort1;

reg [3*WIDTH1-1:0] temp0; //16bit*16bit*16bit
reg [3*WIDTH1-1:0] temp1; //16bit*16bit*16bit
reg [3*WIDTH1-1:0] temp2; //16bit*16bit*16bit
reg [3*WIDTH1-1:0] temp3; //16bit*16bit*16bit

//Convert adj from 1D to 2D array
always @ (*) begin
	count_1 = 0;
	for (p=0; p<N; p=p+1) begin
		for (q=0; q<N; q=q+1) begin
			adj[p][q] = adjacency[count_1];
			count_1 = count_1 + 1;
		end
	end
end

//Convert nodeWeights from 1D to 2D array
always @ (*) begin
	for (r=0; r<N; r=r+1) begin
		nodeWeight[r] = weights[r*WIDTH1+:WIDTH1];
	end
end


//reg [WIDTH-1:0] node0Val;
reg [WIDTH1-1:0] node1Val;
reg [WIDTH1-1:0] node2Val;
reg [WIDTH1-1:0] node3Val;
reg [WIDTH1-1:0] node4Val;
reg [WIDTH1-1:0] node5Val;
reg [WIDTH1-1:0] node6Val;
reg [WIDTH1-1:0] node7Val;
reg [WIDTH1-1:0] node8Val;
reg [WIDTH1-1:0] node9Val;
reg [WIDTH1-1:0] node10Val;
reg [WIDTH1-1:0] node11Val;
reg [WIDTH1-1:0] node12Val;
reg [WIDTH1-1:0] node13Val;
reg [WIDTH1-1:0] node14Val;
reg [WIDTH1-1:0] node15Val;
reg [WIDTH1-1:0] node16Val;
reg [WIDTH1-1:0] node17Val;
reg [WIDTH1-1:0] node18Val;
reg [WIDTH1-1:0] node19Val;
reg [WIDTH1-1:0] node20Val;
reg [WIDTH1-1:0] node21Val;
reg [WIDTH1-1:0] node22Val;
reg [WIDTH1-1:0] node23Val;
reg [WIDTH1-1:0] node24Val;
reg [WIDTH1-1:0] node25Val;
reg [WIDTH1-1:0] node26Val;
reg [WIDTH1-1:0] node27Val;
reg [WIDTH1-1:0] node28Val;
reg [WIDTH1-1:0] node29Val;
reg [WIDTH1-1:0] node30Val;
reg [WIDTH1-1:0] node31Val;
reg [WIDTH1-1:0] node32Val;
reg [WIDTH1-1:0] node33Val;
reg [WIDTH1-1:0] node34Val;
reg [WIDTH1-1:0] node35Val;
reg [WIDTH1-1:0] node36Val;
reg [WIDTH1-1:0] node37Val;
reg [WIDTH1-1:0] node38Val;
reg [WIDTH1-1:0] node39Val;
reg [WIDTH1-1:0] node40Val;
reg [WIDTH1-1:0] node41Val;
reg [WIDTH1-1:0] node42Val;
reg [WIDTH1-1:0] node43Val;
reg [WIDTH1-1:0] node44Val;
reg [WIDTH1-1:0] node45Val;
reg [WIDTH1-1:0] node46Val;
reg [WIDTH1-1:0] node47Val;
reg [WIDTH1-1:0] node48Val;
reg [WIDTH1-1:0] node49Val;
reg [WIDTH1-1:0] node50Val;
reg [WIDTH1-1:0] node51Val;
reg [WIDTH1-1:0] node52Val;
reg [WIDTH1-1:0] node53Val;
reg [WIDTH1-1:0] node54Val;
reg [WIDTH1-1:0] node55Val;
reg [WIDTH1-1:0] node56Val;
reg [WIDTH1-1:0] node57Val;
reg [WIDTH1-1:0] node58Val;
reg [WIDTH1-1:0] node59Val;
reg [WIDTH1-1:0] node60Val;
reg [WIDTH1-1:0] node61Val;
reg [WIDTH1-1:0] node62Val;
reg [WIDTH1-1:0] node63Val;



always @ (*) begin
node0Val = nodeVal[0];
node1Val = nodeVal[1];
node2Val = nodeVal[2];
node3Val = nodeVal[3];
node4Val = nodeVal[4];
node5Val = nodeVal[5];
node6Val = nodeVal[6];
node7Val = nodeVal[7];
node8Val = nodeVal[8];
node9Val = nodeVal[9];
node10Val = nodeVal[10];
node11Val = nodeVal[11];
node12Val = nodeVal[12];
node13Val = nodeVal[13];
node14Val = nodeVal[14];
node15Val = nodeVal[15];
node16Val = nodeVal[16];
node17Val = nodeVal[17];
node18Val = nodeVal[18];
node19Val = nodeVal[19];
node20Val = nodeVal[20];
node21Val = nodeVal[21];
node22Val = nodeVal[22];
node23Val = nodeVal[23];
node24Val = nodeVal[24];
node25Val = nodeVal[25];
node26Val = nodeVal[26];
node27Val = nodeVal[27];
node28Val = nodeVal[28];
node29Val = nodeVal[29];
node30Val = nodeVal[30];
node31Val = nodeVal[31];
node32Val = nodeVal[32];
node33Val = nodeVal[33];
node34Val = nodeVal[34];
node35Val = nodeVal[35];
node36Val = nodeVal[36];
node37Val = nodeVal[37];
node38Val = nodeVal[38];
node39Val = nodeVal[39];
node40Val = nodeVal[40];
node41Val = nodeVal[41];
node42Val = nodeVal[42];
node43Val = nodeVal[43];
node44Val = nodeVal[44];
node45Val = nodeVal[45];
node46Val = nodeVal[46];
node47Val = nodeVal[47];
node48Val = nodeVal[48];
node49Val = nodeVal[49];
node50Val = nodeVal[50];
node51Val = nodeVal[51];
node52Val = nodeVal[52];
node53Val = nodeVal[53];
node54Val = nodeVal[54];
node55Val = nodeVal[55];
node56Val = nodeVal[56];
node57Val = nodeVal[57];
node58Val = nodeVal[58];
node59Val = nodeVal[59];
node60Val = nodeVal[60];
node61Val = nodeVal[61];
node62Val = nodeVal[62];
node63Val = nodeVal[63];

end




//always@(*)
//begin
//	l=0;
//	for (y=0; y<N; y=y+1)
//	begin
//		for (z=0; z<WIDTH; z=z+1)
//		begin
//			top10Vals[y*z+:z] = nodeVal[y];
//			top10IDs[y*6+:6] = y;
//			l=l+1;
//		end
//	end
//end

always @ (*) begin
//if (c=8) begin 
	for (v=0; v<64; v=v+1) begin
		//NOTE: Here we are simply using the first 10 nodes as an example.
		// Your implementation must return the actual top 10 node vals and IDs.	

		top10Vals[v*WIDTH1+:WIDTH1] = nodeValsort[v];
			
		top10IDs[v*6+:6] = v;
	end

if (c == 10) begin
done=1;
for (sort1=0;sort1<N;sort1=sort1+1)begin
nodeValsort[sort1] = nodeVal[sort1];
//new
id1[sort1]= sort1;
//new
end
end


//array sorting
for (v=0;v<N;v=v+1)begin
//
      for (b=N-1; b>v;b=b-1) begin
           
        if (nodeValsort[b] > nodeValsort[b-1]) begin
	b1= id1[b-1];
	v1=nodeValsort[b-1];
        nodeValsort[b-1] = nodeValsort[b];
	id1[b-1] = id1[b];
	id1[b] = b1;
	nodeValsort[b] = v1;
	end
      end

end
//end
end

//always @ (posedge clk, posedge reset) begin
//if (reset)
//port = 0;
//else begin

//if (id == 0)
//port = 1;
//else if (id == 1)
//port = 2;
//else if (id == 2)
//port = 3;
//if (id == 3)
//port = 0;
//end
//end



//Combinational logic
always @ (posedge clk, posedge reset) begin

if (reset) begin
 		dataInE_resp <= 0;
		writeE_resp <= 0;
 		dataInW_resp <= 0;
		writeW_resp <= 0;
 		dataInS_resp <= 0;
		writeS_resp <= 0;
 		dataInN_resp <= 0;
		writeN_resp <= 0;
		dataInE1 <=0;
		writeE1 <=0;
		dataInW1 <=0;
		writeW1 <=0;
		dataInS1 <=0;
		writeS1 <=0;
		dataInN1 <=0;
		writeN1 <=0;
		count0 <=0;
		dest0 <=0; 
		count1 <=0;
		dest1 <=0; 
		count2 <=0;
		dest2 <=0; 
		count3 <=0;
		dest3 <=0; 
		done <=0;
end
else begin
	//For each node
	//for (j=0; j<N; j=j+1) begin
if (a==64)
c=c+1;

if(a==64)
a=0;

j=a;


if (c<10)begin
if (j<16) begin

		//initialize next state node val
		nodeVal_next0[j] = dn;
		//Go through adjacency matrix to find node's neighbours
		for (k=0; k<N; k=k+1) begin
			
			if(k<16) begin//point to point
			if(adj[j][k]==1'b1) begin	
							
				//Add db*nodeval[k]*nodeWeight[k]
				temp0 = db * nodeWeight[k] * nodeVal[k];
				nodeVal_next0[j] = nodeVal_next0[j] + temp0[47:32];
				j1 = j;
				end
				end
			else if(k>16) begin
			
			if(adj[j1][k]==1'b1) begin
									
if((k>16) && (k<32))
port0 = 01;
else if((k>32) && (k<48))
port0 = 10;
else if((k>48) && (k<64))
port0 = 11;


disableme = 0;
id = 2'b00;

	
		if (disableme)
			writeE1 = 1'b0;
		if (count0==2'b11) begin //every 4 cycles
			if ((writeE1 & almost_fullE1)|(~writeE1 & fullE1)| disableme) // note that just checking for full should be fine
				writeE1 <=1'b0;
			else begin //issue a new request
				writeE1 <= 1'b1;
				dataInE1 <= {dest0,id,port0,1'b1}; //Request new data from port
				count0 <= count0 + 1;
				dest0 <= dest0 + 1;
			end
		end 
		else begin
			count0 <= count0 + 1;
			writeE1 <= 1'b0;
		end
	


			
//wire [10:0] myData [15:0]; //8 11-bit registers


 sel0 = dataOutE1[10:5];

if (dataOutE1[4:3]== 01) begin


		//dataInE_resp <= 0;
		//writeE_resp <= 0; reset later

		if (disableme) begin
			writeE_resp <=1'b0;
		end
		if (dataOutE1[0]) begin //if valid data
		//if (dataOutE1[0] == 1) begin
case(sel0)

16: begin dataInE_resp = {nodeVal[16],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
17: begin dataInE_resp = {nodeVal[17],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
18: begin dataInE_resp = {nodeVal[18],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
19: begin dataInE_resp = {nodeVal[19],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
20: begin dataInE_resp = {nodeVal[20],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
21: begin dataInE_resp = {nodeVal[21],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
22: begin dataInE_resp = {nodeVal[22],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
23: begin dataInE_resp = {nodeVal[23],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
24: begin dataInE_resp = {nodeVal[24],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
25: begin dataInE_resp = {nodeVal[25],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
26: begin dataInE_resp = {nodeVal[26],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
27: begin dataInE_resp = {nodeVal[27],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
28: begin dataInE_resp = {nodeVal[28],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
29: begin dataInE_resp = {nodeVal[29],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
30: begin dataInE_resp = {nodeVal[30],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
31: begin dataInE_resp = {nodeVal[31],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end

endcase
end
end
//secomd port
else if (dataOutE1[4:3]== 10) begin


		//dataInE_resp <= 0;
		//writeE_resp <= 0; reset later

		if (disableme) begin
			writeE_resp <=1'b0;
		end
		//if (dataOutE[0]) begin //if valid data
		if (dataOutE1[0] == 1) begin
case(sel0)

32: begin dataInE_resp = {nodeVal[32],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
33: begin dataInE_resp = {nodeVal[33],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
34: begin dataInE_resp = {nodeVal[34],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
35: begin dataInE_resp = {nodeVal[35],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
36: begin dataInE_resp = {nodeVal[36],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
37: begin dataInE_resp = {nodeVal[37],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
38: begin dataInE_resp = {nodeVal[38],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
39: begin dataInE_resp = {nodeVal[39],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
40: begin dataInE_resp = {nodeVal[40],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
41: begin dataInE_resp = {nodeVal[41],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
42: begin dataInE_resp = {nodeVal[42],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
43: begin dataInE_resp = {nodeVal[43],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
44: begin dataInE_resp = {nodeVal[44],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
45: begin dataInE_resp = {nodeVal[45],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
46: begin dataInE_resp = {nodeVal[46],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
47: begin dataInE_resp = {nodeVal[47],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end

endcase
end
end

//third port

else if (dataOutE1[4:3]== 11) begin


		//dataInE_resp <= 0;
		//writeE_resp <= 0; reset later

		if (disableme) begin
			writeE_resp <=1'b0;
		end
		if (dataOutE1[0]) begin //if valid data
		//if (dataOutE[0] == 1) begin
case(sel0)

48: begin dataInE_resp = {nodeVal[48],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
49: begin dataInE_resp = {nodeVal[49],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
50: begin dataInE_resp = {nodeVal[50],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
51: begin dataInE_resp = {nodeVal[51],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
52: begin dataInE_resp = {nodeVal[52],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
53: begin dataInE_resp = {nodeVal[53],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
54: begin dataInE_resp = {nodeVal[54],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
55: begin dataInE_resp = {nodeVal[55],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
56: begin dataInE_resp = {nodeVal[56],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
57: begin dataInE_resp = {nodeVal[57],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
58: begin dataInE_resp = {nodeVal[58],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
59: begin dataInE_resp = {nodeVal[59],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
60: begin dataInE_resp = {nodeVal[60],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
61: begin dataInE_resp = {nodeVal[61],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
62: begin dataInE_resp = {nodeVal[62],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end
63: begin dataInE_resp = {nodeVal[63],dataOutE1[4:3],dataOutE1[2:1],1'b1}; writeE_resp = 1; end

endcase
end


			
				end
				temp0 = db * nodeWeight[k] * dataInE_resp [20:5];
				nodeVal_next0[j1] = nodeVal_next0[j1] + temp0[47:32];

				end
	
end
end
end
//end

//second pagerank 16 to 32
if((j>15) && (j<32)) begin

//initialize next state node val
		nodeVal_next1[j] = dn;
		//Go through adjacency matrix to find node's neighbours
		for (k1=0; k1<N; k1=k1+1) begin

				if((k1>15) && (k1<32)) begin
				if(adj[j][k1]==1'b1) begin
				//Add db*nodeval[k]*nodeWeight[k]
				temp1 = db * nodeWeight[k1] * nodeVal[k1];
				nodeVal_next1[j] = nodeVal_next1[j] + temp1[47:32]; 
				j2 = j;
				end
				end
				else if(~((k1>15) && (k1<32))) begin
				if(adj[j2][k1]==1'b1) begin
			
				//temp1 = db*dataIn_resp;//later
							
					
if(k1<16) 
port1 = 00;
else if((k1>32) && (k1<48))
port1 = 10;
else if((k1>48) && (k1<64))
port1 = 11;


disableme = 0;
id = 2'b01;


		//dataInE <=0;
		//writeE <=0;
		//count <=0;
		//dest <=0; reset later
	
		if (disableme)
			writeW1 = 1'b0;
		if (count1==2'b11) begin //every 4 cycles
			if ((writeW1 & almost_fullW1)|(~writeW1 & fullW1)| disableme) // note that just checking for full should be fine
				writeW1 <=1'b0;
			else begin //issue a new request
				writeW1 <= 1'b1;
				dataInW1 <= {dest1,id,port1,1'b1}; //Request new data from port
				count1 <= count1 + 1;
				dest1 <= dest1 + 1;
			end
		end 
		else begin
			count1 <= count1 + 1;
			writeW1 <= 1'b0;
		end
	

			
//wire [10:0] myData [15:0]; //8 11-bit registers


 sel1 = dataOutW1[10:5];

if (dataOutW1[4:3]== 00) begin


		//dataInE_resp <= 0;
		//writeE_resp <= 0; reset later

		if (disableme) begin
			writeW_resp <=1'b0;
		end
		if (dataOutW1[0]) begin //if valid data
		//if (dataOutW1[0] == 1) begin
case(sel1)

0: begin dataInW_resp <= {nodeVal[0],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
1: begin dataInW_resp <= {nodeVal[1],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
2: begin dataInW_resp <= {nodeVal[2],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
3: begin dataInW_resp <= {nodeVal[3],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
4: begin dataInW_resp <= {nodeVal[4],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
5: begin dataInW_resp <= {nodeVal[5],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
6: begin dataInW_resp <= {nodeVal[6],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
7: begin dataInW_resp <= {nodeVal[7],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
8: begin dataInW_resp <= {nodeVal[8],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
9: begin dataInW_resp <= {nodeVal[9],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
10: begin dataInW_resp <= {nodeVal[10],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
11: begin dataInW_resp <= {nodeVal[11],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
12: begin dataInW_resp <= {nodeVal[12],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
13: begin dataInW_resp <= {nodeVal[13],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
14: begin dataInW_resp <= {nodeVal[14],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
15: begin dataInW_resp <= {nodeVal[15],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end

endcase
end
end
//secomd port
else if (dataOutW1[4:3]== 10) begin


		//dataInE_resp <= 0;
		//writeE_resp <= 0; reset later

		if (disableme) begin
			writeW_resp <=1'b0;
		end
		if (dataOutW1[0]) begin //if valid data
		//if (dataOutE[0] == 1) begin
case(sel1)

32: begin dataInW_resp <= {nodeVal[32],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
33: begin dataInW_resp <= {nodeVal[33],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
34: begin dataInW_resp <= {nodeVal[34],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
35: begin dataInW_resp <= {nodeVal[35],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
36: begin dataInW_resp <= {nodeVal[36],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
37: begin dataInW_resp <= {nodeVal[37],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
38: begin dataInW_resp <= {nodeVal[38],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
39: begin dataInW_resp <= {nodeVal[39],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
40: begin dataInW_resp <= {nodeVal[40],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
41: begin dataInW_resp <= {nodeVal[41],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
42: begin dataInW_resp <= {nodeVal[42],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
43: begin dataInW_resp <= {nodeVal[43],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
44: begin dataInW_resp <= {nodeVal[44],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
45: begin dataInW_resp <= {nodeVal[45],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
46: begin dataInW_resp <= {nodeVal[46],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
47: begin dataInW_resp <= {nodeVal[47],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end

endcase
end
end

//third port

if (dataOutW1[4:3]== 11) begin


		//dataInE_resp <= 0;
		//writeE_resp <= 0; reset later

		if (disableme) begin
			writeW_resp <=1'b0;
		end
		if (dataOutW1[0]) begin //if valid data
		//if (dataOutW[0] == 1) begin
case(sel1)

48: begin dataInW_resp <= {nodeVal[48],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
49: begin dataInW_resp <= {nodeVal[49],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
50: begin dataInW_resp <= {nodeVal[50],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
51: begin dataInW_resp <= {nodeVal[51],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
52: begin dataInW_resp <= {nodeVal[52],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
53: begin dataInW_resp <= {nodeVal[53],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
54: begin dataInW_resp <= {nodeVal[54],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
55: begin dataInW_resp <= {nodeVal[55],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
56: begin dataInW_resp <= {nodeVal[56],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
57: begin dataInW_resp <= {nodeVal[57],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
58: begin dataInW_resp <= {nodeVal[58],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
59: begin dataInW_resp <= {nodeVal[59],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
60: begin dataInW_resp <= {nodeVal[60],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
61: begin dataInW_resp <= {nodeVal[61],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
62: begin dataInW_resp <= {nodeVal[62],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end
63: begin dataInW_resp <= {nodeVal[63],dataOutW1[4:3],dataOutW1[2:1],1'b1}; writeW_resp <= 1; end

			endcase
		end
	end
			temp1 = db * nodeWeight[k1] * dataInW_resp[20:5];
			nodeVal_next1[j2] = nodeVal_next1[j2] + temp1[47:32]; 

end

end
end
end
//end

if((j>31) && (j<48)) begin

		//initialize next state node val
		nodeVal_next2[j] = dn;
		//Go through adjacency matrix to find node's neighbours
		
		for (k2=0; k2<N; k2=k2+1) begin

			
				if((k2>31) && (k2<48)) begin
				if(adj[j][k2]==1'b1) begin
				//Add db*nodeval[k]*nodeWeight[k]
				temp2 = db * nodeWeight[k2] * nodeVal[k2];
				nodeVal_next2[j] = nodeVal_next2[j] + temp2[47:32]; 
				j3 = j;
				end
				end
				else if (~((k2>31) && (k2<48))) begin
				if(adj[j3][k2]==1'b1) begin
						
if(k2<16)
port2 = 00;					
else if((k2>16) && (k2<32))
port2 = 01;
else if((k2>48) && (k2<64))
port2 = 11;


disableme = 0;
id = 2'b10;


		//dataInE <=0;
		//writeE <=0;
		//count <=0;
		//dest <=0; reset later
	
		if (disableme)
			writeS1 = 1'b0;
		if (count2==2'b11) begin //every 4 cycles
			if ((writeS1 & almost_fullS1)|(~writeS1 & fullS1)| disableme) // note that just checking for full should be fine
				writeS1 <=1'b0;
			else begin //issue a new request
				writeS1 <= 1'b1;
				dataInS1 <= {dest2,id,port2,1'b1}; //Request new data from port
				count2 <= count2 + 1;
				dest2 <= dest2 + 1;
			end
		end 
		else begin
			count2 <= count2 + 1;
			writeS1 <= 1'b0;
		end


			
//wire [10:0] myData [15:0]; //8 11-bit registers


 sel2 = dataOutS1[10:5];

if (dataOutS1[4:3]== 00) begin


		//dataInE_resp <= 0;
		//writeE_resp <= 0; reset later

		if (disableme) begin
			writeS_resp <=1'b0;
		end
		if (dataOutS1[0]) begin //if valid data
		//if (dataOutS1[0] == 1) begin
case(sel2)

0: begin dataInS_resp <= {nodeVal[0],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
1: begin dataInS_resp <= {nodeVal[1],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
2: begin dataInS_resp <= {nodeVal[2],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
3: begin dataInS_resp <= {nodeVal[3],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
4: begin dataInS_resp <= {nodeVal[4],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
5: begin dataInS_resp <= {nodeVal[5],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
6: begin dataInS_resp <= {nodeVal[6],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
7: begin dataInS_resp <= {nodeVal[7],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
8: begin dataInS_resp <= {nodeVal[8],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
9: begin dataInS_resp <= {nodeVal[9],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
10: begin dataInS_resp <= {nodeVal[10],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
11: begin dataInS_resp <= {nodeVal[11],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
12: begin dataInS_resp <= {nodeVal[12],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
13: begin dataInS_resp <= {nodeVal[13],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
14: begin dataInS_resp <= {nodeVal[14],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
15: begin dataInS_resp <= {nodeVal[15],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end

endcase
end
end
//secomd port
else if (dataOutS1[4:3]== 01) begin


		//dataInS_resp <= 0;
		//writeS_resp <= 0; reset later

		if (disableme) begin
			writeS_resp <=1'b0;
		end
		if (dataOutS1[0]) begin //if valid data
		//if (dataOutS[0] == 1) begin
case(sel2)

16: begin dataInS_resp <= {nodeVal[16],dataOutS1[4:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
17: begin dataInS_resp <= {nodeVal[17],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
18: begin dataInS_resp <= {nodeVal[18],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
19: begin dataInS_resp <= {nodeVal[19],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
20: begin dataInS_resp <= {nodeVal[20],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
21: begin dataInS_resp <= {nodeVal[21],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
22: begin dataInS_resp <= {nodeVal[22],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
23: begin dataInS_resp <= {nodeVal[23],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
24: begin dataInS_resp <= {nodeVal[24],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
25: begin dataInS_resp <= {nodeVal[25],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
26: begin dataInS_resp <= {nodeVal[26],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
27: begin dataInS_resp <= {nodeVal[27],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
28: begin dataInS_resp <= {nodeVal[28],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
29: begin dataInS_resp <= {nodeVal[29],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
30: begin dataInS_resp <= {nodeVal[30],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
31: begin dataInS_resp <= {nodeVal[31],dataOutS1[2:1],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end

endcase
end
end

//third port

else if (dataOutS1[4:3]== 11) begin


		//dataInS_resp <= 0;
		//writeS_resp <= 0; reset later

		if (disableme) begin
			writeS_resp <=1'b0;
		end
		if (dataOutS1[0]) begin //if valid data
		//if (dataOutS[0] == 1) begin
case(sel2)

48: begin dataInS_resp <= {nodeVal[48],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
49: begin dataInS_resp <= {nodeVal[49],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
50: begin dataInS_resp <= {nodeVal[50],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
51: begin dataInS_resp <= {nodeVal[51],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
52: begin dataInS_resp <= {nodeVal[52],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
53: begin dataInS_resp <= {nodeVal[53],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
54: begin dataInS_resp <= {nodeVal[54],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
55: begin dataInS_resp <= {nodeVal[55],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
56: begin dataInS_resp <= {nodeVal[56],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
57: begin dataInS_resp <= {nodeVal[57],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
58: begin dataInS_resp <= {nodeVal[58],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
59: begin dataInS_resp <= {nodeVal[59],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
60: begin dataInS_resp <= {nodeVal[60],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
61: begin dataInS_resp <= {nodeVal[61],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
62: begin dataInS_resp <= {nodeVal[62],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end
63: begin dataInS_resp <= {nodeVal[63],dataOutS1[4:3],dataOutS1[2:1],1'b1}; writeS_resp <= 1; end

endcase
end


			
		end
	

			
			
				temp2 = db * nodeWeight[k2] * dataInS_resp[20:5];
				nodeVal_next2[j3] = nodeVal_next2[j3] + temp2[47:32];

				end


end
end


end




//fourth pagerank 48 to 63

//end


if((j>47) && (j<64)) begin
//initialize next state node val
		nodeVal_next3[j] = dn;
		//Go through adjacency matrix to find node's neighbours

		for (k3=0; k3<N; k3=k3+1) begin
			
				if((k3>47) && (k3<63)) begin
				if(adj[j][k3]==1'b1) begin
				//Add db*nodeval[k]*nodeWeight[k]
				temp3 = db * nodeWeight[k3] * nodeVal[k3];
				nodeVal_next3[j] = nodeVal_next3[j] + temp3[47:32];
				j4 = j;

				end
				end
				else if(~((k3>47) && (k3<63))) begin
				if(adj[j4][k3]==1'b1) begin
			
							
if(k3<16)
port3 = 00;				
else if((k3>16) && (k3<32))
port3 = 01;
else if((k3>32) && (k3<48))
port3 = 10;



disableme = 0;
id = 2'b11;


		//dataInE <=0;
		//writeE <=0;
		//count <=0;
		//dest <=0; reset later
	
		if (disableme)
			writeN1 = 1'b0;
		if (count3==2'b11) begin //every 4 cycles
			if ((writeN1 & almost_fullN1)|(~writeN1 & fullN1)| disableme) // note that just checking for full should be fine
				writeN1 <=1'b0;
			else begin //issue a new request
				writeN1 <= 1'b1;
				dataInN1 <= {dest3,id,port3,1'b1}; //Request new data from port
				count3 <= count3 + 1;
				dest3 <= dest3 + 1;
			end
		end 
		else begin
			count3 <= count3 + 1;
			writeN1 <= 1'b0;
		end

			
//wire [10:0] myData [15:0]; //8 11-bit registers


 sel3 = dataOutN1[10:5];

if (dataOutN1[4:3]== 00) begin


		//dataInE_resp <= 0;
		//writeE_resp <= 0; reset later

		if (disableme) begin
			writeN_resp <=1'b0;
		end
	else	if (dataOutN1[0]) begin //if valid data
		//if (dataOutN[0] == 1) begin
case(sel3)

0: begin dataInN_resp <= {nodeVal[0],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
1: begin dataInN_resp <= {nodeVal[1],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
2: begin dataInN_resp <= {nodeVal[2],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
3: begin dataInN_resp <= {nodeVal[3],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
4: begin dataInN_resp <= {nodeVal[4],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
5: begin dataInN_resp <= {nodeVal[5],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
6: begin dataInN_resp <= {nodeVal[6],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
7: begin dataInN_resp <= {nodeVal[7],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
8: begin dataInN_resp <= {nodeVal[8],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
9: begin dataInN_resp <= {nodeVal[9],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
10: begin dataInN_resp <= {nodeVal[10],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
11: begin dataInN_resp <= {nodeVal[11],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
12: begin dataInN_resp <= {nodeVal[12],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
13: begin dataInN_resp <= {nodeVal[13],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
14: begin dataInN_resp <= {nodeVal[14],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
15: begin dataInN_resp <= {nodeVal[15],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end

endcase
end
end
//secomd port
else if (dataOutN1[4:3]== 01) begin


		//dataInE_resp <= 0;
		//writeE_resp <= 0; reset later

		if (disableme) begin
			writeN_resp <=1'b0;
		end
		if (dataOutN1[0]) begin //if valid data
		//if (dataOutE[0] == 1) begin
case(sel3)

16: begin dataInN_resp <= {nodeVal[16],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
17: begin dataInN_resp <= {nodeVal[17],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
18: begin dataInN_resp <= {nodeVal[18],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
19: begin dataInN_resp <= {nodeVal[19],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
20: begin dataInN_resp <= {nodeVal[20],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
21: begin dataInN_resp <= {nodeVal[21],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
22: begin dataInN_resp <= {nodeVal[22],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
23: begin dataInN_resp <= {nodeVal[23],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
24: begin dataInN_resp <= {nodeVal[24],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
25: begin dataInN_resp <= {nodeVal[25],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
26: begin dataInN_resp <= {nodeVal[26],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
27: begin dataInN_resp <= {nodeVal[27],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
28: begin dataInN_resp <= {nodeVal[28],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
29: begin dataInN_resp <= {nodeVal[29],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
30: begin dataInN_resp <= {nodeVal[30],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
31: begin dataInN_resp <= {nodeVal[31],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end

endcase
end
end

//third port

else if (dataOutN1[4:3]== 10) begin


		//dataInE_resp <= 0;
		//writeE_resp <= 0; reset later

		if (disableme) begin
			writeN_resp <=1'b0;
		end
		if (dataOutN1[0]) begin //if valid data
		//if (dataOutN[0] == 1) begin
case(sel3)

32: begin dataInN_resp <= {nodeVal[32],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
33: begin dataInN_resp <= {nodeVal[33],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
34: begin dataInN_resp <= {nodeVal[34],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
35: begin dataInN_resp <= {nodeVal[35],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
36: begin dataInN_resp <= {nodeVal[36],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
37: begin dataInN_resp <= {nodeVal[37],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
38: begin dataInN_resp <= {nodeVal[38],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
39: begin dataInN_resp <= {nodeVal[39],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
40: begin dataInN_resp <= {nodeVal[40],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
41: begin dataInN_resp <= {nodeVal[41],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
42: begin dataInN_resp <= {nodeVal[42],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
43: begin dataInN_resp <= {nodeVal[43],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
44: begin dataInN_resp <= {nodeVal[44],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
45: begin dataInN_resp <= {nodeVal[45],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
46: begin dataInN_resp <= {nodeVal[46],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end
47: begin dataInN_resp <= {nodeVal[47],dataOutN1[4:3],dataOutN1[2:1],1'b1}; writeN_resp <= 1; end

endcase
end


			
		end
	

			
			
				temp3 = db * nodeWeight[k3] * dataInN_resp[20:5];
				nodeVal_next3[j4] = nodeVal_next3[j4] + temp3[47:32]; 

				end
end
end
end
end
end
end








always @ (posedge clk, posedge reset) begin
if(reset) begin
a<=0;
c<=0;
j<=0;
end
else
begin
a <= a+1;
//j=a;

end
end


//Next state = current state
always @ (posedge clk, posedge reset) begin
  if (reset) begin

	for (i=0; i<N; i=i+1) begin
		nodeVal[i] <= 16'h0400; // reset to (1/N) = 0.25. Note --- Please update based on N.
                nodeVal_next0[i] <= 16'h0400;
                nodeVal_next1[i] <= 16'h0400;
                nodeVal_next2[i] <= 16'h0400;
                nodeVal_next3[i] <= 16'h0400;	
	end
   end
     else begin

	for (i=0; i<N;i=i+1) begin
		if(i<16)	
		nodeVal[i] <= nodeVal_next0[i];
		if((i>16) && (j<32))	
		nodeVal[i] <= nodeVal_next1[i];
		if((i>32) && (j<48))	
		nodeVal[i] <= nodeVal_next2[i];
		if((i>48) && (j<64))	
		nodeVal[i] <= nodeVal_next3[i]; 
	end
     end

end	

endmodule

