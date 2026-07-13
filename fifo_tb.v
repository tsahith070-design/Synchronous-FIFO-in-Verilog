`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2026 19:09:58
// Design Name: 
// Module Name: fifo_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;

    reg clk;
    reg areset;
    reg [DATA_WIDTH-1:0] wr_data;
    reg wr_en;
    reg rd_en;
    wire [DATA_WIDTH-1:0] rd_data;
    wire full;
    wire empty;
    wire [$clog2(FIFO_DEPTH):0] count;

    integer i;

    // Instantiation
    FIFO_DESIGN #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut(
        .clk     (clk),
        .areset  (areset),
        .wr_data (wr_data),
        .wr_en   (wr_en),
        .rd_en   (rd_en),
        .rd_data (rd_data),
        .full    (full),
        .empty   (empty),
        .count   (count)
    );

    // Clock: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("FIFO Testbench Start");

        // Initialize / reset
        areset  = 1;
        wr_en   = 0;
        rd_en   = 0;
        wr_data = 0;

       repeat (2) @(posedge clk);
       @(negedge clk);   // ✓ fixes areset input race
       areset = 0;
       @(posedge clk);
       #1;             // ✓ fixes empty/full/count output race - keep this

        // Check reset state
        if (empty && !full && count == 0)
            $display("PASS: Reset state OK (empty=1, full=0, count=0)");
        else
            $display("FAIL: Reset state wrong (empty=%b full=%b count=%0d)", empty, full, count);

       
        // Test 1: Write until FIFO is full
        $display(" Test 1: Filling FIFO ");
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            @(negedge clk);        
            wr_en   = 1;
            wr_data = i + 8'h10;
            @(posedge clk);           // DUT samples wr_en/wr_data HERE -one write per iteration
        end
        @(negedge clk);
        wr_en = 0;
        @(posedge clk);
        #1;

        if (full)
            $display("PASS: FIFO full asserted after %0d writes", FIFO_DEPTH);
        else
            $display("FAIL: FIFO not full after %0d writes (count=%0d)", FIFO_DEPTH, count);

        // Try writing while full (should be ignored)
        @(negedge clk);
        wr_en   = 1;
        wr_data = 8'hFF;
        @(posedge clk);
        #1;
        wr_en = 0;

        if (count == FIFO_DEPTH)
            $display("PASS: Write blocked correctly while full (count still %0d)", count);
        else
            $display("FAIL: Write while full changed count to %0d", count);

        
        
        // Test 2: Read until FIFO is empty, check data order    
        $display(" Test 2: Drain FIFO ");
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            @(negedge clk);
            rd_en = 1;
            @(posedge clk);           // rd_data updates HERE - one read per iteration
            #1;                       // let rd_data settle before checking
            if (rd_data == i + 8'h10)
                $display("PASS: Read #%0d correct, data=%h", i, rd_data);
            else
                $display("FAIL: Read #%0d expected %h, got %h", i, i + 8'h10, rd_data);
            rd_en = 0;                // drop before the next iteration re-asserts it
        end

        if (empty)
            $display("PASS: FIFO empty asserted after draining");
        else
            $display("FAIL: FIFO not empty after draining (count=%0d)", count);

        // Try reading while empty (should be ignored)
        @(negedge clk);
        rd_en = 1;
        @(posedge clk);
        #1;
        rd_en = 0;

        if (count == 0)
            $display("PASS: Read blocked correctly while empty (count still 0)");
        else
            $display("FAIL: Read while empty changed count to %0d", count);

       
        
        // Test 3: Simultaneous read & write 
        
        $display(" Test 3: Simultaneous read & write");

        // Put a few items in first
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge clk);
            wr_en   = 1;
            wr_data = 8'hA0 + i;
            @(posedge clk);
        end
        @(negedge clk);
        wr_en = 0;
        @(posedge clk);
        #1;

        begin : sim_test
            reg [$clog2(FIFO_DEPTH):0] count_before;
            count_before = count;      // BEFORE driving the simultaneous op

            @(negedge clk);
            wr_en   = 1;
            rd_en   = 1;
            wr_data = 8'hB0;
            @(posedge clk);            // both write and read sampled on this same edge
            #1;
            wr_en = 0;
            rd_en = 0;

            if (count == count_before)
                $display("PASS: Count unchanged on simultaneous read+write (count=%0d)", count);
            else
                $display("FAIL: Count changed on simultaneous read+write (before=%0d after=%0d)",
                          count_before, count);
        end

        
        // Test 4: Async reset mid-operation
        
        $display(" Test 4: Async reset mid-operation");
        @(negedge clk);
        areset = 1;
        @(posedge clk);
        #1;
        if (empty && !full && count == 0)
            $display("PASS: Async reset cleared FIFO correctly");
        else
            $display("FAIL: Async reset did not clear FIFO (empty=%b full=%b count=%0d)",
                      empty, full, count);
        areset = 0;
        wr_en  = 0;
        rd_en  = 0;

        $display("FIFO Testbench Done");
        $finish;
    end

endmodule
