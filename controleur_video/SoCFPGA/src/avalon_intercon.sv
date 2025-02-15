module avalon_intercon #(parameter  HDISP  = 800, VDISP  = 480 ) (
    input logic clk,
    input logic rst,
      
    // interfaces instantiations
    avalon_if.agent avalon_ifa_vga,
    avalon_if.agent avalon_ifa_stream,
    avalon_if.host  avalon_ifh_sdram
    );


int counter_write_sdram ;
logic sel_vga,vga_busy,not_finish ;
logic [4:0] busy_counter;
//
logic sdram_full ; 

// signal selection between vga or processor
assign sel_vga = vga_busy ;

// signals to stop writing in sdram
assign avalon_if_stream.waitrequest = sel_vga || (sdram_full && (counter_write_sdram == 16)) ;
assign avalon_if_stream.readdata = '0 ;

// connecting the output of the avalon host of th vga to the agent input of sdram
assign  avalon_ifh_sdram.write       = sel_vga ? avalon_ifa_vga.write      : avalon_ifa_stream.write       ;
assign  avalon_ifh_sdram.byteenable  = sel_vga ? avalon_ifa_vga.byteenable : avalon_ifa_stream.byteenable  ;
assign  avalon_ifh_sdram.burstcount  = sel_vga ? avalon_ifa_vga.burstcount : avalon_if_stream.burstcount   ;
assign  avalon_ifh_sdram.read        = sel_vga ? avalon_ifa_vga.read       : avalon_if_stream.read         ;
assign  avalon_ifh_sdram.address     = sel_vga ? avalon_ifa_vga.address    : avalon_if_stream.address      ;
assign  avalon_ifh_sdram.writedata   = sel_vga ? avalon_ifa_vga.writedata  : avalon_if_stream.writedata    ;

// connecting the input of the avalon host of th vga to the agent output of sdram
assign  avalon_ifa_vga.readdata      = avalon_ifh_sdram.readdata       ;
assign  avalon_ifa_vga.readdatavalid = avalon_ifh_sdram.readdatavalid  ;  
assign  avalon_ifa_vga.waitrequest   = avalon_ifh_sdram.waitrequest || !sdram_full ;

// flag to indicate that the VGA is working on sdram
assign vga_busy = avalon_ifa_vga.read  ||  not_finish ;

// vga_busy signal control
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        busy_counter <= avalon_ifa_vga.burstcount + 1 ; 
        not_finish <= 0;
    end
    else begin
        if (avalon_ifa_vga.read) busy_counter <=0;
        else if (avalon_ifh_sdram.readdatavalid) busy_counter <= busy_counter + 1'b1 ;

        if (avalon_ifa_vga.read ) not_finish <= 1'b1 ;
        else if (busy_counter == avalon_ifa_vga.burstcount) not_finish <= 1'b0;
    end
end

// counter of how much the sdram is full
int counter_sdram;

// size of sdram (display zone )
localparam size = HDISP * VDISP ;

// control signals that prouve that sdram is full
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        sdram_full <= 0   ;
        counter_sdram <= 0;
    end
    else begin
        if (counter_sdram == size ) begin
            sdram_full <= 1 ;
        end
        if(counter_sdram == size) counter_sdram <= 0 ;
        else if (!sdram_full && avalon_ifa_stream.write ) counter_sdram <= 1 + counter_sdram ;
    end
end

// signals that controls the fact of  writing 16 pixels 
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        counter_write_sdram <= 0 ;
    end
    else begin
        if (avalon_ifa_vga.read) counter_write_sdram <= 0 ;
        else if (avalon_ifa_stream.write)  counter_write_sdram <= counter_write_sdram + 1 ;
        end
end

endmodule