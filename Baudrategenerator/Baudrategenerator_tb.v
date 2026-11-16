module Baudrategenerator_tb;

reg PCLK;
reg PRESET_n;
reg [1:0] spi_mode;
reg spiswai;
reg [2:0] sppr;
reg [2:0] spr;
reg cpol;
reg cpha;
reg ss;

wire sclk;
wire miso_receive_neg_sclk;
wire miso_receive_pos_sclk;
wire mosi_send_neg_sclk;
wire mosi_send_pos_sclk;
wire [11:0] baudratedivisor;

Baudrategenerator DUT(
    .PCLK(PCLK),
    .PRESET_n(PRESET_n),
    .spi_mode(spi_mode),
    .spiswai(spiswai),
    .sppr(sppr),
    .spr(spr),
    .cpol(cpol),
    .cpha(cpha),
    .ss(ss),
    .sclk(sclk),
    .miso_receive_neg_sclk(miso_receive_neg_sclk),
    .miso_receive_pos_sclk(miso_receive_pos_sclk),
    .mosi_send_neg_sclk(mosi_send_neg_sclk),
    .mosi_send_pos_sclk(mosi_send_pos_sclk),
    .baudratedivisor(baudratedivisor)

);

initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK;
end


task reset;
begin
    @(posedge PCLK);
    PRESET_n = 1'b0;
    @(posedge PCLK);
    PRESET_n = 1'b1;
end
endtask

task initialization;
begin
        PRESET_n = 1'b0;
        spi_mode = 2'b00;
        spiswai  = 1'b0;
        sppr = 3'b000;
        spr  = 3'b000;
        cpol = 1'b0;
        cpha = 1'b0;
        ss = 1'b1;
end
endtask


task stimulus(input [1:0] mode, input [2:0] i, input [2:0] j , input x , input y, input z);
begin
    ss = 1'b0;
    spi_mode = mode;
    spiswai = z;
    sppr = i;
    spr = j;
    cpol = x;
    cpha = y;

    #300;
end
endtask


initial begin
    initialization;
    reset;
        
    stimulus(2'b00, 3'b001, 3'b001, 1'b0, 1'b0, 1'b0);
    
    stimulus(2'b00, 3'b010, 3'b001, 1'b0, 1'b1, 1'b0);

    //stimulus(2'b10, 3'b0101, 3'b111, 1'b0, 1'b1, 1'b0);

    stimulus(2'b01, 3'b001, 3'b010, 1'b1, 1'b0, 1'b0);

    stimulus(2'b01, 3'b000, 3'b001, 1'b1, 1'b1, 1'b0);

    stimulus(2'b01, 3'b001, 3'b000, 1'b1, 1'b1, 1'b1);
    stimulus(2'b01, 3'b001, 3'b000, 1'b1, 1'b1, 1'b0);


    reset;

   $finish;
end


    initial begin

        $monitor(
            "TIME=%0t | PCLK=%b | RESET=%b | SS=%b | "
            ,"SCLK=%b | COUNTER=%0d | DIVISOR=%0d",
            $time,
            PCLK,
            PRESET_n,
            ss,
            sclk,
            DUT.counter,
            baudratedivisor
        );

    end

endmodule