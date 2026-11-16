module Baudrategenerator(

input PCLK,
input PRESET_n,
input [1:0] spi_mode,
input spiswai,
input [2:0]sppr,
input [2:0]spr,
input cpol,
input cpha,
input ss,

output reg sclk,
output reg miso_receive_pos_sclk,
output reg miso_receive_neg_sclk,
output reg mosi_send_pos_sclk,
output reg mosi_send_neg_sclk,
output [11:0] baudratedivisor

);

wire pre_sclk;
reg [11:0] counter;

assign baudratedivisor = (sppr + 1)* (2**(spr+1));
assign pre_sclk = cpol ? 1:0;

always @(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
        counter <= 0;
        sclk <= pre_sclk;
    end
    else if(!ss && !spiswai && (spi_mode == 2'b00 || spi_mode == 2'b01))begin
        if(counter >= baudratedivisor/2 -1)begin
            sclk <= ~sclk;
            counter <= 0;
        end
        else
        counter <= counter + 1;
    end
    else  begin
    sclk <=  pre_sclk;
    counter <= 0;
    end
    end

always @(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
    miso_receive_neg_sclk <= 0;
    miso_receive_pos_sclk <= 0;
    end

    else if((!cpha && cpol) || (cpha && !cpol))begin
        if(sclk)begin
            if(counter == baudratedivisor/2 - 1)
            miso_receive_neg_sclk <= 1;
            else
            miso_receive_neg_sclk <= 0;
        end
        else
        miso_receive_neg_sclk <= 0;
    end

    else if((!cpha && !cpol) || (cpha && cpol))begin
        if(!sclk)begin
            if(counter == baudratedivisor/2 - 1)
            miso_receive_pos_sclk <= 1;
            else
            miso_receive_pos_sclk <= 0;
        end
        else
        miso_receive_pos_sclk <= 0;
    end
end


always @(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
        mosi_send_neg_sclk <= 0;
        mosi_send_pos_sclk <= 0;
    end

    else if((!cpha && cpol) || (cpha && !cpol))begin
        if(sclk)begin
            if(counter == baudratedivisor/2 - 2)
            mosi_send_neg_sclk <= 1;
            else
            mosi_send_neg_sclk <= 0;
        end
        else
        mosi_send_neg_sclk <= 0;
    end

    else if((!cpha && !cpol) || (cpha && cpol))begin
        if(!sclk)begin
            if(counter == baudratedivisor/2 - 2)
                mosi_send_pos_sclk <= 1;
            else
            mosi_send_pos_sclk <= 0;
        end
        else
        mosi_send_pos_sclk <= 0;
    end

end

endmodule