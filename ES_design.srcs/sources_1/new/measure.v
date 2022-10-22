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
    output reg [31:0] sq_wave_period//输出方波的周期，也是被测波的周期
    );

    reg [9:0] AD_read;//暂时储存AD值的数，应该会被综合成触发器
    reg [0:0] sq_wave_for_meas;//方波，基于被测波生成
    reg [31:0] cnt_sq_wave;//由系统时钟驱动数数，方波上升沿清零


    always @(negedge clk or negedge sys_rst_n)begin//触发器在下降沿采样AD，理论上外置AD在上升沿处理，给予外置AD一定的时间
        if(!sys_rst_n) begin
            AD_read <= 10'b0;

        end
        else begin
            AD_read <= AD_D;
        end
    end

    always @(posedge clk or negedge sys_rst_n)begin//上升沿采样触发器
        if(!sys_rst_n) begin
            sq_wave_for_meas <= 0;//方波复位
            cnt_sq_wave <= 0;
            sq_wave_period <= 0;
        end
        else begin
            if (AD_read[9] == 1)begin//方波产生
                sq_wave_for_meas <= 1;
            end
            else begin
                sq_wave_for_meas <= 0;
            end
            cnt_sq_wave = cnt_sq_wave + 1;//每个系统时钟周期数数
        end
    end

    always @(posedge sq_wave_for_meas or negedge sys_rst_n)begin//计数方波
        if(!sys_rst_n) begin
            cnt_sq_wave <= 0;
            sq_wave_period <= 0;
        end
        else begin
            sq_wave_period <= cnt_sq_wave;//保存一个方波周期内有几个系统时钟周期
            cnt_sq_wave <= 0;//清零计数器

        end
    end

endmodule
