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
      parameter size =  1 << (RAM_ADD_W);
      logic [7:0] mem_0 [size-1:0];
      logic [7:0] mem_1 [size-1:0];
      logic [7:0] mem_2 [size-1:0];
      logic [7:0] mem_3 [size-1:0];
      logic [BURSTCOUNT_W-1:0] counter_read, counter_write;
      logic [RAM_ADD_W-1:0] address_reg, full_address, word_address, final_address; 
      logic [BURSTCOUNT_W-1:0] burstcount_reg, full_burstcount;
      logic past_reset, true_write, true_read;
      // TODO size might be wrong
    
    assign true_write = avalon_a.write && !avalon_a.waitrequest;
    assign true_read = avalon_a.read && !avalon_a.waitrequest;

    // gestion des compteurs
    always_ff @(posedge avalon_a.clk or negedge avalon_a.reset) begin
        if (avalon_a.reset) begin
            counter_read <= 0;
            counter_write <= 0;
        end
        else begin

            // compteur de lecture
            if (counter_read == full_burstcount) counter_read <= 0;
            else if (true_read || (counter_read > 0)) counter_read <= counter_read + 1;

            // compteur d'écriture
            if ((counter_write + 1) == full_burstcount && true_write) counter_write <= 0;
            else if (true_write) counter_write <= counter_write + 1;
        end
        
    end

    // gestion de sauvegarde de l'adresse et de burstcount
    always_ff @(posedge avalon_a.clk or negedge avalon_a.reset) begin

        if (avalon_a.reset) begin
            address_reg <= 0;
            burstcount_reg <= 1;
        end
        else begin
            past_reset <= avalon_a.reset;

            if (true_read) begin
                address_reg <= avalon_a.address;
                burstcount_reg <= avalon_a.burstcount;
            end
            else if (true_write && (counter_write == 0)) begin
                address_reg <= avalon_a.address;
                burstcount_reg <= avalon_a.burstcount;
            end
        end
    end

    // creation d'une "full" adresse et "full" bustcount qi sont valides tout au long de l'operation
    always_comb begin
        if ((true_read) || (true_write && (counter_write == 0))) begin
            full_address = avalon_a.address;
            full_burstcount = avalon_a.burstcount;
        end
        else begin
            full_address = address_reg;
            full_burstcount = burstcount_reg;
        end
    end

    // calcul de l'adresse final
    always_comb begin

        word_address = (full_address >> 2) & (size - 1);

        if (counter_read > 0) begin
            final_address = word_address + counter_read - 1;
        end
        else if (true_write) begin
            final_address = word_address + counter_write;
        end

    end

    // Lecture
    always_comb begin
        if (counter_read > 0) begin
            avalon_a.readdata = {mem_3[final_address], mem_2[final_address], mem_1[final_address], mem_0[final_address]};
            avalon_a.waitrequest = 1;
            avalon_a.readdatavalid = 1;
        end
        else if (avalon_a.reset || past_reset)begin 
            avalon_a.readdata = 0;
            avalon_a.waitrequest = 1;
            avalon_a.readdatavalid = 0;
        end
        else begin
            avalon_a.readdata = 0;
            avalon_a.waitrequest = 0;
            avalon_a.readdatavalid = 0;
        end
    end

    // Ecriture
    always_ff @(posedge avalon_a.clk) begin
            if (true_write) 
            begin
                if(avalon_a.byteenable[0]) mem_0[final_address] <= avalon_a.writedata[7:0]; 
                if(avalon_a.byteenable[1]) mem_1[final_address] <= avalon_a.writedata[15:8];
                if(avalon_a.byteenable[2]) mem_2[final_address] <= avalon_a.writedata[23:16];
                if(avalon_a.byteenable[3]) mem_3[final_address] <= avalon_a.writedata[31:24];
            end

    end
endmodule

