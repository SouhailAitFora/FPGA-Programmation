module test_MCE;

logic [7:0] A, B;
logic [7:0] MAX, MIN;
int i = 0;

logic [0:7] MAX_SIM  ;
logic [0:7] MIN_SIM  ;

MCE I_MCE(.A(A), .B(B), .MAX(MAX), .MIN(MIN));

always(*)
begin
    for (i=0; i<1000;i++)
        begin
            A = $random() ;
            B = $random() ;
            MAX_SIM = ( A-B > 0 ) ? A : B ; 
            MIN_SIM = ( A-B > 0 ) ? A : B ;

            if (MAX_SIM != MAX || MIN_SIM != MIN) 
                begin
                    @always @(*) 
                        begin
                            $stop() ; 
                            $display("MAX_SIM = %u et MAX = %u && MIN_SIM = %u et MIN = %u", MAX_SIM,MAX,MIN_SIM,MIN);
                            $finish();
                        end

                end
        end
    $finish();    
end
endmodule