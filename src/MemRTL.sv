module MemRTL
#(
    parameter WORD_SIZE=32,
    parameter NUM_WORDS=1024
)
(
    input wire clk,
    
    input wire IN_nce,
    input wire IN_nwe,
    input wire[$clog2(NUM_WORDS)-1:0] IN_addr,
    input wire[WORD_SIZE-1:0] IN_data,
    input wire[(WORD_SIZE/8)-1:0] IN_wm,
    output reg[WORD_SIZE-1:0] OUT_data,
    
    input wire IN_nce1,
    input wire[$clog2(NUM_WORDS)-1:0] IN_addr1,
    output reg[WORD_SIZE-1:0] OUT_data1
);

reg[WORD_SIZE-1:0] mem[NUM_WORDS-1:0];

reg ce_reg = 1;
reg ce1_reg = 1;
reg we_reg;
reg[$clog2(NUM_WORDS)-1:0] addr_reg;
reg[$clog2(NUM_WORDS)-1:0] addr1_reg;
reg[WORD_SIZE-1:0] data_reg;
reg[(WORD_SIZE/8)-1:0] wm_reg;

reg dbgMultiple;

always@(posedge clk) begin

    dbgMultiple <= 0;
    
    ce_reg <= IN_nce;
    ce1_reg <= IN_nce1;
    we_reg <= IN_nwe;
    addr_reg <= IN_addr;
    addr1_reg <= IN_addr1;
    data_reg <= IN_data;
    wm_reg <= IN_wm;
    
    if (!ce_reg) begin
        if (!we_reg) begin
            for (integer i = 0; i < WORD_SIZE/8; i=i+1) begin
                if (wm_reg[i])
                    mem[addr_reg][(8*i)+:8] <= data_reg[(8*i)+:8];
            end
            //$display("write %x to %x (%b)", data_reg, addr_reg, wm_reg);
            // OUT_data <= 0;
        end
        else begin
            OUT_data <= mem[addr_reg];
        end
    end
    
    if (!ce1_reg) begin
        OUT_data1 <= mem[addr1_reg];
    end
    
    if (!ce1_reg && !ce_reg && addr1_reg == addr_reg) begin
        $display("Warning: Multiple %m accesses at same address %x, we=%b", addr_reg, we_reg);
        dbgMultiple <= 1;
        OUT_data1 <= 'x;
        
        /*if (!we_reg) begin
            for (integer i = 0; i < WORD_SIZE/8; i=i+1) begin
                if (wm_reg[i])
                    mem[addr_reg][(8*i)+:8] <= 'x;
            end
        end
        else begin
            OUT_data <= 'x;
        end
        
        assert(0);*/
    end
end

endmodule
