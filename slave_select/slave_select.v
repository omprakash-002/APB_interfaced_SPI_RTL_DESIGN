module slave_select(

input PCLK,
input PRESET_n,
input [1:0] spi_mode,
input mstr,
input spiswai,
input send_data,
input [11:0] baudratedivisor,

output reg ss,
output reg receive_data,
output tip
);

reg [15:0] counter;
wire[15:0] target;
reg rcv;

assign target = (baudratedivisor*8);
assign tip = ~ss;

always @(posedge PCLK or negedge PRESET_n)begin
    
    if(!PRESET_n)begin
        counter <= {16{1'b1}};
        ss <= 1'b1;
        rcv <= 1'b0;
    end

    else if(mstr == 1 && (spi_mode == 2'b00 || spi_mode == 2'b01 ) && spiswai == 1'b0)begin
        if(send_data)begin
            ss <= 1'b0;
            counter <= 16'd0;
            rcv <= 1'b0;
        end

        else if(counter < target - 1)begin
            ss <= 1'b0;
            counter <= counter + 1'b1;
            rcv <= 1'b0;
        end

        else if(counter == target - 1 )begin
            ss <= 1'b0;
            counter <= {16{1'b1}};
            rcv <= 1'b1;
        end
        
        else begin

        ss <= 1'b1;
        rcv <= 1'b0;
        counter <= {16{1'b1}};

    end
end

else begin
   
        ss <= 1'b1;
        rcv <= 1'b0;
        counter <= {16{1'b1}};
    end

end



always @(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)
    receive_data <= 1'b0;
    else
    receive_data <= rcv;

    end

endmodule


