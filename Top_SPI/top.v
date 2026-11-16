module top(
    input PCLK,
    input PRESET_n,
    input [2:0] PADDR,
    input PWRITE,
    input PSEL,
    input PENABLE,
    input [7:0] PWDATA,
    input miso,

    output ss,
    output sclk,
    output spi_interrupt_request,
    output mosi,
    output [7:0] PRDATA,
    output PREADY,
    output PSLVERR
);


wire [1:0] spi_mode;
wire spiswai;
wire [2:0] sppr;
wire [2:0] spr;
wire cpol;
wire cpha;
wire lsbfe;
wire mstr;


wire send_data;
wire receive_data;
wire tip;


wire miso_receive_pos_sclk;
wire miso_receive_neg_sclk;
wire mosi_send_pos_sclk;
wire mosi_send_neg_sclk;


wire [11:0] baudratedivisor;
wire [7:0] data_mosi;
wire [7:0] data_miso;



Baudrategenerator baud(
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
    .miso_receive_pos_sclk(miso_receive_pos_sclk),
    .miso_receive_neg_sclk(miso_receive_neg_sclk),
    .mosi_send_pos_sclk(mosi_send_pos_sclk),
    .mosi_send_neg_sclk(mosi_send_neg_sclk),
    .baudratedivisor(baudratedivisor)
);

slave_select slave(
    .PCLK(PCLK),
    .PRESET_n(PRESET_n),
    .spi_mode(spi_mode),
    .mstr(mstr),
    .spiswai(spiswai),
    .send_data(send_data),
    .baudratedivisor(baudratedivisor),
    .ss(ss),
    .receive_data(receive_data),
    .tip(tip)
);

shift_register shift(
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

apb_interface apb(
    .PCLK(PCLK),
    .PRESET_n(PRESET_n),
    .PADDR(PADDR),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .ss(ss),
    .receive_data(receive_data),
    .data_miso(data_miso),
    .tip(tip),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR),
    .spi_interrupt_request(spi_interrupt_request),
    .send_data(send_data),
    .mstr(mstr),
    .cpol(cpol),
    .cpha(cpha),
    .lsbfe(lsbfe),
    .spiswai(spiswai),
    .data_mosi(data_mosi),
    .spi_mode(spi_mode),
    .sppr(sppr),
    .spr(spr)
);

endmodule