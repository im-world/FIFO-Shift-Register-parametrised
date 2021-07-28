`timescale 1ns / 1ps                                      //default time unit is 1ns, with a precision of 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2021 16:49:07
// Design Name: Behaviioural Model of FIFO Shift Register
// Module Name: FIFO_shift_reg_beh
// Project Name: EE 258 Digital Design Lab      
// Description: 
// 
// Dependencies: None
// 
// 
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



//FIFO shift register implementation using a queue model

//The data written arranges itself in the memory in a queue, with the
//first input always being at position 0 (the first position) of the 
//queue. The position 0 is where the data is read from the FIFO shift 
//register. Full and Empty flags are provided.
 
//Read has precedence/priority over write

module FIFO_shift_reg_beh
#(
    parameter FIFO_width = 32,                          //parameters for reusability; default values assigned
    parameter FIFO_depth = 10
 )
(
    
    output reg [FIFO_width - 1 : 0] dataOut,                //n-bit output word; First In; n = FIFO_width
    output empty, full,                                     //to indicate if reading/writing is safe
                                                            //(if full, then writing not allowed)
                                                            //(if empty, then reading not allowed)
    
    input readEnable, writeEnable,                          //controls to read/write            
    input [FIFO_width - 1 : 0] dataIn,                      //n-bit input word; Last to be in; n = FIFO_width
    input enable, reset, clk                                //active-high enable,  active-high enable-dependent reset, clock signal    
    
    );

    parameter noAddressBits = $clog2(FIFO_depth);                   //log of parameter is NOT calculated on hardware; '$' indicates it is a system task; 
                                                                    //helps to determine number of address bits for given depth     
                                                                    //it raises a warning due to parameter being inaccessible outside
                                                                    //the module, but this is fact is the desired behaviour                           
    
                                                                    //reg [noAddressBits - 1 : 0]  wordsFilled = 0; not needed now                     
    
    reg [FIFO_width - 1 : 0] FIFO_memory [FIFO_depth - 1 : 0];      //A memory of 'FIFO_depth' words with 'FIFO_width' bits per word
    
    reg [noAddressBits - 1 : 0]  writePosition = 0;                 //tracks the position to which to write; begins with 0, increments if
                                                                    //a word is written, and decrements if a word is read
    
    reg fullFlag = 1'b0;                                            //indicates if FIFO_memory is full 'during writing'; assists the 'full' output
    
    assign empty = (writePosition == 0)? 1'b1:1'b0;                 //ternary operator '?' to check if FIFO is either full or empty, and 
    assign full = ((writePosition == FIFO_depth - 1) && fullFlag)? 1'b1:1'b0;     //then set the corresponding bits
    
    integer i;                                                      //used in for loops
    
    always @(posedge clk)                                   //always, since we are creating a behavioural model 
        begin 

            if(enable == 0)                                 //if not enabled, do nothing
                begin
                end
            else
                begin
                   
                    if(reset == 1)                          //if reset, reset the write position, dataOut, fullFlag, and FIFO memory
                        begin
                            writePosition <= 0;
                            dataOut <= 0;
                            fullFlag <= 0;              
                            for (i = 0; i < FIFO_depth; i = i + 1)   //resetting memory; note that the 'for' loop is a coding construct tha
                                                                     //helps reduce typing; it is NOT a 'hardware-for-loop; 
                                begin
                                    FIFO_memory[i] <= {FIFO_width{1'b0}};     // non-blocking assignment used, since synchronous 
                                end
                                
                        end
                   
                    else if (readEnable && !empty)          //if read, and not empty
                        begin
                            dataOut <= FIFO_memory[0];      //read the right-most (first in) word; 
                                                            //we feed data from the left, so the 0th bus
                                                            //is always the first-in bus unless the FIFO is empty  
                            
                                                            //FIFO_memory[FIFO_depth - 2 : 0] <= FIFO_memory[FIFO_depth - 1 : 1];  
                                                            //not possible, since FIFO_memory is a memory
                            
                            for(i = 0; i < FIFO_depth - 1; i = i + 1)       
                                begin
                                    FIFO_memory[i] <= FIFO_memory[i+1];            //right shift, since the right-most bus is now read
                                end
                            
                            FIFO_memory[FIFO_depth - 1] <= {FIFO_width{1'b0}};             //as all buses shift to the right, the left-most bus
                                                                                            //is 'vacant', that is, it is not being used; while
                                                                                            //it is not necessary, we still reset it to 0 as a good practice
                            
                            writePosition <= writePosition - 1;      //one written bus is read, so read position is decremented (moves towards right)
                            fullFlag <= 1'b0;                        //resets the full flag; if it was 1, reading from a full FIFO would make it not-full again
                            
                        end                
             
                    else if (writeEnable && !full)            //if write, and not full
                        begin
                            
                            FIFO_memory[writePosition] <= dataIn;          //write input data to the bus at the write position of the FIFO_memory
                            
                            if(writePosition == FIFO_depth - 1)
                                begin
                                    fullFlag <= 1'b1;               //if write position was already 'FIFO_depth - 1', and the FIFO_memory was not
                                                                    //full (parent if condition), this means that we are writing at the
                                                                    //left-most position. After we write, the FIFO_memory will be full; However,
                                                                    //since writePosition cannot attain the value FIFO_depth, it cannot be 
                                                                    //incremented. We use a flag called fullFlag to indicate that such a 
                                                                    //process happened, and the FIFO_memory is now full.
                                end
                            else
                                begin
                                    writePosition <= writePosition + 1;     //write position is incremented (moves towards left), as a bus is written
                                end
                        end
                   
                    else
                        begin
                        end 
                end
        end    
endmodule






