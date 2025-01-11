module MEDIAN #(parameter WIDTH = 8 , N_PIXELS = 9)
            (input  logic  DSI,
             input  logic  CLK,
             input  logic  nRST,
             input  logic [WIDTH-1:0] DI,
             output logic [WIDTH-1:0] DO,
             output logic DSO
             );

logic BYP;
logic [32:0] i;
logic [32:0] skip;
logic [32:0] step;

assign BYP = DSI ? 1 : SEND;

assign DSO = (step == (((N_PIXELS-1)>>1) + 1)) ? 1 :0 ; 

always_ff @(CLK posedge or nRST negedge)
begin
    if(!nRST) 
    begin
        DI   <=0 ; 
        DSO  <=0 ;
        i    <= N_PIXELS - 1 ;
        step <= 1 ; 
        SEND <= 0 ;
        skip <= 0 ;
    end


    if (step == (((N_PIXELS-1)>>1) + 1))
    begin
        step <= 1 ;
    end


    if (!DSI)
    begin
        i <= i-1 ;
        if (i<=skip)
        begin
            skip<=skip+1;
            SEND <=1:
            i    <= N_PIXELS - 1 - step ;
            step <= step + 1 ;
        end
    end

    SEND <= !SEND;

end



 
MED MED1(.BYP(BYP)  ,  .DSI(DSI),  .CLK(CLK),  .DI(DI),  .DO(DO));














endmodule