`timescale 1ns / 1ps
/*
创建日期：2022.10.19
开发者：黄炫宇
平台：EGO1
说明：这是数码管的程序
*/
module Digit_LED (
    input sys_rst_n, clk, // 10k
    input [31:0] data_in,//显示在4个数码管上的段信号，8个数码管的前4或后4
    output reg [3:0] cs,//位选
    output reg [7:0] data//段选
);

reg [1:0] cnt;

always @(posedge clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        cnt <= 2'b0;
        cs <= 4'b1;
        data <= 8'b0;
    end
    else begin
        if(!cs) cs <= 4'b0001;//cs全为0时咋移都是0，所以赋1
        else if(cs == 4'b1000)//1跑到最左边
            cs <= 4'b0001;
        else cs <= cs << 1'b1;
        case(cnt)//这里不是按顺序排列的我也没办法，它板子就那样
            2'b10: data <= data_in[7:0];
            2'b01: data <= data_in[15:8];
            2'b00: data <= data_in[23:16];
            2'b11: data <= data_in[31:24];
        endcase
        cnt <= cnt + 1'b1;//cnt无归零操作，通过2位的自然溢出实现周期4的循环
    end
end

endmodule
