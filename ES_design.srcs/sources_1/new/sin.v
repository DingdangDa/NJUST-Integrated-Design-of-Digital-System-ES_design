`timescale 1ns / 1ps
/*
创建日期：2022.10.21
开发者：黄炫宇
平台：EGO1
说明：
这个文件有一个关键思想。在已知目标周期的情况下，计算每10个周期（100和10MHz决定的），应该输出sin表中的第几个数？
我们有cnt_for_sin，cnt_for_sin与set_period的比值，会相等于n_in_256与256的比值。即做一个映射。我们要求n_in_256。
如果单纯思考除法，n_in_256 = ( cnt_for_sin / set_period ) * 256，其中set_period范围(1,2_000_000)，除法无法保证在10个周期内算完。
由于n_in_256只有256种可能性，即只有8位精度/深度，理论上使用8次二分法可以得到n_in_256的值，保证在10个周期内算完。
这个文件另一个重点是，要关注时序。
*/
module sin(
    input sys_rst_n, clk,
    input [31:0] set_period,
    output reg dac_ile,//DAC允许信号输入线，高有效
    output reg dac_cs_n,//DAC片选信号输入线，低有效
    output reg dac_wr1_n,//DAC写信号1，低有效
    output reg dac_wr2_n,//DAC写信号2，低有效
    output reg dac_xfer_n,//DAC数据传输控制信号输入线，低有效
    output reg [7:0] dac_data//DAC数据输出
    );

reg [7:0] sin_data[255:0];//sin表格
reg [31:0] cnt_for_sin;//100Mhz的数数，除以set_period后映射到256
reg [31:0] cnt_for_sin_10m;//10Mhz的数数，除以set_period后映射到256
reg [31:0] set_period_cut_for_cpr;//二分法的数，与cnt_for_sin_10m比较
reg [3:0] cnt_for_sin_out_10m;//用于输出10MHz的数数
reg [0:0] n_in_256 [7:0];//表示cnt_for_sin_10m除以set_period后映射到256后的位置
reg [1:0] cpr_finish;//10个100MHz时钟周期内完成了映射，的标志位

reg [7:0] addra;
wire [7:0] douta;

wire [63:0] dout_tdata0;

reg [31:0] set_period_last;

blk_sin rom_sin (
  .clka(clk),    // input wire clka
  .wea(),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [7 : 0] addra
  .dina(),    // input wire [7 : 0] dina
  .douta(douta)  // output wire [7 : 0] douta
);

div_gen_0 div_gen_3(//
    .aclk(clk),
    .s_axis_divisor_tvalid(1'b1),//给1就行
    //.s_axis_divisor_tready(),
    .s_axis_divisor_tdata(set_period),
    .s_axis_dividend_tvalid(1'b1),//给1就行
    //.s_axis_dividend_tready(),
    .s_axis_dividend_tdata(cnt_for_sin_10m * 256),
    .m_axis_dout_tvalid(),
    .m_axis_dout_tdata(dout_tdata0)
);


always @(posedge clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        cnt_for_sin <= 0;
        cnt_for_sin_10m <= 0;
        cnt_for_sin_out_10m <= 0;
        cpr_finish <= 0;
        dac_ile <= 1;
        dac_cs_n <= 0;
        dac_wr1_n <= 0;
        dac_wr2_n <= 0;
        dac_xfer_n <= 0;
    end
    else begin


        if(cnt_for_sin_out_10m == 9) begin//10Mhz的数数，10个时钟周期，该数数是为产生10MHz的输出频率
            cnt_for_sin_out_10m <= 0;
        end
        else cnt_for_sin_out_10m <= cnt_for_sin_out_10m + 1;


        if(cnt_for_sin == set_period - 1) begin//大周期数数，周期set_period，是目标波的周期
            cnt_for_sin <= 0;
            cnt_for_sin_10m <= 0;
            cpr_finish <= 0;//未完成映射
            n_in_256[0]<=0;n_in_256[1]<=0;n_in_256[2]<=0;n_in_256[3]<=0;//初始化这玩意，他只能一个个来
            n_in_256[4]<=0;n_in_256[5]<=0;n_in_256[6]<=0;n_in_256[7]<=0;
            addra <= 8'b0000_0000;
            cnt_for_sin_out_10m <= 0;
        end
        else cnt_for_sin <= cnt_for_sin + 1;

        if(cnt_for_sin_out_10m == 0)begin//10Mhz的数数，10个时钟周期，周期的开始0
            cnt_for_sin_10m <= cnt_for_sin;//取值，由于cnt_for_sin在每个时钟周期都变化，太快了，用cnt_for_sin_10m暂存，刷新率10M
            set_period_cut_for_cpr <= set_period  >> 1;//希望二分对比值在第二个周期，即1时，是设定周期的一半
            cpr_finish <= 0;//未完成映射
            n_in_256[0]<=0;n_in_256[1]<=0;n_in_256[2]<=0;n_in_256[3]<=0;//初始化这玩意，他只能一个个来
            n_in_256[4]<=0;n_in_256[5]<=0;n_in_256[6]<=0;n_in_256[7]<=0;
            dac_wr2_n <= 0;//这个是对板载DAC的某一控制位翻转，可以让板载DAC刷新一下输出
        end

        if(cnt_for_sin_out_10m > 0 && cnt_for_sin_out_10m <= 8)begin//10Mhz的数数，10个时钟周期，周期的中间12345678
            if(cnt_for_sin_10m < set_period_cut_for_cpr && ~cpr_finish)begin//目标值小了
                set_period_cut_for_cpr <= set_period_cut_for_cpr - (set_period >> (1 + cnt_for_sin_out_10m));//锟斤拷锟街凤拷锟斤拷一锟斤拷
                n_in_256[8 - cnt_for_sin_out_10m] <= 0;//n_in_256某一位是0
            end
            else begin
                if(cnt_for_sin_10m > set_period_cut_for_cpr && ~cpr_finish)begin//目标值大了
                    set_period_cut_for_cpr <= set_period_cut_for_cpr + (set_period >> (1 + cnt_for_sin_out_10m));//二分法加一点
                    n_in_256[8 - cnt_for_sin_out_10m] <= 1;//n_in_256某一位是1
                end
                else begin
                    if(cnt_for_sin_10m == set_period_cut_for_cpr && ~cpr_finish)begin//目标值一样
                        cpr_finish <= 1;//完成映射
                        n_in_256[8 - cnt_for_sin_out_10m] <= 1;
                    end
                end
            end
        end

        if(cnt_for_sin_out_10m == 9)begin//10Mhz的数数，10个时钟周期，周期的结尾9
            cpr_finish <= 1;//完成映射（约等于）?
            //addra <= {n_in_256[7],n_in_256[6],n_in_256[5],n_in_256[4],n_in_256[3],n_in_256[2],n_in_256[1],n_in_256[0]};
            addra <= dout_tdata0[39:32];
            //dac_data <= douta;
            //dac_wr2_n <= 1;//这个是对板载DAC的某一控制位翻转，可以让板载DAC刷新一下输出
        end
        dac_data <= douta;
        
        set_period_last <= set_period;
        if(set_period_last != set_period)begin
            cnt_for_sin <= 0;
            cnt_for_sin_10m <= 0;
            cnt_for_sin_out_10m <= 0;
            cpr_finish <= 0;
            dac_ile <= 1;
            dac_cs_n <= 0;
            dac_wr1_n <= 0;
            dac_wr2_n <= 0;
            dac_xfer_n <= 0;
        end
    end
end






endmodule
