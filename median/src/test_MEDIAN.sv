module test_MEDIAN;
logic BYP,DSI,CLK,DSO,nRST ;
logic [7:0] DI,DO ;

MEDIAN #(parameter WIDTH = 8 , N_PIXELS = 9)
            (input  logic  DSI,
             input  logic  CLK,
             input  logic  nRST,
             input  logic [WIDTH-1:0] DI,
             output logic [WIDTH-1:0] DO,
             output logic DSO
             );

MEDIAN MEDIAN1(.DSI(DSI),  .CLK(CLK),  .DI(DI),  .DO(DO),.nRST(nRST),.DSO(DSO));

always #10ns CLK = ~CLK;

initial begin: ENTREES
    nRST = 0;
    #100ns;
    nRST = 1;
    
    int v[0:8];
    int i, j, k, tmp;
    DSO = 0;
    CLK = 0;
    DSI = 0;
    BYP = 0;

    repeat(1000) begin

        @(posedge CLK);
        DSI = 1;
        BYP = 1;

        for (j = 0; j < 9; j++) begin

            v[j] = {$random} % 256;
            DI = v[j];

            @(posedge CLK);
        end

        DI = 0;
        DSI = 0;
        
        // median caluculation for verification
        for(j = 0; j < 8; j = j + 1)
        for(k = j + 1; k < 9; k = k + 1) 
          if(v[j] < v[k]) begin
            tmp = v[j];
            v[j] = v[k];
            v[k] = tmp;
          end
        
        @(posedge CLK);

        if(v[4] != DO and DSO) begin
            $display("erreur : DO = ", DO, " au lieu de ", v[4]);
            $stop;
        end

    end
    if(DSO)
    begin
        $display("Fin de la simulation sans aucune erreur"); 
        $finish;
    end
    else begin
        $display("Fin de la simulation sans que DSO = 1 "); 
        $finish;
    end
end

endmodule