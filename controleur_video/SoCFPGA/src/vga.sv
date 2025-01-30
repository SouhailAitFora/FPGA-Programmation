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

logic walmost_full;

assign avalon_ifh.write = 1'b0; // Read only
assign avalon_ifh.byteenable = 4'h0; // Read only
assign avalon_ifh.burstcount = BURSTSIZE; // We use a constant burstcount

// data red verification
int verification_counter;

always_ff@(posedge avalon_ifh.clk or posedge avalon_ifh.reset)
begin
    if (avalon_ifh.reset) begin
        verification_counter <= BURSTSIZE + 1;
    end
    else if (avalon_ifh.read) verification_counter <= 0;
    else if (avalon_ifh.readdatavalid) verification_counter <= verification_counter + 1;
end

localparam MAX_ADDRESS = 4 * HDISP * VDISP;

// read signal and address counter
always_ff@(posedge avalon_ifh.clk or posedge avalon_ifh.reset)
begin
    if (avalon_ifh.reset) begin
        avalon_ifh.read <= 1'b0;
        avalon_ifh.address <= 32'd0;
    end
    else if (verification_counter == BURSTSIZE + 1 && !avalon_ifh.waitrequest && !walmost_full) avalon_ifh.read <= 1'b1;
    else if (verification_counter == BURSTSIZE && !avalon_ifh.waitrequest && !walmost_full) begin
        avalon_ifh.read <= 1'b1;
        if (avalon_ifh.address < MAX_ADDRESS) avalon_ifh.address <= avalon_ifh.address + BURSTSIZE * 4;
        else avalon_ifh.address <= 0;
    end
    else if (avalon_ifh.read) begin
        avalon_ifh.read <= 1'b0;
    end
end

// asynchronous FIFO
localparam DATA_WIDTH = 32;
localparam DEPTH_WIDTH = 8;
localparam ALMOST_FULL_THRESHOLD = (1 << DEPTH_WIDTH) - BURSTSIZE - 1;


async_fifo #(.DATA_WIDTH(DATA_WIDTH),.DEPTH_WIDTH(DEPTH_WIDTH),.ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD)) async_fifo_inst (
        .rst(avalon_ifh.reset),
        .rclk(pixel_clk),
        .read(1'b0),
        .rdata(),
        .rempty(),
        .wclk(avalon_ifh.clk),
        .wdata(avalon_ifh.readdata),
        .write(avalon_ifh.readdatavalid),
        .wfull(),
        .walmost_full(walmost_full)
);
endmodule