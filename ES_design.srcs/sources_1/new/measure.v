`timescale 1ns / 1ps
/*
创建日期：2022.10.19
开发者：黄炫宇
平台：EGO1
说明：频率测量，外部ADC输入
*/
module measure(
    input sys_rst_n, clk,
    input [9:0] AD_D,//AD的输入
    input [0:0] meas_high_flash,//高低刷新率
    output reg [31:0] meas_period//输出方波的周期，也是被测波的周期
    );

    reg [0:0] AD_D_9_last ;//上一个系统时钟周期的AD_D[9]的值
    reg [31:0] AD_D_9_period;//AD_D[9]变化的半周期
    reg [31:0] cnt_to_half_sec;//会数到半秒的数


    always @(posedge clk or negedge sys_rst_n)begin//
        if(!sys_rst_n) begin
            AD_D_9_last <= 0;
            AD_D_9_period <= 0;
            cnt_to_half_sec <= 0;
        end
        else begin
            AD_D_9_last <= AD_D[9];
            cnt_to_half_sec <= cnt_to_half_sec + 1;

            if (AD_D[9] != AD_D_9_last)begin
                AD_D_9_period <= AD_D_9_period + 1;
            end

            if (cnt_to_half_sec == 32'd50_000_000)begin//测量半秒内有多少个半周期，就是频率了
                cnt_to_half_sec <= 0;
                AD_D_9_period <= 1;
                meas_period <= AD_D_9_period;
            end
            else cnt_to_half_sec <= cnt_to_half_sec + 1;

        end
    end

endmodule
