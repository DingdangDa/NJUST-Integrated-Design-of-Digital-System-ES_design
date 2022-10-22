`timescale 1ns / 1ps
/*
创建日期：2022.10.19
开发者：黄炫宇
平台：EGO1
说明：分频程序
*/
module freq_div(
    input sys_rst_n, sys_clk_in,
    input [31:0] set_period,
    output reg clk_10m,clk_10k

    );

reg [15:0] cnt_10k;
reg [3:0] cnt_10m;



always @(posedge sys_clk_in or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        clk_10m <= 1'b0;
        cnt_10m <= 16'b0;
    end
    else begin
        if(cnt_10m == 4'd4) begin
            cnt_10m <= 4'b0;
            clk_10m <= ~clk_10m;
        end
        else cnt_10m <= cnt_10m + 1'b1;
    end
end

always @(posedge sys_clk_in or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        clk_10k <= 1'b0;
        cnt_10k <= 16'b0;
    end
    else begin
        if(cnt_10k == 16'd4999) begin
            cnt_10k <= 16'b0;
            clk_10k <= ~clk_10k;
        end
        else cnt_10k <= cnt_10k + 1'b1;
    end
end




endmodule
