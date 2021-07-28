`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2021 15:21:23
// Design Name: 
// Module Name: assert
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


//used to automate the testbench output verification;
//taken from stackexchange
//https://stackoverflow.com/questions/13904794/assert-statement-in-verilog


//NOT USED; not working fine

module assert(input clk, input test);
    always @(posedge clk)
    begin
        if (test !== 1)
        begin
            $display("ASSERTION FAILED in %m");
            $finish;
        end
    end
endmodule
