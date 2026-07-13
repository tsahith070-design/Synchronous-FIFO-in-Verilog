`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2026 19:08:27
// Design Name: 
// Module Name: FIFO_DESIGN
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


module  FIFO_DESIGN#(parameter DATA_WIDTH=8,parameter FIFO_DEPTH=16)(
    input clk,
    input areset,
    
    input [DATA_WIDTH-1:0] wr_data,
    input wr_en,
    input rd_en,
    
    output reg [DATA_WIDTH-1:0] rd_data,
    output full,
    output empty,
    output reg [$clog2(FIFO_DEPTH):0]count

  
);
    localparam BR=$clog2(FIFO_DEPTH); //bits required to  locate the memeory address(fifo depth based)we need one bit more than
                                 //actually required cause of the way we checking the memory address is full or not
    
    reg [BR:0]wr_ptr,rd_ptr;                      //write and read pointer
    reg [DATA_WIDTH-1:0] fifoo [0:FIFO_DEPTH-1];  //memory
    
    always@(posedge clk or posedge areset)begin
        if(areset)               
            begin
                wr_ptr<=0;
                rd_ptr<=0;
                count<=0;
            end
        else 
            begin
            if(wr_en && ~full)begin      //write
            fifoo[wr_ptr[BR-1:0]]<=wr_data;
            wr_ptr<=wr_ptr+1;
            end
            if(rd_en && ~empty)begin    //read
            rd_data<=fifoo[rd_ptr[BR-1:0]];
            rd_ptr<=rd_ptr+1;           
            end
       
                ///////////counting
                if((wr_en && ~full)&&(rd_en && ~empty))
                    count<=count;
                else if(wr_en && ~full)
                    count<=count+1;
                else if(rd_en && ~empty)
                    count<=count-1;
                    
 
            end
    end
    assign full=(rd_ptr=={~wr_ptr[BR],wr_ptr[BR-1:0]});
    assign empty=(rd_ptr==wr_ptr);
    
    
    
endmodule

