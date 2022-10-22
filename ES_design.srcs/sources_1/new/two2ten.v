`timescale 1ns / 1ps
/*
创建时间：2022.10.20
创建者：黄炫宇
平台：EGO1
说明：
频率值转换为显示在8个数码管上的段信号（8*8大小）
这是一个时序非常头疼的程序。。。。。。
正常思维：
考虑第n个数码管，n从8到0
    频率值减去10的(n-1)次方，能减几次，那个数码管就是几，最多减9次
这个思维下是2个for循环，周期72次，但蛋疼就在于你不能在Verilog写循环
已知某数码管上显示的是几后，需要确定数码管段值，要考虑8个数码管，有周期8的循环。。。但你不能写循环
9次的循环不好看，我们取10，从里往外写80次的循环，通过数数
程序中间有分割线，分割线前是在算数码管显示的数字应该是几，这部分程序决定了80的大周期
分割线后是确定数码管段值，利用80的周期实现循环
*/
module freq_set2display(
    input sys_rst_n, clk,
    input [31:0] set_freq,
    output reg [63:0] display_freq_num//数码管显示的段值
    );

reg [7:0] sw_pin_trans;//左边拨码开关输入的转置
reg [3:0] freq_num [7:0];//数组，每一个数对应一个数码管，表示数码管显示的数字，但被计算完成之后，下一步立马清零，需要用freq_num_nice暂存
reg [3:0] freq_num_nice [7:0];//为了利用数数，而不进行多case
reg [7:0] display_freq_num_make [7:0];//数码管显示的段值的拆分，为了display_freq_num服务
reg [31:0] set_freq_rfi;//set_freq不能是reg，so，set_freq_reg_for_input，中间变量
reg [31:0] dec_power_for_compare = 32'd0;//power means 幂，用于减频率值的减数

reg [3:0] cnt_for_freq_num;//数数值，周期8，二层
reg [3:0] cnt_for_display_freq_num;//数数值，周期10，一层

always @(posedge clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        display_freq_num <= 32'b0;
        set_freq_rfi <= 32'b0;
        dec_power_for_compare <= 32'b1;
        cnt_for_display_freq_num <= 0;
        cnt_for_freq_num <= 7;
    end
    else begin

        if(cnt_for_display_freq_num == 9) begin//一层数数
            cnt_for_display_freq_num <= 0;
        end
        else cnt_for_display_freq_num <= cnt_for_display_freq_num + 1;

        if(cnt_for_display_freq_num == 0)begin//二层数数，顺序：76543210
            if(cnt_for_freq_num == 0) begin//双0周期初始化，理论上只会最开始被执行一次
                cnt_for_freq_num <= 7;
                dec_power_for_compare <= 32'd1;
                set_freq_rfi <= 0;
                freq_num_nice[0] <= 0;freq_num_nice[1] <= 0;freq_num_nice[2] <= 0;freq_num_nice[3] <= 0;
                freq_num_nice[4] <= 0;freq_num_nice[5] <= 0;freq_num_nice[6] <= 0;freq_num_nice[7] <= 0;
            end
            else cnt_for_freq_num <= cnt_for_freq_num - 1;
        end

        case(cnt_for_freq_num)//二层数数值，周期8，用于决定减数
            4'd0: dec_power_for_compare <= 32'd1;
            4'd1: dec_power_for_compare <= 32'd10;
            4'd2: dec_power_for_compare <= 32'd100;
            4'd3: dec_power_for_compare <= 32'd1000;
            4'd4: dec_power_for_compare <= 32'd10000;
            4'd5: dec_power_for_compare <= 32'd100000;
            4'd6: dec_power_for_compare <= 32'd1000000;
            4'd7: dec_power_for_compare <= 32'd10000000;
        endcase

        if(cnt_for_freq_num == 7 && cnt_for_display_freq_num == 1)begin//这是周期80的大周期的第2周期
            set_freq_rfi <= set_freq;//读取设置的频率值
            freq_num[0] <= 0;freq_num[1] <= 0;freq_num[2] <= 0;freq_num[3] <= 0;//初始化
            freq_num[4] <= 0;freq_num[5] <= 0;freq_num[6] <= 0;freq_num[7] <= 0;
            //下面暂存频率值，乍一看好像是在周期开头进行，但其实是时序已经延迟到了下一个周期。。。
            freq_num_nice[0] <= freq_num[0];freq_num_nice[1] <= freq_num[1];freq_num_nice[2] <= freq_num[2];freq_num_nice[3] <= freq_num[3];
            freq_num_nice[4] <= freq_num[4];freq_num_nice[5] <= freq_num[5];freq_num_nice[6] <= freq_num[6];freq_num_nice[7] <= freq_num[7];
        end

        if(set_freq_rfi >= dec_power_for_compare)begin//当频率值大于10的幂，幂值随二层数数值变化
            set_freq_rfi <= set_freq_rfi - dec_power_for_compare;//减，每个一层周期都减，直到当频率值小于10的幂
            freq_num[cnt_for_freq_num] <= freq_num[cnt_for_freq_num] + 1;//第“二层数数值”个二极管应该显示的数字加1
        end
        //---------------------------------分割线-------------------------------------//
        if(cnt_for_freq_num == 3)begin//第4个数码管需要点小数点，段值不一样
            case(freq_num_nice[cnt_for_freq_num])
                4'd0: display_freq_num_make[cnt_for_freq_num] = 8'b10111111;
                4'd1: display_freq_num_make[cnt_for_freq_num] = 8'b10000110;
                4'd2: display_freq_num_make[cnt_for_freq_num] = 8'b11011011;
                4'd3: display_freq_num_make[cnt_for_freq_num] = 8'b11001111;
                4'd4: display_freq_num_make[cnt_for_freq_num] = 8'b11100110;
                4'd5: display_freq_num_make[cnt_for_freq_num] = 8'b11101101;
                4'd6: display_freq_num_make[cnt_for_freq_num] = 8'b11111101;
                4'd7: display_freq_num_make[cnt_for_freq_num] = 8'b10000111;
                4'd8: display_freq_num_make[cnt_for_freq_num] = 8'b11111111;
                4'd9: display_freq_num_make[cnt_for_freq_num] = 8'b11101111;
            endcase
        end
        else begin
            case(freq_num_nice[cnt_for_freq_num])
                4'd0: display_freq_num_make[cnt_for_freq_num] = 8'b00111111;
                4'd1: display_freq_num_make[cnt_for_freq_num] = 8'b00000110;
                4'd2: display_freq_num_make[cnt_for_freq_num] = 8'b01011011;
                4'd3: display_freq_num_make[cnt_for_freq_num] = 8'b01001111;
                4'd4: display_freq_num_make[cnt_for_freq_num] = 8'b01100110;
                4'd5: display_freq_num_make[cnt_for_freq_num] = 8'b01101101;
                4'd6: display_freq_num_make[cnt_for_freq_num] = 8'b01111101;
                4'd7: display_freq_num_make[cnt_for_freq_num] = 8'b00000111;
                4'd8: display_freq_num_make[cnt_for_freq_num] = 8'b01111111;
                4'd9: display_freq_num_make[cnt_for_freq_num] = 8'b01101111;
            endcase
        end

        display_freq_num = {display_freq_num_make[7],
            display_freq_num_make[6],
            display_freq_num_make[5],
            display_freq_num_make[4],
            display_freq_num_make[3],
            display_freq_num_make[2],
            display_freq_num_make[1],
            display_freq_num_make[0]};
    end
end

endmodule
