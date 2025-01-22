module vga #(parameter  HDISP  = 800, VDISP  = 480 ) (
      // video  interface for a master
      video_if.master video_ifm

      input logic pixel_clk;
      input logic pixel_rst;
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
logic [Nbits_counter_H-1:0] horizontal_counter;
logic [Nbits_counter_V-1:0] vertical_counter  ;

// Clock atttachement 
assign video_ifm.CLK = pixel_clk ;

// coordonance for MIRE image
localparam Nb_pixel_counter = 16;
localparam Nb_ligne_counter = 16;


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
            horizontal_counter <= horizontal_counter + 1 ;
        end
        
        //control of vertical counter
        if (vertical_counter_counter == (VFP + VPULSE + VBP + VDISP -1)) begin
            vertical_counter <= 0 ; 
        end
        else if (horizontal_counter == (HFP + HPULSE + HBP + HDISP -1)) begin
            vertical_counter <= horizontal_counter + 1 ;
        end
        else begin
            vertical_counter <= vertical_counter ;
        end

    end
end

always_ff@(posedge pixel_clk or posedge pixel_rst)begin
    if (pixel_rst) begin
        video_ifm.VS    <= 1 ;
        video_ifm.HS    <= 1 
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
        else begin
            video_ifm.BLANK <= 1 ;
        end

    end
end

// MIRE image generation
always_ff@(posedge pixel_clk or posedge pixel_rst)begin
    if (pixel_rst) begin
        video_ifm.RGB <= 0; 
    end
    else begin
        if((((vertical_counter-(VFP + VPULSE + VBP - 1))) & 4'hf) == 15 ) begin
            video_ifm.RGB <= 24'hffffff ; 
        end
        else if ((((horizontal_counter-HFP + HPULSE + HBP - 1))) & 4'hf == 15) begin
            video_ifm.RGB <= 24'hffffff ;
        end
        else begin
            video_ifm.RGB <= 0 ;
        end
    end
end
// this part is for module Top

/*
 modport video_ifm.master video_ifm
  vga #(
        .HDISP(HDISP),
        .VDISP(VDISP)
    ) vga_inst (
        .pixel_clk(pixel_clk),
        .pixel_rst(pixel_rst),
        .video_ifm(video_ifm)
    );
*/
endmodule