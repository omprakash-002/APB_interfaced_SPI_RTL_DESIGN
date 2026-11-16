module slave_select_tb;

reg PRESET_n;
reg [1:0] spi_mode;
reg mstr;
reg spiswai;
reg PCLK;
reg send_data;
reg [11:0] baudratedivisor;

wire ss;
wire receive_data;
wire tip;

slave_select DUT(
    .PRESET_n(PRESET_n),
    .spi_mode(spi_mode),
    .mstr(mstr),
    .spiswai(spiswai),
    .PCLK(PCLK),
    .send_data(send_data),
    .baudratedivisor(baudratedivisor),
    .ss(ss),
    .receive_data(receive_data),
    .tip(tip)
);

initial begin
    PCLK = 1'b0;
    forever #5 PCLK = ~PCLK;
end

task reset;
begin
    @(negedge PCLK);
    PRESET_n = 1'b0;
    @(negedge PCLK);
    PRESET_n = 1'b1;
end
endtask

task initialization;
begin

    PRESET_n = 1'b0;
    spi_mode = 2'b00;
    mstr = 1'b0;
    spiswai = 1'b0;
    send_data = 1'b0;
    baudratedivisor = 12'd4;
    
end
endtask

task stimulus;
begin
    @(negedge PCLK);
    mstr = 1'b1;
    spiswai = 1'b0;
    spi_mode = 2'b00;
    send_data = 1'b1;
    @(negedge PCLK);
    send_data = 1'b0;

end
endtask

initial begin
    initialization;
    reset;
    
    stimulus;
    wait(receive_data == 1'b1);
    @(negedge PCLK);
    

    mstr = 1'b0;
    repeat(3) @(negedge PCLK);


    mstr = 1'b1;
    spi_mode = 2'b10;
    repeat(3) @(negedge PCLK);


    spi_mode = 2'b01;
    spiswai = 1'b1;
    repeat(3) @(negedge PCLK);


    reset;


    $finish;
end


initial begin

$monitor(
        "TIME=%0t | CLK=%b | RESET=%b | MODE=%b | MSTR=%b | WAIT=%b | SEND=%b | DIVISOR=%0d | TARGET=%0d | COUNTER=%0d | SS=%b | TIP=%b | RCV=%b | RECEIVE=%b",
        $time,
        PCLK,
        PRESET_n,
        spi_mode,
        mstr,
        spiswai,
        send_data,
        baudratedivisor,
        DUT.target,
        DUT.counter,
        ss,
        tip,
        DUT.rcv,
        receive_data
    );
end

endmodule
