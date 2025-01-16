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
module avalon_bram #(parameter RAM_ADD_W = 32, BURSTCOUNT_W = 4 ) (
      // Avalon  interface for an agent
      avalon_if.agent avalon_a
      );
      // a vous de jouer a partir d'ici
      parameter size =  1 << (RAM_ADD_W) ;
      logic [31:0] new_adress;
      logic [7:0] mem_0 [size-1:0];
      logic [7:0] mem_1 [size-1:0];
      logic [7:0] mem_2 [size-1:0];
      logic [7:0] mem_3 [size-1:0];
      assign new_adress = (avalon_a.address >>2);

      always_ff @(posedge avalon_a.clk or posedge avalon_a.reset) begin
            if(avalon_a.reset)begin
                  avalon_a.waitrequest <= 1 ;
                  avalon_a.readdatavalid <= 1 ;
            end
            else
            begin
            if(avalon_a.read)begin
                  avalon_a.waitrequest   <= 1 ;
                  avalon_a.readdatavalid <= 1 ;
                  avalon_a.readdata <= { mem_3[new_adress], mem_2[new_adress], mem_1[new_adress], mem_0[new_adress]} ;
            end
            else begin
                  avalon_a.waitrequest <= 0;
                  avalon_a.readdatavalid <= 0 ;
            end

            if(avalon_a.waitrequest )begin
                  avalon_a.waitrequest<=0 ;
                  avalon_a.readdatavalid <= 0 ;


            end
            end
            
      end

      always @(posedge avalon_a.clk)
      begin
            if (avalon_a.write) 
            begin
            case (avalon_a.byteenable)
                  
                  4'b0001: mem_0[new_adress] <= avalon_a.writedata[7:0];        
                  4'b0010: mem_1[new_adress] <= avalon_a.writedata[15:8];       
                  4'b0100: mem_2[new_adress] <= avalon_a.writedata[23:16];      
                  4'b1000: mem_3[new_adress] <= avalon_a.writedata[31:24];      
                  
                  4'b0011: begin 
                        mem_0[new_adress] <= avalon_a.writedata[7:0];
                        mem_1[new_adress] <= avalon_a.writedata[15:8];
                  end
                  4'b0101: begin 
                        mem_0[new_adress] <= avalon_a.writedata[7:0];
                        mem_2[new_adress] <= avalon_a.writedata[23:16];
                  end
                  4'b1001: begin 
                        mem_0[new_adress] <= avalon_a.writedata[7:0];
                        mem_3[new_adress] <= avalon_a.writedata[31:24];
                  end
                  4'b0110: begin 
                        mem_1[new_adress] <= avalon_a.writedata[15:8];
                        mem_2[new_adress] <= avalon_a.writedata[23:16];
                  end
                  4'b1010: begin 
                        mem_1[new_adress] <= avalon_a.writedata[15:8];
                        mem_3[new_adress] <= avalon_a.writedata[31:24];
                  end
                  4'b1100: begin 
                        mem_2[new_adress] <= avalon_a.writedata[23:16];
                        mem_3[new_adress] <= avalon_a.writedata[31:24];
                  end

                  
                  4'b0111: begin 
                        mem_0[new_adress] <= avalon_a.writedata[7:0];
                        mem_1[new_adress] <= avalon_a.writedata[15:8];
                        mem_2[new_adress] <= avalon_a.writedata[23:16];
                  end
                  4'b1011: begin 
                        mem_0[new_adress] <= avalon_a.writedata[7:0];
                        mem_1[new_adress] <= avalon_a.writedata[15:8];
                        mem_3[new_adress] <= avalon_a.writedata[31:24];
                  end
                  4'b1101: begin 
                        mem_0[new_adress] <= avalon_a.writedata[7:0];
                        mem_2[new_adress] <= avalon_a.writedata[23:16];
                        mem_3[new_adress] <= avalon_a.writedata[31:24];
                  end
                  4'b1110: begin 
                        mem_1[new_adress] <= avalon_a.writedata[15:8];
                        mem_2[new_adress] <= avalon_a.writedata[23:16];
                        mem_3[new_adress] <= avalon_a.writedata[31:24];
                  end

                  4'b1111: begin 
                        mem_0[new_adress] <= avalon_a.writedata[7:0];
                        mem_1[new_adress] <= avalon_a.writedata[15:8];
                        mem_2[new_adress] <= avalon_a.writedata[23:16];
                        mem_3[new_adress] <= avalon_a.writedata[31:24];
                  end

                  
                  default: begin
                        mem_0[new_adress] <= mem_0[new_adress];
                        mem_1[new_adress] <= mem_0[new_adress];
                        mem_2[new_adress] <= mem_0[new_adress];
                        mem_3[new_adress] <= mem_0[new_adress];
                  end
            endcase
            end

      end


endmodule

