`define SPI_APB_DATA_WIDTH 8
`define SPI_REG_WIDTH 8
`define SPI_APB_ADDR_WIDTH 3

module apb_interface_tb;

reg PCLK;
reg PRESET_n;
reg [`SPI_APB_ADDR_WIDTH-1: 0] PADDR;
reg PSEL;
reg PENABLE;
reg PWRITE;
reg [`SPI_APB_DATA_WIDTH-1 : 0] PWDATA;
reg ss;
reg receive_data;
reg [7:0] data_miso;
reg tip;

wire [`SPI_APB_DATA_WIDTH-1 : 0] PRDATA;
wire PREADY;
wire PSLVERR;
wire spi_interrupt_request;
wire send_data;
wire mstr;
wire cpol;
wire cpha;
wire lsbfe;
wire spiswai;
wire [7:0] data_mosi;
wire [1:0] spi_mode;
wire [2:0] sppr;
wire [2:0] spr;

apb_interface DUT(
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


initial begin
    PCLK = 1'b0;
    forever #5 PCLK = ~PCLK;
end

task reset;
begin

    @(negedge PCLK)
    PRESET_n = 1'b0;
    @(negedge PCLK)
    PRESET_n = 1'b1;

end
endtask

task initialization;
begin
    PRESET_n = 1'b0;
    PADDR = 3'b000;
    PWRITE = 1'b0;
    PSEL = 1'b1;
    PENABLE = 1'b0;
    PWDATA = 8'b0;
    ss = 1'b1;
    data_miso = 8'b0;
    receive_data = 1'b0;
    tip = 1'b0;
end
endtask

task write_register(input [7:0] ctrl_reg1, input [7:0] ctrl_reg2, input [7:0] baud_reg);
begin

    @(negedge PCLK)// CR1
    PADDR = 3'b000;
    PWRITE = 1'b1;
    PSEL = 1'b1;
    PENABLE = 1'b0; //Setup state
    PWDATA = ctrl_reg1;

    @(negedge PCLK)
    PADDR = 3'b000;
    PWRITE = 1'b1;
    PSEL = 1'b1;
    PENABLE = 1'b1; //Enable state
    PWDATA = ctrl_reg1;

    @(negedge PCLK)
    wait(PREADY)
    PENABLE = 1'b0;

    @(negedge PCLK) //CR2
    PADDR = 3'b001;
    PWRITE = 1'b1;
    PSEL = 1'b1;
    PENABLE = 1'b0; //Setup state
    PWDATA = ctrl_reg2;

    @(negedge PCLK)
    PADDR = 3'b001;
    PWRITE = 1'b1;
    PSEL = 1'b1;
    PENABLE = 1'b1; //Enable state
    PWDATA = ctrl_reg2;

    @(negedge PCLK)
    wait(PREADY)
    PENABLE = 1'b0;

    @(negedge PCLK)// Baudrate reg
    PADDR = 3'b010;
    PWRITE = 1'b1;
    PSEL = 1'b1;
    PENABLE = 1'b0; //setup state
    PWDATA = baud_reg;

    @(negedge PCLK)
    PADDR = 3'b010;
    PWRITE = 1'b1;
    PSEL = 1'b1;
    PENABLE = 1'b1; //Enable state
    PWDATA = baud_reg;

    @(negedge PCLK)
    wait(PREADY)
    PENABLE = 1'b0;

end
endtask

// task write_cr2(input [7:0] data_reg);
// begin
//     @(negedge PCLK)
//     PADDR = 3'b001;
//     PWRITE = 1'b1;
//     PSEL = 1'b1;
//     PENABLE = 1'b0;
//     PWDATA = data_reg;

//     @(negedge PCLK)
//     PADDR = 3'b001;
//     PWRITE = 1'b1;
//     PSEL = 1'b1;
//     PENABLE = 1'b1;
//     PWDATA = data_reg;

//     @(negedge PCLK)
//     wait(PREADY)
//     PENABLE = 1'b0;

// end
// endtask

task write_data_reg(input [7:0] data_reg);
begin
    @(negedge PCLK)// data reg
    PADDR = 3'b101;
    PWRITE = 1'b1;
    PSEL = 1'b1;
    PENABLE = 1'b0;//Setup state
    PWDATA = data_reg;

    @(negedge PCLK)
    PADDR = 3'b101;
    PWRITE = 1'b1;
    PSEL = 1'b1;
    PENABLE = 1'b1;//Enable state
    PWDATA = data_reg;

    @(negedge PCLK)
    wait(PREADY)
    PENABLE = 1'b0;

end
endtask

task read_register(input [2:0]  address);
begin
    @(negedge PCLK)
    PADDR = address;
    PWRITE = 1'b0;
    PSEL = 1'b1;
    PENABLE = 1'b0; //Setup

    @(negedge PCLK)
    PADDR = address;
    PWRITE = 1'b0;
    PSEL = 1'b1;
    PENABLE = 1'b1; // Enable

    @(negedge PCLK)
    wait(PREADY)
    PENABLE = 1'b0;

end
endtask

initial begin
    initialization;
    reset;
    ss = 1'b0;
    receive_data = 1'b1;
    tip = 1'b1;
    data_miso = 8'hFC;
    write_register(8'b00011101, 8'b00000000, 8'b00000001);
    write_data_reg(8'hDD);
    read_register(3'b000);
    read_register(3'b001);
    read_register(3'b010);
    read_register(3'b011);
    read_register(3'b101);

end

initial
#5000 $finish();

endmodule

