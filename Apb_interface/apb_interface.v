`define SPI_APB_DATA_WIDTH 8
`define SPI_REG_WIDTH 8
`define SPI_APB_ADDR_WIDTH 3


module apb_interface(
    input PCLK, 
    input PRESET_n,
    input [`SPI_APB_ADDR_WIDTH-1:0] PADDR,
    input PSEL,
    input PENABLE,
    input PWRITE,
    input [`SPI_APB_DATA_WIDTH-1:0] PWDATA,
    input ss,
    input receive_data,
    input [7:0] data_miso,
    input tip,

    output reg [`SPI_APB_DATA_WIDTH-1:0] PRDATA,
    output PREADY,
    output PSLVERR,
    output reg spi_interrupt_request,
    output reg send_data,
    output mstr,
    output cpol,
    output cpha,
    output lsbfe,
    output spiswai,
    output reg [7:0] data_mosi,
    output [1:0] spi_mode,
    output [2:0] sppr,
    output [2:0] spr
);

reg [`SPI_REG_WIDTH-1:0] SPI_CR_1;
reg [`SPI_REG_WIDTH-1:0] SPI_CR_2;
reg [`SPI_REG_WIDTH-1:0] SPI_BR;
reg [`SPI_REG_WIDTH-1:0] SPI_SR;
reg [`SPI_REG_WIDTH-1:0] SPI_DR;


wire wr_en;
wire rd_en;

wire spie, spe, sptie, ssoe;
wire modfen;
wire modf;
wire spif, sptef;


//APB FSM
reg [1:0] state, next_state;

localparam IDLE = 2'b00;
localparam SETUP = 2'b01;
localparam ENABLE = 2'b10;


always@(posedge PCLK or negedge PRESET_n) begin
    if(!PRESET_n)
    state <= IDLE;
    else 
    state <= next_state;
end

always @(*)begin
    next_state = state;

    case(state)

    IDLE: begin
        if(PSEL && !PENABLE)
        next_state = SETUP;
        else 
        next_state = IDLE;
    end

    SETUP: begin
        if(PSEL && PENABLE)
        next_state = ENABLE;
        else if(!PSEL)
        next_state = IDLE;
        else 
        next_state = SETUP;
    end

    ENABLE: begin
        if(!PSEL)
        next_state = IDLE;
        else if(!PENABLE)
        next_state = SETUP;
        else
        next_state = ENABLE;
    end

    default: next_state = IDLE;

    endcase
end


//SPI FSM

reg [1:0] mode, next_mode;

localparam RUN = 2'b00;
localparam WAIT = 2'b01;
localparam STOP = 2'b10;


//state_register

always@(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)
    mode <= RUN;
    else
    mode <= next_mode; 
end

always @(*)begin
    next_mode = mode;

    case(mode)

    RUN: begin
        if(!spe)
        next_mode = WAIT;
        else 
        next_mode = RUN;
    end

    WAIT: begin
        if(spe)
        next_mode = RUN;
        else if(spiswai)
        next_mode = STOP;
        else 
        next_mode = WAIT;
    end

    STOP: begin
        if(spe)
        next_mode = RUN;
        else if(!spiswai)
        next_mode = WAIT;
        else
        next_mode = STOP;
    end

    default: next_mode = RUN;

    endcase
end

assign spi_mode = mode;

wire [7:0] cr2_mask = 8'b00011011;
wire [7:0] br_mask = 8'b01110111;

assign rd_en = (!PWRITE && (state == ENABLE)) ? 1'b1 : 1'b0;
assign wr_en = (PWRITE && (state == ENABLE)) ? 1'b1 : 1'b0;

assign PSLVERR = (state == ENABLE) ? (!tip) : 1'b0;
assign PREADY = (state == ENABLE) ? 1'b1 : 1'b0;


assign lsbfe = SPI_CR_1[0];
assign ssoe = SPI_CR_1[1];
assign cpha = SPI_CR_1[2];
assign cpol = SPI_CR_1[3];
assign mstr = SPI_CR_1[4];
assign sptie = SPI_CR_1[5];
assign spe = SPI_CR_1[6];
assign spie = SPI_CR_1[7];

assign modfen = SPI_CR_2[4];
assign spiswai = SPI_CR_2[1];

assign spr = SPI_BR[2:0];
assign sppr = SPI_BR[6:4];

assign sptef = (SPI_DR == 8'h00) ? 1'b1 : 1'b0;
assign spif = (SPI_DR != 8'h00) ? 1'b1 : 1'b0;
assign modf = (!ss && mstr && modfen && !ssoe);

//status register
always @(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)
        SPI_SR <= 8'b00100000;
    else
        SPI_SR <= {spif,1'b0,sptef,modf,4'b0};
end

//Control register 1
always @(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
        SPI_CR_1 <= 8'h04;
    end 
    else begin
        if(wr_en)begin
            if(PADDR == 3'b000)begin
                SPI_CR_1 <= PWDATA;
            end
            else begin
                SPI_CR_1 <= SPI_CR_1;
            end
        end
    end
end
    

//Control register 2
always @(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
        SPI_CR_2 <= 8'h00;
    end
    else begin
        if(wr_en)begin
            if(PADDR == 3'b001)begin
                SPI_CR_2 <= PWDATA & cr2_mask;
            end
            else begin
                SPI_CR_2 <= SPI_CR_2;
            end
        end
    end
end


//Baudrate register
always @(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
        SPI_BR <= 8'h00;
    end
    else begin
        if(wr_en)begin
            if(PADDR == 3'b010)begin
                SPI_BR <= PWDATA & br_mask;
            end
            else begin
                SPI_BR <= SPI_BR;
            end
        end
    end
end
      

//Data register
always @(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)begin
        SPI_DR <= 8'h00;
    end
    else begin
        if(wr_en)begin
            if(PADDR == 3'b101)
            SPI_DR <= PWDATA;
            else 
            SPI_DR <= SPI_DR;
        end
        else begin
            if((spi_mode == RUN || spi_mode == WAIT) && (SPI_DR == PWDATA) && (SPI_DR != data_miso))
            SPI_DR <= 8'h00;
            else begin
                if((spi_mode == RUN || spi_mode == WAIT) && receive_data)
                SPI_DR <= data_miso;
                else
                SPI_DR <= SPI_DR;
            end
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
//Read data

always @(*)begin
    if(!rd_en)
    PRDATA = 8'b0;
    else begin
        case(PADDR)
        3'd0: PRDATA = SPI_CR_1;
        3'd1: PRDATA = SPI_CR_2;
        3'd2: PRDATA = SPI_BR;
        3'd3: PRDATA = SPI_SR;
        3'd5: PRDATA = SPI_DR;
        default: PRDATA = 8'b0;
        endcase
    end
end

//send data

always @(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)
    send_data <= 1'b0;
    else begin
        if(wr_en)begin
            send_data <= send_data;
        end
        else begin
            if((spi_mode == RUN || spi_mode == WAIT) && (SPI_DR == PWDATA) && (SPI_DR != data_miso))
            send_data <= 1'b1;
            else begin
            if((spi_mode == RUN) || (spi_mode == WAIT) && receive_data)
            send_data <= 1'b0;
            else 
            send_data <= 1'b0;
            end
        end
    end
end


// always @(posedge PCLK or negedge PRESET_n)begin
//     if(!PRESET_n)
//     send_data <= 1'b0;
//     else 
//     if(wr_en)begin
//         if((spi_mode == RUN || spi_mode == WAIT) && SPI_DR == PWDATA && SPI_DR != data_miso)
//         send_data <= 1'b1;
//         else 
//         send_data <= 1'b0;
//     end
//     else 
//     send_data <= 1'b0;
// end


//mosi data

always @(posedge PCLK or negedge PRESET_n)begin
    if(!PRESET_n)
    data_mosi <= 8'b0;
    else  if(!wr_en)begin
        if((SPI_DR == PWDATA) && (SPI_DR != data_miso) && (spi_mode == RUN || spi_mode == WAIT))
            data_mosi <= SPI_DR;
        else
        data_mosi <= data_mosi;
    end
    else 
    data_mosi <= data_mosi;     
end

//spi interrupt request

always @(*) begin
    spi_interrupt_request = 1'b0;

    if (!spie && !sptie) begin
        spi_interrupt_request = 1'b0;
    end
    else if (spie && !sptie) begin
        spi_interrupt_request = spif || modf;
    end
    else if (!spie && sptie) begin
        spi_interrupt_request = sptef;
    end
    else begin
        spi_interrupt_request = spif || modf || sptef;
    end
end

endmodule