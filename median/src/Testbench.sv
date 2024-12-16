module test_MCE;

logic [0:7] A, B;
logic [0:7] MAX, MIN;
logic i;

MCE I_MCE(.A(A), .B(B), .MAX(MAX), .MIN(MIN));

for i in 1 ... 1000
begin
    assign A = 
end