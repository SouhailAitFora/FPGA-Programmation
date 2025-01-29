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

//SDRAM access controler
localparam BURSTSIZE = 16;

assign avalon_ifh.write = 1'b0; // Read only
assign avalon_ifh.byteenable = 4'h0; // Read only
assign avalon_ifh.burstcount = BURSTSIZE; // We use a constant burstcount

// data red verification
int verification_counter;

always_ff@(posedge avalon_if.clk or posedge avalon_ifh.reset)
begin
    if (avalon_ifh.reset || avalan_ifh.read) begin
        verification_counter <= 0;
    end
    else if (readdatavalid_old && !avalan_ifh.readdatavalid && !avalan_ifh.waitrequest) begin
        verification_counter <= verification_counter + 1;
    end
end

localparam MAX_ADDRESS = 4 * HDISP * VDISP;

// read signal and address counter
always_ff@(posedge avalon_if.clk or posedge avalon_ifh.reset)
begin
    if (avalon_ifh.reset) begin
        avalan_ifh.read <= 1'b0;
        avalon_ifh.address <= 32'd0;
    end
    else if (verification_counter == BURSTSIZE && !avalan_ifh.waitrequest) begin
        avalan_ifh.read <= 1'b1;
        if (avalan_ifh.address < MAX_ADDRESS) avalan_ifh.address <= avalan_ifh.address + BURSTSIZE * 4;
        else avalan_ifh.address <= 0;
    end
    else if (avalan_ifh.read) begin
        avalan_ifh.read <= 1'b0;
    end
end


endmodule