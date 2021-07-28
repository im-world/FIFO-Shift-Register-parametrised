`timescale 1ns / 1ps                                    //default time unit is 1ns, with a precision of 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2021 14:41:27
// Design Name: 
// Module Name: FIFO_shift_reg_beh_tb
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


module FIFO_shift_reg_beh_tb
#(
    parameter FIFO_width = 32,                          //parameters for reusability; default values assigned
    parameter FIFO_depth = 10
 )
(
    );

    //Outputs of unit under test as registers, and inputs as wires (since simulation is procedural)
    
    wire [FIFO_width - 1 : 0] dataOut;                      //n-bit output word; First In; n = FIFO_width
    wire empty;
    wire full;                                              //to indicate if reading/writing is safe
                                                            //(if full, then writing not allowed)
                                                            //(if empty, then reading not allowed)
    
    reg readEnable;
    reg writeEnable;                                        //controls to read/write            
    reg [FIFO_width - 1 : 0] dataIn;                        //n-bit input word; Last to be in; n = FIFO_width
    reg enable;                                             //active-high enable
    reg reset;                                              //active-high reset
    reg clk;                                                //clock signal    
    
    //parameter stop_time = 1000;                             //ignore warning; raised since parameter is local
    
    
    FIFO_shift_reg_beh #(
        .FIFO_width(FIFO_width),
        .FIFO_depth(FIFO_depth)
    )
     uut(
        .dataOut(dataOut),                
        .empty(empty), 
        .full(full),                          
        
        .readEnable(readEnable), 
        .writeEnable(writeEnable),                          
        .dataIn(dataIn),                      
        .enable(enable), 
        .reset(reset), 
        .clk(clk)                                
    );
    
    //initial #stop_time $finish;                             //Ends simulation after stop_time, using the $finish system task
    
    always #5 clk = ~clk;                                  //generates a clock with frequency 100MHz
    
    initial
        begin
        
            //initialisation
            clk = 1'b0;
            enable = 1'b1;
            reset = 1'b1;  
            readEnable = 1'b0;
            writeEnable = 1'b0;
            dataIn = {FIFO_width{1'b0}};
        
            #100;                                       //all instantiated primitives get held in their INIT state for the
                                                        //first 100 ns of simulation
            
            //write first value
            reset = 1'b0;  
            readEnable = 1'b0;
            writeEnable = 1'b1;
            dataIn = 'd10;
            
            #10
                        
            //write second value
            readEnable = 1'b0;          //these lines are not required, but are repeated
            writeEnable = 1'b1;         //for better readability of the code
            dataIn = 'd9;
            
            #10
            
            //write third value  
            readEnable = 1'b0;
            writeEnable = 1'b1;
            dataIn = 'd8;
            
            #10
            
            //write fourth value  
            readEnable = 1'b0;
            writeEnable = 1'b1;
            dataIn = 'd7;
            
            //write remaining values as 1
            repeat(FIFO_width - 4) #10 dataIn = 'd1;
            
            //full must be 1 now
            //assert aFull(.clk(clk), .test(full));
            #10;
            
            //FIFO_memory must be full now; 6 will not be written
            dataIn = 'd6;
            
            #10;
            
            
            //Now that we have checked the write and full outputs, let us 
            //finally verify the read and empty operations, along with the
            //FIFO flow of data 
            writeEnable = 1'b0;                           //set to zero, since now we are reading
            dataIn = 'd0;                                 //set to zero, since it won't be used for now
            
            //read all the values, or in other words, read across the entire width of FIFO
            repeat(FIFO_width) #10 readEnable = 1'b1;     //should read values in the order 10, 9, 8, 7, 1, 1, 1, 1, ...., 1
                                                        
                                                          //also, 6 is not reflected while reading, meaning it was not written 
                                                          //in the first place, since the FIFO_memory was already full        
            //empty must be 1 now
            #10;
            
            //FIFO_memory must be empty now; dataOut would remain the same
            #10;
               
            //Stop reading   
            readEnable = 1'b0;
            #10;
                    
            //Finally, let's test the reset and enable inputs;
            
            //Testing reset
            writeEnable = 1'b1;
            dataIn = 'd11;
            #10;
            writeEnable = 1'b0;
            reset = 1'b1;
            #10;
            reset = 1'b0;
            #10;
            readEnable = 1'b1;                      //if reset works, dataOut should not change
            #10;
            
            
            //Testing enable
            readEnable = 1'b0;
            writeEnable = 1'b1;
            dataIn = 'd11;
            #10;
            writeEnable = 1'b0;
            enable = 1'b0;
            #10;
            readEnable = 1'b1;                      //if enable works, dataOut should not change
            #10; 
            readEnable = 1'b0;            
            
            
            //Ending the simulation
            #20
            reset = 1'b1;
            #20
            $finish;
            
        end
endmodule
