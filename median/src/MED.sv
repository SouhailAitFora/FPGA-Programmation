module MED #(parameter WIDTH = 8 , N_PIXELS = 9)
            (input  logic  BYP  ,
             input  logic  DSI  ,
             input  logic  CLK,
             input logic [WIDTH-1:0] DI,
             output logic [WIDTH-1:0] DO);

logic [WIDTH-1:0] regs [N_PIXELS-1:0];
logic [WIDTH-1:0] A,B,MAX,MIN,O_MUX1,O_MUX2 ;

assign O_MUX1 = DSI ? DI : MIN ;

assign O_MUX2 = BYP ? regs[N_PIXELS-2] : MAX ; 

assign A  = regs[N_PIXELS-1] ;

assign B = regs[N_PIXELS-2] ;

assign DO = regs[N_PIXELS-1];

MCE #(.WIDTH(WIDTH)) I_MCE(.A(A), .B(B), .MAX(MAX), .MIN(MIN));

always_ff @(posedge CLK) 
begin
    regs[0] <= O_MUX1 ;
    for( int i = 0 ; i < N_PIXELS-2 ; i++)
    begin
        regs[i+1] <= regs[i];
    end
    regs[N_PIXELS-1] <= O_MUX2 ;
end

endmodule