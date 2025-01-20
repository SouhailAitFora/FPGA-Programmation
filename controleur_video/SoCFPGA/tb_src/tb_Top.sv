`timescale 1ns/1ps

`default_nettype none

module tb_Top;

// Entrées sorties extérieures
bit   FPGA_CLK1_50;
logic [1:0]	KEY;
wire  [7:0]	LED;
logic [3:0]	SW;

// Interface vers le support matériel
hws_if      hws_ifm();

// Instance du module Top
Top Top0(.*) ;

///////////////////////////////
//  Code élèves
//////////////////////////////

// generation of clock signal 
always begin
    FPGA_CLK1_50 = 0 ;
    # 10ns ;
    FPGA_CLK1_50 = 1 ;
    # 10ns ;
end

// simulation of an random interaction with KEY[0]
initial begin

    KEY[0] = 1 ;
    #128ns    ; 
    KEY[0] = 0 ;
    #128ns    ;
    KEY[0] = 1 ;

end

// end simulation after 4 ms
always begin
    # 4ms ;
    $stop(); 
    
end

// test of LED[0]
always@(*) begin
    if(KEY[0] != LED[0]) begin
        $display(" LED[0] != KEY[0]");
        $stop();    
    end
end


endmodule
