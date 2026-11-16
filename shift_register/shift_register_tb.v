module shift_register_tb;

reg PCLK;
reg PRESET_n;
reg ss;
reg send_data;
reg lsbfe;
reg cpha;
reg cpol;
wire miso_receive_neg_sclk;
wire miso_receive_pos_sclk;
wire mosi_send_neg_sclk;
wire mosi_send_pos_sclk;
reg [7:0] data_mosi;
reg miso;
reg receive_data;

reg [1:0] spi_mode;
reg spiswai;
reg [2:0] sppr;
reg [2:0] spr;

wire mosi;
wire [7:0] data_miso;
wire sclk;
wire [11:0] baudratedivisor;

shift_register dut(
    .PCLK(PCLK),
    .PRESET_n(PRESET_n),
    .ss(ss),
    .send_data(send_data),
    .lsbfe(lsbfe),
    .cpha(cpha),
    .cpol(cpol),
    .miso_receive_neg_sclk(miso_receive_neg_sclk),
    .miso_receive_pos_sclk(miso_receive_pos_sclk),
    .mosi_send_neg_sclk(mosi_send_neg_sclk),
    .mosi_send_pos_sclk(mosi_send_pos_sclk),
    .data_mosi(data_mosi),
    .miso(miso),
    .receive_data(receive_data),
    .mosi(mosi),
    .data_miso(data_miso)
);

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
    PCLK = 1'b0;
    forever #5 PCLK = ~PCLK;
end

task initialization();
begin
    PRESET_n = 1'b0;
    ss = 1'b1;
    send_data = 1'b0;
    lsbfe = 1'b0;
    cpha = 1'b0;
    cpol = 1'b0;
    data_mosi = 8'h00;
    miso = 1'b0;
    receive_data = 1'b0;
    spr = 3'b000;
    sppr = 3'b000;
    spi_mode = 2'b00;
    spiswai = 1'b0;
end
endtask

task reset();
begin
    @(negedge PCLK);
    PRESET_n = 1'b0;
    @(negedge PCLK);
    PRESET_n = 1'b1;
end
endtask

task stimulus(input a , input b);
begin
    @(negedge PCLK);
    
    spr = 3'b001;
    sppr = 3'b000;
    spi_mode = 2'b01;
    spiswai = 1'b0;
    cpha = a;
    cpol = b;
end
endtask


task send_stimulus(input [7:0] data, input lsb);
begin

    @(negedge PCLK);
    send_data = 1'b1;
    data_mosi = data;
    lsbfe = lsb;
    
    @(negedge PCLK);
    send_data = 1'b0;
    ss = 1'b0;

end
endtask

task wait_mode;
begin
  wait(ss == 1'b0);
  repeat(3)@(posedge sclk);

  @(negedge PCLK);
  spi_mode = 2'b01;
  spiswai = 1'b1;

  repeat(10)@(negedge PCLK);

  spi_mode = 2'b00;
  spiswai = 1'b0;

end
endtask

task receive_stimulus(input [7:0] data , input b);
integer i;
begin
    lsbfe=b;
    wait (ss == 1'b0);
    
    if(lsbfe == 1'b1) begin
      for(i = 0; i < 8; i = i + 1) begin
        miso = data[i];
        @(posedge sclk);
      end
    end
    else begin
      for(i = 7; i >= 0; i = i - 1) begin
        miso = data[i];
        @(posedge sclk);
      end
    end
  
    
  end
endtask
        
initial begin
  initialization();
  reset();
  stimulus(1'b1, 1'b1);

  fork 
    begin
      send_stimulus(8'hAA,1);
      receive_stimulus(8'hBB,1);
    end

    begin
      wait_mode();
    end

  join

  @(negedge PCLK);
  receive_data = 1'b1;
  @(negedge PCLK);
  receive_data = 1'b0;

  ss = 1'b1;
  
  reset();
  
  // stimulus(1'b0, 1'b1);
  // send_stimulus(8'hAB, 0);

  // receive_stimulus(8'hCC, 0);
 
  // @(negedge PCLK);
  // receive_data = 1'b1;
  // @(negedge PCLK);
  // receive_data = 1'b0;

  // ss = 1'b1;
  
  // reset();


end

 initial begin
                #2000;
                $finish;
        end

initial begin
    $monitor(
        "TIME=%0t | reset_n=%b | ss=%b | send_data=%b | lsbfe=%b | cpol=%b | cpha=%b | sclk=%b | MOSI=%b | MISO=%b | data_mosi=%h | data_miso=%h | count=%0d | count1=%0d | count2=%0d | count3=%0d",
        $time,
        PRESET_n,
        ss,
        send_data,
        lsbfe,
        cpol,
        cpha,
        sclk,
        mosi,
        miso,
        data_mosi,
        data_miso,
        dut.count,
        dut.count1,
        dut.count2,
        dut.count3
    );
end



endmodule