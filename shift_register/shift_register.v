module shift_register(

input PCLK,
input PRESET_n,
input ss,
input send_data,
input lsbfe,
input cpha,
input cpol,
input miso_receive_neg_sclk,
input miso_receive_pos_sclk,
input mosi_send_neg_sclk,
input mosi_send_pos_sclk,
input [7:0] data_mosi,
input miso,
input receive_data,

output reg mosi,
output [7:0] data_miso
);

reg [7:0] shift_reg;
reg [7:0] temp_reg;
reg [2:0] count, count1;
reg [2:0] count2, count3;

//shift register
always@(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
        shift_reg <= 8'b0;
    end
    else if(send_data)begin
        shift_reg <= data_mosi;
    end
    else 
    shift_reg <= shift_reg;
end


 // MOSI Transfer
always @(posedge PCLK or negedge PRESET_n) begin
    if (!PRESET_n) begin
        mosi   <= 1'b0;
        count  <= 3'd0;
        count1 <= 3'd7;
    end

    else begin
    if (!ss) begin
        if ((!cpha && cpol) || (cpha && !cpol)) begin
            // Negative-pulse branch
            if (lsbfe) begin
                if(count <= 7)begin
                    if(mosi_send_neg_sclk)begin
                        mosi <= shift_reg[count];
                        count <= count + 1'b1;
                    end
                end
                else begin
                    count <= 0;
                end
            end
            else begin
                if(count1 >= 0) begin
                    if(mosi_send_neg_sclk)begin
                        mosi <= shift_reg[count1];
                        count1 <= count1 - 1'b1;
                    end
                end
                else begin
                    count1 <= 3'd7;
                    end
                end
            end
        else begin
            // Positive-pulse branch
            if (lsbfe) begin
                if(count <= 7)begin
                    if(mosi_send_pos_sclk)begin
                        mosi <= shift_reg[count];
                        count <= count + 1'b1;
                    end
                end
                else begin
                    count <= 0;
                end
                
            end
            else begin
                if(count1 >= 0)begin
                    if(mosi_send_pos_sclk)begin
                        mosi <= shift_reg[count1];
                        count1 <= count1 - 1'b1;
                    end
                end
                else begin
                    count1 <= 3'd7;
                end
        end
    end
end
end
end

//MISO receive

always@(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
        temp_reg <= 8'b0;
        count2 <= 3'd0;
        count3 <= 3'd7;
    end
    else begin
        if(!ss)begin
            if((!cpha && cpol) || (cpha && !cpol))begin
                if(lsbfe == 1)begin
                    if(count2 <= 7)begin
                        if(miso_receive_neg_sclk)begin
                            temp_reg[count2] <= miso;
                            count2 <= count2 + 1'b1;
                        end
                    end
                    else begin
                        count2 <= 0;
                    end
                end
                else begin
                    if(count3 >= 0)begin
                        if(miso_receive_neg_sclk)begin
                            temp_reg[count3] <= miso;
                            count3 <= count3 - 1'b1;
                        end
                    end
                    else begin
                        count3 <= 3'd7;
                    end
                end
            end

            else begin
                if(lsbfe == 1)begin
                    if(count2 <= 7)begin
                        if(miso_receive_pos_sclk)begin
                            temp_reg[count2] <= miso;
                            count2 <= count2 + 1'b1;
                        end
                    end
                    else begin
                        count2 <= 0;
                    end
                end
                else begin
                    if(count3 >= 0)begin
                        if(miso_receive_pos_sclk)begin
                            temp_reg[count3] <= miso;
                            count3 <= count3 - 1'b1;
                        end
                    end
                    else begin
                        count3 <= 3'd7;
                    end
                    end
                end
            end
        end
    end



assign data_miso = receive_data?temp_reg:8'b0;

endmodule