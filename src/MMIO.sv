
module MMIO
(
    input wire clk,
    input wire rst,
    
    IF_MMIO.MEM IF_mem,
    
    output reg OUT_SPI_cs,
    output reg OUT_SPI_clk,
    output reg OUT_SPI_mosi,
    input wire IN_SPI_miso,

    output wire OUT_uartTx,
    input wire IN_uartRx,
    
    output reg OUT_powerOff,
    output reg OUT_reboot,
    
    IF_CSR_MMIO.MMIO OUT_csrIf
);


// Registered Inputs
reg reReg;
reg weReg;
reg[3:0] wmReg;
reg[31:0] writeAddrReg;
reg[31:0] readAddrReg;
reg[31:0] dataReg;

assign IF_mem.rbusy = 0;
assign IF_mem.wbusy = aclintBusy || spiBusy || sysConBusy || uartBusy || weReg;

wire[31:0] aclintData;
wire aclintBusy;
wire aclintRValid;
ACLINT aclint
(
    .clk(clk),
    .rst(rst),
    
    .IN_re(reReg),
    .IN_raddr(readAddrReg[31:2]),
    .OUT_rdata(aclintData),
    .OUT_rbusy(aclintBusy),
    .OUT_rvalid(aclintRValid),
    
    .IN_we(weReg),
    .IN_wmask(wmReg),
    .IN_waddr(writeAddrReg[31:2]),
    .IN_wdata(dataReg),
    
    .OUT_mtime(OUT_csrIf.mtime),
    .OUT_mtimecmp(OUT_csrIf.mtimecmp)
);

wire[31:0] spiData;
wire spiBusy;
wire spiRValid;
SPI#(.ADDR(`SPI_ADDR)) spi
(
    .clk(clk),
    .rst(rst),
    
    .IN_re(reReg),
    .IN_raddr(readAddrReg),
    .OUT_rdata(spiData),
    .OUT_rbusy(spiBusy),
    .OUT_rvalid(spiRValid),
    
    .IN_we(weReg),
    .IN_wmask(wmReg),
    .IN_waddr(writeAddrReg),
    .IN_wdata(dataReg),
    
    .OUT_SPI_cs(OUT_SPI_cs),
    .OUT_SPI_clk(OUT_SPI_clk),
    .OUT_SPI_mosi(OUT_SPI_mosi),
    .IN_SPI_miso(IN_SPI_miso)
);

wire[31:0] uartData;
wire uartBusy;
wire uartRValid;
`ifdef ENABLE_UART
UART#(.ADDR(`UART_ADDR)) uart
(
    .clk(clk),
    .rst(rst),
    
    .IN_re(reReg),
    .IN_raddr(readAddrReg),
    .OUT_rdata(uartData),
    .OUT_rbusy(uartBusy),
    .OUT_rvalid(uartRValid),
    
    .IN_we(weReg),
    .IN_wmask(wmReg),
    .IN_waddr(writeAddrReg),
    .IN_wdata(dataReg),
    
    .OUT_uartTX(OUT_uartTx),
    .IN_uartRX(IN_uartRx)
);
`else
    assign uartBusy = 0;
    assign uartRValid = 0;
    assign uartData = 'x;
    assign OUT_uartTx = 0;
`endif

wire[31:0] sysConData;
wire sysConBusy;
wire sysConRValid;
SysCon#(.ADDR(`SYSCON_ADDR)) sysCon
(
    .clk(clk),
    .rst(rst),
    
    .IN_re(reReg),
    .IN_raddr(readAddrReg[31:2]),
    .OUT_rdata(sysConData),
    .OUT_rbusy(sysConBusy),
    .OUT_rvalid(sysConRValid),
    
    .IN_we(weReg),
    .IN_wmask(wmReg),
    .IN_waddr(writeAddrReg[31:2]),
    .IN_wdata(dataReg),
    
    .OUT_powerOff(OUT_powerOff),
    .OUT_reboot(OUT_reboot)
    
);

always_comb begin
    IF_mem.rdata = 'x;
    if (aclintRValid) IF_mem.rdata = aclintData;
    if (spiRValid) IF_mem.rdata = spiData;
    if (sysConRValid) IF_mem.rdata = sysConData;
    if (uartRValid) IF_mem.rdata = uartData;
end

always_ff@(posedge clk) begin
    
    if (rst) begin
        weReg <= 0;
        reReg <= 0;
    end
    else begin
        reReg <= !IF_mem.re;
        weReg <= !IF_mem.we;
        wmReg <= IF_mem.wmask;
        readAddrReg <= IF_mem.raddr;
        writeAddrReg <= IF_mem.waddr;
        dataReg <= IF_mem.wdata;
    end

end

endmodule
