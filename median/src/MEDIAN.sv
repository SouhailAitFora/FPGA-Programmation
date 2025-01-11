module MEDIAN #(parameter WIDTH = 8 , N_PIXELS = 9)
            (input  logic  DSI,
             input  logic  CLK,
             input  logic  nRST,
             input  logic [WIDTH-1:0] DI,
             output logic [WIDTH-1:0] DO,
             output logic DSO
             );

logic BYP;

always@(negedge DSI)
begin
    @(posedge CLK);
    for (i = N_PIXELS - 1; i > 4; i--) begin

            BYP = 0;
            DSI = 0;
            for (j = 0; j < i; j++) @(posedge CLK);
            
            BYP = 1;
            DSI = 1;
            for (j = i; j < N_PIXELS; j++) @(posedge CLK);
    end

    BYP = 0;
    DSI = 0;
    for (j = 0; j < ((N_PIXELS - 1) >> 1); j++) @(posedge CLK);
    @(posedge CLK);
    DSO = 1;
    @(posedge CLK);
    DSO = 0;
end

MED MED1(.BYP(BYP)  ,  .DSI(DSI),  .CLK(CLK),  .DI(DI),  .DO(DO));

endmodule