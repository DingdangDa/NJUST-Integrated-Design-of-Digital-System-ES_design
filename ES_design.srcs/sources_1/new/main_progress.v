`timescale 1ns / 1ps
/*
创建日期：2022.10.19
开发者：黄炫宇
平台：EGO1
说明：主程序，实现功能：
1、2022.1223的显示
2、开关/电位器输入的频率，产生sin波形（外置DAC）
3、测量外部ADC的sin周期
*/
module main_progress(
    input sys_rst_n, sys_clk_in,
    input [7:0] sw_pin,//左边开关输入
    input [7:0] dip_pin,//右边拨码开关输入
    input [9:0] AD_D,//外接AD，数据输入
    input XADC_AUX_v_p,//电位器输入电压
    input XADC_AUX_v_n,
    input [4:0] btn_pin,//5个按钮输入
    output [7:0] seg_cs_pin,//数码管位选
    output [7:0] seg_data_0_pin,//数码管段选1
    output [7:0] seg_data_1_pin,//数码管段选2
    output dac_ile,//板载DAC允许信号输入线，高有效
    output dac_cs_n,//板载DAC片选信号输入线，低有效
    output dac_wr1_n,//板载DAC写信号1，低有效
    output dac_wr2_n,//板载DAC写信号2，低有效
    output dac_xfer_n,//板载DAC数据传输控制信号输入线，低有效
    output [7:0] dac_data,//板载//DAC_0832数据输出
    output CLK_AD,//外接AD的时钟
    output CLK_DA,//外接DA的时钟
    output [13:0] DA_D,//外接DA，数据输出
    output [15:0] led_pin//LED
);


wire clk_10m,clk_10k;//接收来自分频器模块的分频信号

reg [7:0] sw_pin_trans;//左边开关输入，转置。转置后7是最左边，0是最右边
reg [31:0] set_freq;//这是我们所设置的频率值
reg [63:0] set_freq_64;
reg [31:0] set_period;//根据设置的频率值，计算得到的目标周期内含有多少个系统时钟（100MHz）的周期
wire [63:0] display_freq_num;//拨码开关设置的目标频率值显示在数码管上的段信号（8*8大小）
wire [63:0] set_freq_num;
reg [63:0] display_choose;//要输出给数码管的段信号（8*8大小），可变

wire dout_tvalid0;//第0个除法器计算完成的信号，1时为计算完成，未使用到
wire dout_tvalid1;//第1个除法器计算完成的信号，1时为计算完成，未使用到
wire [63:0] dout_tdata0;//第0个除法器计算结果，高32位是商，低32位是余数
wire [63:0] dout_tdata1;//第1个除法器计算结果，高32位是商，低32位是余数

wire [31:0] meas_period;//方波的周期内含有多少个系统时钟（100MHz）周期，方波由AD输入的正弦波得到
reg [31:0] meas_freq;//方波的频率，也是AD输入的正弦波的频率
wire [63:0] meas_freq_num;//方波的频率，也是AD输入的正弦波的频率，显示在数码管上的段信号（8*8大小）
wire [63:0] meas_period_num;


wire [4:0] channel_out;//XADC的
wire eoc_out;//XADC的
wire [15:0] xdac_out_16;//XADC的输出，有12位[15:4]

wire [4:0] btn_push_num;//按下翻转

assign CLK_AD = clk_10m;//AD时钟
assign CLK_DA = clk_10m;
//assign led_pin[15:4] = xdac_out_16[15:4];
assign led_pin[4:0] = btn_push_num[4:0];
assign led_pin[5] = AD_D[9];

Digit_LED led1 (//左4位数码管的模块
    .sys_rst_n(sys_rst_n),
    .clk(clk_10k),//10K刷新频率
    .data_in(display_choose[63:32]),//显示在8个数码管上的段信号（8*8大小）的高位
    .cs(seg_cs_pin[3:0]),//位选
    .data(seg_data_0_pin)//段选
);

Digit_LED led2 (//右4位数码管的模块
    .sys_rst_n(sys_rst_n),
    .clk(clk_10k),//10K刷新频率
    .data_in(display_choose[31:0]),//显示在8个数码管上的段信号（8*8大小）的低位
    .cs(seg_cs_pin[7:4]),//位选
    .data(seg_data_1_pin)//段选
);

freq_div freq_div(//分频器模块
    .sys_rst_n(sys_rst_n),
    .sys_clk_in(sys_clk_in),
    .clk_10m(clk_10m),//10M用于DA
    .clk_10k(clk_10k)//10K用于数码管刷新
);

freq_set2display freq_set2display(//频率值转换为显示在8个数码管上的段信号（8*8大小）
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .set_freq(set_freq),//设置的频率值
    .display_freq_num(display_freq_num)

);


div_gen_0 div_gen_0(//第0个除法器，100M / 设置的频率值 = 目标周期内含有多少个系统时钟（100MHz）的周期
    .aclk(sys_clk_in),
    .s_axis_divisor_tvalid(1'b1),//给1就行
    //.s_axis_divisor_tready(),
    .s_axis_divisor_tdata(set_freq),
    .s_axis_dividend_tvalid(1'b1),//给1就行
    //.s_axis_dividend_tready(),
    .s_axis_dividend_tdata(32'd100_000_000),
    .m_axis_dout_tvalid(dout_tvalid0),
    .m_axis_dout_tdata(dout_tdata0)
  );

sin sin0(//通过“目标周期内含有多少个系统时钟（100MHz）的周期”，以10M的频率刷新DA的D值
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .set_period(set_period),
    .dac_ile(dac_ile),//板载DAC
    .dac_cs_n(dac_cs_n),//板载DAC
    .dac_wr1_n(dac_wr1_n),//板载DAC
    .dac_wr2_n(dac_wr2_n),//板载DAC
    .dac_xfer_n(dac_xfer_n),//板载DAC
    //.dac_data(dac_data),//板载DAC
    .dac_data(DA_D[13:6])//外接DAC
);

measure measure0(//频率测量模块
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .AD_D(AD_D),//输入AD的数值
    .meas_high_flash(btn_push_num[4]),//高低刷新率
    .meas_period(meas_period)//输出被测量信号一个周期内有多少个时钟（100MHz）的周期
);

div_gen_0 div_gen_1(//第1个除法器，100MHz / “被测量信号一个周期内有多少个系统时钟（100MHz）的周期” = 被测量信号的频率
    .aclk(sys_clk_in),
    .s_axis_divisor_tvalid(1'b1),
    //.s_axis_divisor_tready(),
    .s_axis_divisor_tdata(meas_period),//除数
    .s_axis_dividend_tvalid(1'b1),
    //.s_axis_dividend_tready(),
    .s_axis_dividend_tdata(32'd100_000_000_0),//被除数
    .m_axis_dout_tvalid(dout_tvalid1),
    .m_axis_dout_tdata(dout_tdata1)
  );

freq_set2display freq_set2display1(//被测量信号频率值转换为显示在8个数码管上的段信号（8*8大小）
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .set_freq(meas_freq),
    .display_freq_num(meas_freq_num)

);

btn btn(
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .btn_pin(btn_pin),//5个按钮输入
    .btn_push_num(btn_push_num)//按下之后会翻转
);

xadc_wiz_0 xadc_wiz (
  //.di_in(di_in),              // input wire [15 : 0] di_in
  .daddr_in(channel_out),        // input wire [6 : 0] daddr_in
  .den_in(eoc_out),            // input wire den_in
  .dwe_in(1'b0),            // input wire dwe_in
  //.drdy_out(drdy_out),        // output wire drdy_out
  .do_out(xdac_out_16),            // output wire [15 : 0] do_out
  .dclk_in(sys_clk_in),          // input wire dclk_in
  .reset_in(dip_pin[0]),        // input wire reset_in

  .vauxp1(XADC_AUX_v_p),            // note since vauxn5, channel 5, is used  .daddr_in(ADC_ADDRESS), ADC_ADRESS = 15h, i.e., 010101
  .vauxn1(XADC_AUX_v_n),            // note since vauxn5, channel 5, is used  .daddr_in(ADC_ADDRESS), ADC_ADRESS = 15h, i.e., 010101

  .channel_out(channel_out),  // output wire [4 : 0] channel_out
  .eoc_out(eoc_out)       // output wire eoc_out
  //.alarm_out(led[0]),      // output wire alarm_out
  //.eos_out(led[1]),         // output wire eos_out

  //.busy_out(led[2])        // output wire busy_out
);

freq_set2display freq_set2display_meas_period(//被测量信号周期转换为显示在8个数码管上的段信号（8*8大小）
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .set_freq(meas_period),
    .display_freq_num(meas_period_num)

);

freq_set2display freq_set2display_set_period(//目标信号周期转换为显示在8个数码管上的段信号（8*8大小）
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .set_freq(set_period),
    .display_freq_num(set_period_num)

);

always @(posedge sys_clk_in or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        set_freq <= 0;
        //display_freq_num = 64'b00111111_00111111_00111111_00111111_00111111_00111111_00111111_00111111;
        //DA_D[5:0] <= 6'b000000;//外接DAC的后6位未使用，初始化为0
    end
    else begin
        sw_pin_trans={sw_pin[0],sw_pin[1],sw_pin[2],sw_pin[3],sw_pin[4],sw_pin[5],sw_pin[6],sw_pin[7]};

        if(btn_push_num[0] == 0)begin
            set_freq = (sw_pin_trans * 32'd10_000_000) >> 8;//由开关的值得到目标频率，由于是常数乘法，在一个周期内能算出来
        end
        else begin
            if(btn_push_num[4] == 1)begin
                set_freq_64 = (xdac_out_16[15:4] * 32'd10_000_000) >> 12;
                set_freq <= set_freq_64[31:0];
            end
            else begin
                set_freq = (xdac_out_16[15:8] * 32'd10_000_000) >> 8;
            end
        end

        set_period = dout_tdata0[63:32];//除法器结果的前32位是商
        meas_freq <= dout_tdata1[63:32];

        if(btn_push_num[3] == 1)begin//左边的按钮
            display_choose <= 64'b01011011_00111111_01011011_11011011_00000110_01011011_01011011_01001111;//2022.学号显示
        end
        else begin
            if(btn_push_num[2] == 1)begin
                if(btn_push_num[1] == 0)begin
                    display_choose <= meas_freq_num;//显示测量信号的频率
                end
                else display_choose <= meas_period_num;//显示测量信号的周期
            end
            else begin
                if(btn_push_num[1] == 0)begin
                    display_choose <= display_freq_num;//显示设定信号的频率
                end
                else display_choose <= set_period_num;
            end
        end





    end
end

endmodule
