`timescale 1ns / 1ps
/*
创建日期：2022.10.21
开发者：黄炫宇
平台：EGO1
说明：这是5个按钮的处理程序，按下按钮会使得btn_push_num翻转
我无法像单片机一样使用按钮的上升沿触发延时
延时通过技计数实现，延时10毫秒，用于消抖
*/

module btn(
    input sys_rst_n, clk,
    input [4:0] btn_pin,//5个按键
    output reg [4:0] btn_push_num//按下翻转
    );

    reg [31:0] cnt_btn;
    reg [0:0] dis_shakes;//消抖

    always @(posedge clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            btn_push_num <= 5'b00000;
            dis_shakes <= 1;
        end
        else begin

            if ( (btn_pin[0] == 1 || btn_pin[1] == 1 || btn_pin[2] == 1 || btn_pin[3] == 1 || btn_pin[4] == 1) && dis_shakes == 1) begin
                cnt_btn <= 0;
                dis_shakes <= 0;
            end


            if(cnt_btn == 32'd100_000_0) begin
                if (btn_pin[0] == 1) begin
                    if (btn_push_num[0] == 1)btn_push_num[0] <= 0;
                    else btn_push_num[0] <= 1;
                end
                if (btn_pin[1] == 1) begin
                    if (btn_push_num[1] == 1)btn_push_num[1] <= 0;
                    else btn_push_num[1] <= 1;
                end
                if (btn_pin[2] == 1) begin
                    if (btn_push_num[2] == 1)btn_push_num[2] <= 0;
                    else btn_push_num[2] <= 1;
                end
                if (btn_pin[3] == 1) begin
                    if (btn_push_num[3] == 1)btn_push_num[3] <= 0;
                    else btn_push_num[3] <= 1;
                end
                if (btn_pin[4] == 1) begin
                    if (btn_push_num[4] == 1)btn_push_num[4] <= 0;
                    else btn_push_num[4] <= 1;
                end
                dis_shakes <= 1;
            end
            else cnt_btn <= cnt_btn + 1'b1;
        end
    end

    /*
    always @(posedge btn_pin[0] or posedge btn_pin[1] or posedge btn_pin[2] or posedge btn_pin[3] or posedge btn_pin[4]) begin
        cnt_btn <= 0;
    end
    */

endmodule
