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
      logic [31:0] size =  1 << (RAM_ADD_W-2)  ;
      logic [31:0] new_adress;
      logic [7:0] mem_0 [size-1:0];
      logic [7:0] mem_1 [size-1:0];
      logic [7:0] mem_2 [size-1:0];
      logic [7:0] mem_3 [size-1:0];
      assign new_adress = ((avalon_a.address - avalon_a.address[1:0])>>1) + 1 ;

      always_ff @(posedge avalon_a.clk or posedge avalon_a.reset) begin
            if(avalon_a.reset)begin
                  avalon_a.waitrequest <= 1 ;
            end
            else
            begin
            if(avalon_a.read)begin
                  avalon_a.waitrequest   <= 1 ;
                  avalon_a.readdatavalid <= 1 ;
                  if(avalon_a.address<=3)begin

                        case (avalon_a.address)
                              0 : avalon_a.readdata <= mem_0 [0];
                              1 : avalon_a.readdata <= mem_1 [1];
                              2 : avalon_a.readdata <= mem_2 [2];
                              3 : avalon_a.readdata <= mem_3 [3];
                        endcase

                  end
                  else begin
                        case (avalon_a.address[1:0])
                              0 : avalon_a.readdata <= mem_0[new_adress];
                              1 : avalon_a.readdata <= mem_1[new_adress]; 
                              2 : avalon_a.readdata <= mem_2[new_adress];
                              3 : avalon_a.readdata <= mem_3[new_adress];
                        endcase
                  end
                  
            end
            else begin
                  avalon_a.waitrequest <= 0;
            end

            if(avalon_a.waitrequest )begin
                  avalon_a.waitrequest<=0 ;


            end
            end
            
      end

      always @(*)
      begin
            if (avalon_a.write) 
            begin
                  if(avalon_a.address<=3)begin

                        case (avalon_a.address)
                              0 :  mem_0 [0] = avalon_a.writedata ;
                              1 :  mem_1 [1] = avalon_a.writedata ;
                              2 :  mem_2 [2] = avalon_a.writedata ;
                              3 :  mem_3 [3] = avalon_a.writedata ;
                        endcase

                  end
                  else begin
                        case (avalon_a.address[1:0])
                              0 :  mem_0[new_adress] = avalon_a.writedata;
                              1 :  mem_1[new_adress] = avalon_a.writedata; 
                              2 :  mem_2[new_adress] = avalon_a.writedata;
                              3 :  mem_3[new_adress] = avalon_a.writedata;
                        endcase
            end
      end
      end


endmodule

