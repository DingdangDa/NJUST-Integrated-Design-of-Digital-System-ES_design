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

    reg [9:0] AD_read;//暂时储存AD值的数，应该会被综合成触发器
    reg [0:0] sq_wave_for_meas;//方波，基于被测波生成
    reg [31:0] cnt_sq_wave;//由系统时钟驱动数数，方波上升沿清零
    reg [0:0] AD_D_9_last ;
    reg [15:0] AD_D_9_period;
    reg [63:0] sq_wave_period;//测量出来的频率（高刷新率）
    reg [31:0] cnt_flash;//低刷新率数数
    reg [0:0] cnt_sq_wave_set_0_enable;


    always @(posedge clk or negedge sys_rst_n)begin//
        if(!sys_rst_n) begin
            AD_D_9_last <= 0;
            cnt_sq_wave <= 0;
            AD_D_9_period <= 0;
        end
        else begin
            AD_D_9_last <= AD_D[9];
            cnt_sq_wave <= cnt_sq_wave + 1;
            if (AD_D[9] != AD_D_9_last)begin
                AD_D_9_period <= AD_D_9_period + 1;
                //cnt_sq_wave_set_0_enable <= 1;
                if(AD_D_9_period == 16'd19)begin
                    sq_wave_period <= cnt_sq_wave + 1;
                    cnt_sq_wave <= 0;
                    AD_D_9_period <= 0;
                end
            end
            /*
            if (AD_D_9_period == 8'b1111_1111)begin
                if(cnt_sq_wave_set_0_enable == 1)begin
                    cnt_sq_wave <= 0;
                    cnt_sq_wave_set_0_enable <= 0;
                end
                AD_D_9_period <= 0;
                sq_wave_period <= cnt_sq_wave;
            end
            */
            if(cnt_flash == 32'd50_000_000)begin//低刷新率数数
                cnt_flash <= 0;
            end
            else cnt_flash <= cnt_flash +1;

            if(meas_high_flash)begin//High flash
                meas_period <= sq_wave_period ;
            end
            else begin
                if (cnt_flash == 32'd50_000_000)begin
                    meas_period <= sq_wave_period ;
                end
            end

        end
    end


endmodule
