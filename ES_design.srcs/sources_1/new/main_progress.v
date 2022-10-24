`timescale 1ns / 1ps
/*
�������ڣ�2022.10.19
�����ߣ�������
ƽ̨��EGO1
˵����������ʵ�ֹ��ܣ�
1��2022.1223����ʾ
2������/��λ�������Ƶ�ʣ�����sin���Σ�����DAC��
3�������ⲿADC��sin����
*/
module main_progress(
    input sys_rst_n, sys_clk_in,
    input [7:0] sw_pin,//��߿�������
    input [7:0] dip_pin,//�ұ߲��뿪������
    input [9:0] AD_D,//���AD����������
    input XADC_AUX_v_p,//��λ�������ѹ
    input XADC_AUX_v_n,
    input [4:0] btn_pin,//5����ť����
    output [7:0] seg_cs_pin,//�����λѡ
    output [7:0] seg_data_0_pin,//����ܶ�ѡ1
    output [7:0] seg_data_1_pin,//����ܶ�ѡ2
    output dac_ile,//����DAC�����ź������ߣ�����Ч
    output dac_cs_n,//����DACƬѡ�ź������ߣ�����Ч
    output dac_wr1_n,//����DACд�ź�1������Ч
    output dac_wr2_n,//����DACд�ź�2������Ч
    output dac_xfer_n,//����DAC���ݴ�������ź������ߣ�����Ч
    output [7:0] dac_data,//����//DAC_0832�������
    output CLK_AD,//���AD��ʱ��
    output CLK_DA,//���DA��ʱ��
    output [13:0] DA_D,//���DA���������
    output [15:0] led_pin//LED
);


wire clk_10m,clk_10k;//�������Է�Ƶ��ģ��ķ�Ƶ�ź�

reg [7:0] sw_pin_trans;//��߿������룬ת�á�ת�ú�7������ߣ�0�����ұ�
reg [31:0] set_freq;//�������������õ�Ƶ��ֵ
reg [63:0] set_freq_64;
reg [31:0] set_period;//�������õ�Ƶ��ֵ������õ���Ŀ�������ں��ж��ٸ�ϵͳʱ�ӣ�100MHz��������
wire [63:0] display_freq_num;//���뿪�����õ�Ŀ��Ƶ��ֵ��ʾ��������ϵĶ��źţ�8*8��С��
wire [63:0] set_freq_num;
reg [63:0] display_choose;//Ҫ���������ܵĶ��źţ�8*8��С�����ɱ�

wire dout_tvalid0;//��0��������������ɵ��źţ�1ʱΪ������ɣ�δʹ�õ�
wire dout_tvalid1;//��1��������������ɵ��źţ�1ʱΪ������ɣ�δʹ�õ�
wire [63:0] dout_tdata0;//��0������������������32λ���̣���32λ������
wire [63:0] dout_tdata1;//��1������������������32λ���̣���32λ������

wire [31:0] meas_period;//�����������ں��ж��ٸ�ϵͳʱ�ӣ�100MHz�����ڣ�������AD��������Ҳ��õ�
reg [31:0] meas_freq;//������Ƶ�ʣ�Ҳ��AD��������Ҳ���Ƶ��
wire [63:0] meas_freq_num;//������Ƶ�ʣ�Ҳ��AD��������Ҳ���Ƶ�ʣ���ʾ��������ϵĶ��źţ�8*8��С��
wire [63:0] meas_period_num;


wire [4:0] channel_out;//XADC��
wire eoc_out;//XADC��
wire [15:0] xdac_out_16;//XADC���������12λ[15:4]

wire [4:0] btn_push_num;//���·�ת

assign CLK_AD = clk_10m;//ADʱ��
assign CLK_DA = clk_10m;
//assign led_pin[15:4] = xdac_out_16[15:4];
assign led_pin[4:0] = btn_push_num[4:0];
assign led_pin[5] = AD_D[9];

Digit_LED led1 (//��4λ����ܵ�ģ��
    .sys_rst_n(sys_rst_n),
    .clk(clk_10k),//10Kˢ��Ƶ��
    .data_in(display_choose[63:32]),//��ʾ��8��������ϵĶ��źţ�8*8��С���ĸ�λ
    .cs(seg_cs_pin[3:0]),//λѡ
    .data(seg_data_0_pin)//��ѡ
);

Digit_LED led2 (//��4λ����ܵ�ģ��
    .sys_rst_n(sys_rst_n),
    .clk(clk_10k),//10Kˢ��Ƶ��
    .data_in(display_choose[31:0]),//��ʾ��8��������ϵĶ��źţ�8*8��С���ĵ�λ
    .cs(seg_cs_pin[7:4]),//λѡ
    .data(seg_data_1_pin)//��ѡ
);

freq_div freq_div(//��Ƶ��ģ��
    .sys_rst_n(sys_rst_n),
    .sys_clk_in(sys_clk_in),
    .clk_10m(clk_10m),//10M����DA
    .clk_10k(clk_10k)//10K���������ˢ��
);

freq_set2display freq_set2display(//Ƶ��ֵת��Ϊ��ʾ��8��������ϵĶ��źţ�8*8��С��
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .set_freq(set_freq),//���õ�Ƶ��ֵ
    .display_freq_num(display_freq_num)

);


div_gen_0 div_gen_0(//��0����������100M / ���õ�Ƶ��ֵ = Ŀ�������ں��ж��ٸ�ϵͳʱ�ӣ�100MHz��������
    .aclk(sys_clk_in),
    .s_axis_divisor_tvalid(1'b1),//��1����
    //.s_axis_divisor_tready(),
    .s_axis_divisor_tdata(set_freq),
    .s_axis_dividend_tvalid(1'b1),//��1����
    //.s_axis_dividend_tready(),
    .s_axis_dividend_tdata(32'd100_000_000),
    .m_axis_dout_tvalid(dout_tvalid0),
    .m_axis_dout_tdata(dout_tdata0)
  );

sin sin0(//ͨ����Ŀ�������ں��ж��ٸ�ϵͳʱ�ӣ�100MHz�������ڡ�����10M��Ƶ��ˢ��DA��Dֵ
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .set_period(set_period),
    .dac_ile(dac_ile),//����DAC
    .dac_cs_n(dac_cs_n),//����DAC
    .dac_wr1_n(dac_wr1_n),//����DAC
    .dac_wr2_n(dac_wr2_n),//����DAC
    .dac_xfer_n(dac_xfer_n),//����DAC
    //.dac_data(dac_data),//����DAC
    .dac_data(DA_D[13:6])//���DAC
);

measure measure0(//Ƶ�ʲ���ģ��
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .AD_D(AD_D),//����AD����ֵ
    .meas_high_flash(btn_push_num[4]),//�ߵ�ˢ����
    .meas_period(meas_period)//����������ź�һ���������ж��ٸ�ʱ�ӣ�100MHz��������
);

div_gen_0 div_gen_1(//��1����������100MHz / ���������ź�һ���������ж��ٸ�ϵͳʱ�ӣ�100MHz�������ڡ� = �������źŵ�Ƶ��
    .aclk(sys_clk_in),
    .s_axis_divisor_tvalid(1'b1),
    //.s_axis_divisor_tready(),
    .s_axis_divisor_tdata(meas_period),//����
    .s_axis_dividend_tvalid(1'b1),
    //.s_axis_dividend_tready(),
    .s_axis_dividend_tdata(32'd100_000_000_0),//������
    .m_axis_dout_tvalid(dout_tvalid1),
    .m_axis_dout_tdata(dout_tdata1)
  );

freq_set2display freq_set2display1(//�������ź�Ƶ��ֵת��Ϊ��ʾ��8��������ϵĶ��źţ�8*8��С��
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .set_freq(meas_freq),
    .display_freq_num(meas_freq_num)

);

btn btn(
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .btn_pin(btn_pin),//5����ť����
    .btn_push_num(btn_push_num)//����֮��ᷭת
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

freq_set2display freq_set2display_meas_period(//�������ź�����ת��Ϊ��ʾ��8��������ϵĶ��źţ�8*8��С��
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .set_freq(meas_period),
    .display_freq_num(meas_period_num)

);

freq_set2display freq_set2display_set_period(//Ŀ���ź�����ת��Ϊ��ʾ��8��������ϵĶ��źţ�8*8��С��
    .sys_rst_n(sys_rst_n),
    .clk(sys_clk_in),
    .set_freq(set_period),
    .display_freq_num(set_period_num)

);

always @(posedge sys_clk_in or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        set_freq <= 0;
        //display_freq_num = 64'b00111111_00111111_00111111_00111111_00111111_00111111_00111111_00111111;
        //DA_D[5:0] <= 6'b000000;//���DAC�ĺ�6λδʹ�ã���ʼ��Ϊ0
    end
    else begin
        sw_pin_trans={sw_pin[0],sw_pin[1],sw_pin[2],sw_pin[3],sw_pin[4],sw_pin[5],sw_pin[6],sw_pin[7]};

        if(btn_push_num[0] == 0)begin
            set_freq = (sw_pin_trans * 32'd10_000_000) >> 8;//�ɿ��ص�ֵ�õ�Ŀ��Ƶ�ʣ������ǳ����˷�����һ���������������
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

        set_period = dout_tdata0[63:32];//�����������ǰ32λ����
        meas_freq <= dout_tdata1[63:32];

        if(btn_push_num[3] == 1)begin//��ߵİ�ť
            display_choose <= 64'b01011011_00111111_01011011_11011011_00000110_01011011_01011011_01001111;//2022.ѧ����ʾ
        end
        else begin
            if(btn_push_num[2] == 1)begin
                if(btn_push_num[1] == 0)begin
                    display_choose <= meas_freq_num;//��ʾ�����źŵ�Ƶ��
                end
                else display_choose <= meas_period_num;//��ʾ�����źŵ�����
            end
            else begin
                if(btn_push_num[1] == 0)begin
                    display_choose <= display_freq_num;//��ʾ�趨�źŵ�Ƶ��
                end
                else display_choose <= set_period_num;
            end
        end





    end
end

endmodule
