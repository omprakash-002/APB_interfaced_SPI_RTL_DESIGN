module top_tb;

reg PCLK;
reg PRESET_n;
reg [2:0] PADDR;
reg PWRITE;
reg PSEL;
reg PENABLE;
reg [7:0] PWDATA;
reg miso;

wire ss;
wire sclk;
wire spi_interrupt_request;
wire mosi;
wire [7:0] PRDATA;
wire PREADY;
wire PSLVERR;

top DUT(
    .PCLK(PCLK),
    .PRESET_n(PRESET_n),
    .PADDR(PADDR),
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWDATA(PWDATA),
    .miso(miso),
    .ss(ss),
    .sclk(sclk),
    .spi_interrupt_request(spi_interrupt_request),
    .mosi(mosi),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR)
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
    PCLK = 1'b0;
    PRESET_n = 1'b0;
    PADDR = 3'b000;
    PWRITE = 1'b0;
    PSEL = 1'b1;
    PENABLE = 1'b0;
    PWDATA = 8'b0;
    miso = 1'b0;
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

task write_data_reg(input [7:0] data_reg);
begin
    @(negedge PCLK)
    PADDR = 3'b101;
    PWRITE = 1'b1;
    PSEL = 1'b1;
    PENABLE = 1'b0;
    PWDATA = data_reg;

    @(negedge PCLK)
    PADDR = 3'b101;
    PWRITE = 1'b1;
    PSEL = 1'b1;
    PENABLE = 1'b1;
    PWDATA = data_reg;

    @(negedge PCLK)
    wait(PREADY)
    PENABLE = 1'b0;

end
endtask

// task write_cr2(input [7:0] ctrl_reg2);
// begin
    
//     @(negedge PCLK) //CR2
//     PADDR = 3'b001;
//     PWRITE = 1'b1;
//     PSEL = 1'b1;
//     PENABLE = 1'b0; //Setup state
//     PWDATA = ctrl_reg2;

//     @(negedge PCLK)
//     PADDR = 3'b001;
//     PWRITE = 1'b1;
//     PSEL = 1'b1;
//     PENABLE = 1'b1; //Enable state
//     PWDATA = ctrl_reg2;

//     @(negedge PCLK)
//     wait(PREADY)
//     PENABLE = 1'b0;

// end
// endtask


// task wait_mode;
// begin
//   wait(ss == 1'b0);
//   repeat(3)@(posedge sclk);

//   @(negedge PCLK);
//   write_cr2(8'b00000010);

//   repeat(10)@(negedge PCLK);

//   write_cr2(8'b00000000);

// end
// endtask


//write data_miso lsbfe = 1 & cpol and cpha differs
task miso_data_neg_lsbfe(input [7:0] data);
integer i;
begin
    miso = 1'bz;
    wait(~ss)
    for(i = 0; i <= 7; i= i+1)begin
        @(negedge sclk)
        miso = data[i];
    end
end
endtask

// write data_miso lsbfe = 0 & cpol ad cpha differs
task miso_data_neg_lsbfe0(input [7:0] data);
integer i;
begin
    miso = 1'bz;
    wait(~ss)
    for(i = 7; i >= 0; i = i-1)begin
        @(negedge sclk)
        miso = data[i];
    end 
end
endtask

//write data_miso lsbfe = 1 & cpol cpha are same
task miso_data_pos_lsbfe(input [7:0] data);
integer i;
begin
    miso = 1'bz;
    wait(~ss)
    for(i = 0; i<= 7 ; i = i+1)begin
        @(negedge sclk)
        miso = data[i];
    end
end
endtask

//write data_miso lsbfe = 0 & cpol cpha are same
task miso_data_pos_lsbfe0(input [7:0] data);
integer i;
begin
    miso = 1'bz;
    wait(~ss)
    for(i = 7; i>= 0; i = i-1)begin
        @(negedge sclk)
        miso = data[i];
    end
end
endtask

//Read registers
task read_register(input [2:0] address);
begin
    @(negedge PCLK)
    PADDR = address;
    PWRITE = 1'b0;
    PSEL = 1'b1;
    PENABLE = 1'b0;

    @(negedge PCLK)
    PADDR = address;
    PWRITE = 1'b0;
    PSEL = 1'b1;
    PENABLE = 1'b1;

    @(negedge PCLK)
    wait(PREADY)
    PENABLE = 1'b0;

end
endtask

initial begin
    initialization;
    reset;
    write_register(8'b00011011, 8'b00000000, 8'b00000001);
    
    // fork 
    //     begin
    //         write_data_reg(8'hAA);
    write_data_reg(8'b01010101);
    miso_data_neg_lsbfe(8'b11001100);
    //     end

    //     begin
    //         wait_mode();
    //     end
    // join

    read_register(3'b000);
    read_register(3'b001);
    read_register(3'b010);
    read_register(3'b011);
    read_register(3'b101);
end

initial begin
    #5000 $finish;
end

endmodule
