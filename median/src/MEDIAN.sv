module MEDIAN #(parameter WIDTH = 8 , N_PIXELS = 9)
            (input  logic  DSI,
             input  logic  CLK,
             input  logic  nRST,
             input  logic [WIDTH-1:0] DI,
             output logic [WIDTH-1:0] DO,
             output logic DSO
             );

logic BYP,BYP_tri;
int counter_step ,counter_clk;

assign BYP = DSI ? 1 : BYP_tri ;

always_ff@(posedge CLK, negedge nRST)
begin
    
    if(!nRST)
    begin
        counter_step <= 8;
        counter_clk  <= 0;
        BYP_tri      <= 0;
    end

    if (!DSI)
    begin
        counter_clk <= counter_clk + 1 ;
        
        if(counter_clk < counter_step)
        begin
            BYP_tri <= 0; 
        end
        
        else if (counter_clk == 9) 
        begin

            counter_step <= counter_step - 1 ;
            counter_clk  <= 0 ;    

            if (counter_step ==4 )
            begin
                DSO <= 1 ;
            end    

        end

        else if(counter_step > 4)
        begin
            BYP_tri <= 1 ;    
        end

    end
end 

always@(negedge DSI)
begin
    @(posedge CLK);
    for (i = N_PIXELS - 1; i > 4; i--) begin

            BYP = 0;
            for (j = 0; j < i; j++) @(posedge CLK);
            
            BYP = 1;
            for (j = i; j < N_PIXELS; j++) @(posedge CLK);
    end

    BYP = 0;
    for (j = 0; j < ((N_PIXELS - 1) >> 1); j++) @(posedge CLK);
    @(posedge CLK);
    DSO = 1;
    @(posedge CLK);
    DSO = 0;
end

always@(posedge clk)
begin
    if(!DSI)
    begin

    end
end 
MED MED1(.BYP(BYP)  ,  .DSI(DSI),  .CLK(CLK),  .DI(DI),  .DO(DO));

endmodule