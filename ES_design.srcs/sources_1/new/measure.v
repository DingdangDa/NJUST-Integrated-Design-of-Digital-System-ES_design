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
    reg [0:0] AD_D_9_last ;//上一个系统时钟周期的AD_D[9]的值
    reg [31:0] AD_D_9_period;//AD_D[9]变化的半周期
    reg [31:0] sq_wave_period;//测量出来的频率（高刷新率）
    reg [31:0] cnt_flash;//低刷新率数数
    reg [31:0] cnt_to_half_sec;//会数到半秒的数


    always @(posedge clk or negedge sys_rst_n)begin//
        if(!sys_rst_n) begin
            AD_D_9_last <= 0;
            cnt_sq_wave <= 0;
            AD_D_9_period <= 0;
        end
        else begin
            AD_D_9_last <= AD_D[9];
            cnt_sq_wave <= cnt_sq_wave + 1;
            cnt_to_half_sec <= cnt_to_half_sec + 1;

            if (AD_D[9] != AD_D_9_last)begin
                AD_D_9_period <= AD_D_9_period + 1;
                /*
                if(AD_D_9_period == 16'd19)begin
                    sq_wave_period <= cnt_sq_wave + 1;
                    cnt_sq_wave <= 0;
                    AD_D_9_period <= 0;
                end
                */
                //上面被注释掉的代码块测量10个AD周期内有多少个时钟周期
            end
            //下面代码测量半秒内有多少个半周期，就是频率了，懒得改返回值的名称
            if (cnt_to_half_sec == 32'd50_000_000)begin
                cnt_to_half_sec <= 0;
                //cnt_sq_wave <= 0;
                AD_D_9_period <= 0;
                sq_wave_period <= AD_D_9_period + 1;
            end
            else cnt_to_half_sec <= cnt_to_half_sec + 1;
            
            


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
