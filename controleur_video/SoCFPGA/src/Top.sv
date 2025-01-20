`default_nettype none

module Top (
    // Les signaux externes de la partie FPGA
	input  wire  FPGA_CLK1_50,
	input  wire  [1:0]	KEY,
	output logic [7:0]	LED,
	input  wire	 [3:0]	SW,
    // Les signaux du support matériel son regroupés dans une interface
    hws_if.master       hws_ifm
);

//====================================
//  Déclarations des signaux internes
//====================================
  wire        sys_rst;   // Le signal de reset du système
  wire        sys_clk;   // L'horloge système a 100Mhz
  wire        pixel_clk; // L'horloge de la video 32 Mhz

//=======================================================
//  La PLL pour la génération des horloges
//=======================================================

sys_pll  sys_pll_inst(
		   .refclk(FPGA_CLK1_50),   // refclk.clk
		   .rst(1'b0),              // pas de reset
		   .outclk_0(pixel_clk),    // horloge pixels a 32 Mhz
		   .outclk_1(sys_clk)       // horloge systeme a 100MHz
);

//=============================
//  Les bus Avalon internes
//=============================
avalon_if #( .DATA_BYTES(4)) avalon_if_sdram  (sys_clk, sys_rst);
avalon_if #( .DATA_BYTES(4)) avalon_if_stream (sys_clk, sys_rst);


//=============================
//  Le support matériel
//=============================
hw_support hw_support_inst (
    .avalon_ifa (avalon_if_sdram),
    .avalon_ifh (avalon_if_stream),
    .hws_ifm  (hws_ifm),
	.sys_rst  (sys_rst), // output
    .SW_0     ( SW[0] ),
    .KEY      ( KEY )
 );

//=============================
// On neutralise l'interface
// du flux video pour l'instant
//TODO A SUPPRIMER PLUS TARD
//=============================
assign avalon_if_stream.waitrequest = 1'b1;
assign avalon_if_stream.readdata = '0 ;


//=============================
// On neutralise l'interface SDRAM
// pour l'instant
//TODO A SUPPRIMER PLUS TARD
//=============================
assign avalon_if_sdram.write  = 1'b0;
assign avalon_if_sdram.read   = 1'b0;
assign avalon_if_sdram.address = '0  ;
assign avalon_if_sdram.writedata = '0 ;
assign avalon_if_sdram.byteenable = '0 ;


//--------------------------
//------- Code Eleves ------
//--------------------------
`ifdef SIMULATION
  localparam hcmpt=100 ;
`else
  localparam hcmpt=100 000 000 ;
`endif

int counter;

assign LED[0] = KEY[0];

always_ff @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst) begin
        LED[1] <= 0;
        counter <= 0;
    end
    else if(counter == (hcmpt - 1))begin
        LED[1] <= ~LED[1];
        counter <= 0;
    end
    else begin
        counter <= counter + 1;
    end
end

endmodule
`default_nettype wire