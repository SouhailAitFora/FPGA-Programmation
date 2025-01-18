//-----------------------------------------------------------------
// Avalon BlockRAM
//-----------------------------------------------------------------
//
// Le paramètre RAM_ADD_W permet de déterminer le nombre de mots de
// la mémoire RAM interne au module (2**RAM_ADD_W)
// Le paramètre BURSTCOUNT_W permet de déterminer la taille maximale
// du "burst" en mode BURST (2**(BURST_COUNT_W-1))
// (voir doc mnl_avalon_spec.pdf, page 17)
`timescale 1ns/1ps
`default_nettype none
module avalon_bram #(parameter RAM_ADD_W = 8, BURSTCOUNT_W = 4 ) (
      // Avalon  interface for an agent
      avalon_if.agent avalon_a
      );
      // a vous de jouer a partir d'ici
      parameter size =  1 << (RAM_ADD_W) ;
      parameter size_burst = 1 << (BURSTCOUNT_W-1);
      logic [size-1:0] new_address;
      logic [7:0] mem_0 [size-1:0];
      logic [7:0] mem_1 [size-1:0];
      logic [7:0] mem_2 [size-1:0];
      logic [7:0] mem_3 [size-1:0];
      logic [size_burst-1:0] counter_read;
      logic [size_burst-1:0] counter_write;
      logic [size_burst-1:0] address_burst ;
      logic [size_burst-1:0] save_burst ;
      logic [size_burst-1:0] address_burst_write ;



      assign new_address = ( avalon_a.address >> 2 ) & (size-1) ;
      assign address_burst = new_address + counter_read;
      assign address_burst_write = new_address + counter_write;


      always_ff @(posedge avalon_a.clk or posedge avalon_a.reset) begin
            if(avalon_a.reset)begin
                  avalon_a.waitrequest <= 1 ;
                  avalon_a.readdatavalid <= 0 ;
                  avalon_a.readdata <=0 ;
                  save_burst <= 1 ;
            end
            else
            begin
                  if(counter_read == save_burst )begin
                        avalon_a.waitrequest   <= 0  ;
                        avalon_a.readdatavalid <= 0 ;
                  end
                  else 
                  begin
                        if(avalon_a.read ||  (counter_read>0)  )begin
                              if(avalon_a.read)  begin 
                                    save_burst <= avalon_a.burstcount;
                                    new_address<= ( avalon_a.address >> 2 ) & (size-1) ;
                              end
                              avalon_a.waitrequest   <= 1 ;
                              avalon_a.readdatavalid <= 1 ;
                              avalon_a.readdata <= { mem_3[address_burst], mem_2[address_burst], mem_1[address_burst], mem_0[address_burst]} ;
                        end
                        else begin
                              avalon_a.waitrequest   <= 0;
                              avalon_a.readdatavalid <= 0 ;
                        end
                  end
                  
                  if (avalon_a.write && (counter_write ==0)) begin
                        save_burst<= avalon_a.burstcount;
                        new_address<= ( avalon_a.address >> 2 ) & (size-1) ;
                  end


            end
            
      end

      always_ff @(posedge avalon_a.clk)
      begin

            if (avalon_a.write) 
            begin
                  if(avalon_a.byteenable[0] ) mem_0[address_burst_write] <= avalon_a.writedata[7:0]; 
                  if(avalon_a.byteenable[1] ) mem_1[address_burst_write] <= avalon_a.writedata[15:8];
                  if(avalon_a.byteenable[2] ) mem_2[address_burst_write] <= avalon_a.writedata[23:16];
                  if(avalon_a.byteenable[3] ) mem_3[address_burst_write] <= avalon_a.writedata[31:24];
                  $display("%d",new_address);
                  $$display("%d",counter_write);
                  $display("%d",address_burst);
            end

      end

      always_ff@(posedge avalon_a.clk or posedge avalon_a.reset)begin
            if(avalon_a.reset)begin
                  counter_read <= 0 ;
                  counter_write <=0 ;
            end
            else begin
                  if(counter_write == save_burst)begin
                        counter_write <=0;
                  end
                  else if (avalon_a.write) begin
                        counter_write <= counter_write + 1 ;
                  end

                  if (counter_read == save_burst) begin
                        counter_read <=0;
                  end
                  else if (avalon_a.read ||   (counter_read>0) ) begin
                        counter_read <= counter_read + 1;
                  end
            end
      end


endmodule

