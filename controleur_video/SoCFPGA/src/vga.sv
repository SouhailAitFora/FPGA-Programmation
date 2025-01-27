module vga #(parameter  HDISP  = 800, VDISP  = 480 ) (
      input logic pixel_clk,
      input logic pixel_rst,
      
      // video  interface for a master
      video_if.master video_ifm,
      avalon_if.host avalon_ifh
      );
//  nombre of pixels of each signal
localparam HFP = 40;
localparam HPULSE = 48;
localparam HBP = 40 ;

// nombre of lines of each signal
localparam VFP = 13 ;
localparam VPULSE = 3;
localparam VBP = 29 ;   

// Nb of bits of horizontal counter
localparam Nbits_counter_H = $clog2( HFP + HPULSE + HBP + HDISP);

//Nb of bits of vertical counter
localparam Nbits_counter_V = $clog2(  VFP + VPULSE + VBP + VDISP);

// vertical and horizontal counters 
logic [Nbits_counter_H-1:0] horizontal_counter,x;
logic [Nbits_counter_V-1:0] vertical_counter,y  ;

// Clock atttachement 
assign video_ifm.CLK = pixel_clk ;



// horizontal signal controls 
always_ff@(posedge pixel_clk or posedge pixel_rst)begin
    if (pixel_rst) begin
        horizontal_counter <= 0 ;
        vertical_counter   <= 0 ;
    end
    else begin
        
        //control of horizontal counter
        if (horizontal_counter == (HFP + HPULSE + HBP + HDISP -1)) begin
            horizontal_counter <= 0 ; 
        end
        else begin
            horizontal_counter <= horizontal_counter + 1'b1 ;
        end
        
        //control of vertical counter
        if (vertical_counter == (VFP + VPULSE + VBP + VDISP -1)) begin
            vertical_counter <= 0 ; 
        end
        else if (horizontal_counter == (HFP + HPULSE + HBP + HDISP -1)) begin
            vertical_counter <= vertical_counter + 1'b1 ;
        end

    end
end

always_ff@(posedge pixel_clk or posedge pixel_rst)begin
    if (pixel_rst) begin
        video_ifm.VS    <= 1 ;
        video_ifm.HS    <= 1 ;
        video_ifm.BLANK <=0 ;
    end
    else begin
        // control of HS signal
        if(horizontal_counter >=(HFP -1) && horizontal_counter < (HFP + HPULSE -1) )begin
             video_ifm.HS    <= 0 ;    
        end
        else begin
            video_ifm.HS <= 1 ;
        end

        // control of VS signal 
        if(vertical_counter >=(VFP -1) && vertical_counter < (VFP + VPULSE -1) )begin
             video_ifm.VS    <= 0 ;    
        end
        else begin
            video_ifm.VS <= 1 ;
        end

        // control of BLANK SIGNAL
        if (horizontal_counter < (HFP + HPULSE + HBP - 1) || vertical_counter < (VFP + VPULSE + VBP - 1)   ) begin
            video_ifm.BLANK  <= 0 ;  
        end
        else if (horizontal_counter == (HFP + HPULSE + HBP + HDISP -1)||vertical_counter == (VFP + VPULSE + VBP + VDISP -1) ) begin
            video_ifm.BLANK  <= 0 ; 
        end
        else begin
            video_ifm.BLANK <= 1 ;
        end

    end
end


// creating coordinate
assign x = horizontal_counter - (HFP + HPULSE + HBP - 1'b1);
assign y = vertical_counter - (VFP + VPULSE + VBP - 1'b1) ;

// MIRE image generation
always_ff@(posedge pixel_clk or posedge pixel_rst)begin
    if (pixel_rst) begin
        video_ifm.RGB <= 0; 
    end
    else begin
        if(x[3:0] == 15) begin
            video_ifm.RGB <= 24'hffffff ; 
        end
        else if (y[3:0]== 15) begin
            video_ifm.RGB <= 24'hffffff ;
        end
        else begin
            video_ifm.RGB <= 0 ;
        end
    end
end

// Code de test de l'interconnection avalon_sdram (non synthétisable)
assign avalon_ifh.address = '0 ;             // Adresse fixe à 0
assign avalon_ifh.burstcount = 6'h1 ;        // Transfert d'une donnée 
assign avalon_ifh.writedata = 32'hBABECAFE ; // On écrit toujours la même chose
assign avalon_ifh.byteenable = 4'hF ;        // On écrit tous les octets
initial begin
    {avalon_ifh.write, avalon_ifh.read} = 2'b00 ;
    @(posedge avalon_ifh.reset) ;
    @(negedge avalon_ifh.reset) ;
    repeat(10) @(posedge avalon_ifh.clk) ;
    avalon_ifh.write <= 1'b1 ;
    @(posedge avalon_ifh.clk iff !avalon_ifh.waitrequest) ;
    avalon_ifh.write <= 1'b0 ;
    repeat(10) @(posedge avalon_ifh.clk) ;
    avalon_ifh.read <= 1'b1 ;
    @(posedge avalon_ifh.clk iff !avalon_ifh.waitrequest) ;
    avalon_ifh.read <= 1'b0 ;
    @(posedge avalon_ifh.readdatavalid) ;
    repeat(10) @(posedge avalon_ifh.clk) ;
    $stop() ;
end
// Fin du code de test

endmodule