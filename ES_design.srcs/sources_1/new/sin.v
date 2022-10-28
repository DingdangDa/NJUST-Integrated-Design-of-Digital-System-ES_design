`timescale 1ns / 1ps
/*
�������ڣ�2022.10.21
�����ߣ�������
ƽ̨��EGO1
˵����
����ļ���һ���ؼ�˼�롣����֪Ŀ�����ڵ�����£�����ÿ10�����ڣ�100��10MHz�����ģ���Ӧ�����sin���еĵڼ�������
������cnt_for_sin��cnt_for_sin��set_period�ı�ֵ���������n_in_256��256�ı�ֵ������һ��ӳ�䡣����Ҫ��n_in_256��
�������˼��������n_in_256 = ( cnt_for_sin / set_period ) * 256������set_period��Χ(1,2_000_000)�������޷���֤��10�����������ꡣ
����n_in_256ֻ��256�ֿ����ԣ���ֻ��8λ����/��ȣ�������ʹ��8�ζ��ַ����Եõ�n_in_256��ֵ����֤��10�����������ꡣ
����ļ���һ���ص��ǣ�Ҫ��עʱ��
*/
module sin(
    input sys_rst_n, clk,
    input [31:0] set_period,
    output reg dac_ile,//DAC�����ź������ߣ�����Ч
    output reg dac_cs_n,//DACƬѡ�ź������ߣ�����Ч
    output reg dac_wr1_n,//DACд�ź�1������Ч
    output reg dac_wr2_n,//DACд�ź�2������Ч
    output reg dac_xfer_n,//DAC���ݴ�������ź������ߣ�����Ч
    output reg [7:0] dac_data//DAC�������
    );

reg [7:0] sin_data[255:0];//sin���
reg [31:0] cnt_for_sin;//100Mhz������������set_period��ӳ�䵽256
reg [31:0] cnt_for_sin_10m;//10Mhz������������set_period��ӳ�䵽256
reg [31:0] set_period_cut_for_cpr;//���ַ���������cnt_for_sin_10m�Ƚ�
reg [3:0] cnt_for_sin_out_10m;//�������10MHz������
reg [0:0] n_in_256 [7:0];//��ʾcnt_for_sin_10m����set_period��ӳ�䵽256���λ��
reg [1:0] cpr_finish;//10��100MHzʱ�������������ӳ�䣬�ı�־λ

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
    .s_axis_divisor_tvalid(1'b1),//��1����
    //.s_axis_divisor_tready(),
    .s_axis_divisor_tdata(set_period),
    .s_axis_dividend_tvalid(1'b1),//��1����
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


        if(cnt_for_sin_out_10m == 9) begin//10Mhz��������10��ʱ�����ڣ���������Ϊ����10MHz�����Ƶ��
            cnt_for_sin_out_10m <= 0;
        end
        else cnt_for_sin_out_10m <= cnt_for_sin_out_10m + 1;


        if(cnt_for_sin == set_period - 1) begin//����������������set_period����Ŀ�겨������
            cnt_for_sin <= 0;
            cnt_for_sin_10m <= 0;
            cpr_finish <= 0;//δ���ӳ��
            n_in_256[0]<=0;n_in_256[1]<=0;n_in_256[2]<=0;n_in_256[3]<=0;//��ʼ�������⣬��ֻ��һ������
            n_in_256[4]<=0;n_in_256[5]<=0;n_in_256[6]<=0;n_in_256[7]<=0;
            addra <= 8'b0000_0000;
            cnt_for_sin_out_10m <= 0;
        end
        else cnt_for_sin <= cnt_for_sin + 1;

        if(cnt_for_sin_out_10m == 0)begin//10Mhz��������10��ʱ�����ڣ����ڵĿ�ʼ0
            cnt_for_sin_10m <= cnt_for_sin;//ȡֵ������cnt_for_sin��ÿ��ʱ�����ڶ��仯��̫���ˣ���cnt_for_sin_10m�ݴ棬ˢ����10M
            set_period_cut_for_cpr <= set_period  >> 1;//ϣ�����ֶԱ�ֵ�ڵڶ������ڣ���1ʱ�����趨���ڵ�һ��
            cpr_finish <= 0;//δ���ӳ��
            n_in_256[0]<=0;n_in_256[1]<=0;n_in_256[2]<=0;n_in_256[3]<=0;//��ʼ�������⣬��ֻ��һ������
            n_in_256[4]<=0;n_in_256[5]<=0;n_in_256[6]<=0;n_in_256[7]<=0;
            dac_wr2_n <= 0;//����Ƕ԰���DAC��ĳһ����λ��ת�������ð���DACˢ��һ�����
        end

        if(cnt_for_sin_out_10m > 0 && cnt_for_sin_out_10m <= 8)begin//10Mhz��������10��ʱ�����ڣ����ڵ��м�12345678
            if(cnt_for_sin_10m < set_period_cut_for_cpr && ~cpr_finish)begin//Ŀ��ֵС��
                set_period_cut_for_cpr <= set_period_cut_for_cpr - (set_period >> (1 + cnt_for_sin_out_10m));//���ַ���һ��
                n_in_256[8 - cnt_for_sin_out_10m] <= 0;//n_in_256ĳһλ��0
            end
            else begin
                if(cnt_for_sin_10m > set_period_cut_for_cpr && ~cpr_finish)begin//Ŀ��ֵ����
                    set_period_cut_for_cpr <= set_period_cut_for_cpr + (set_period >> (1 + cnt_for_sin_out_10m));//���ַ���һ��
                    n_in_256[8 - cnt_for_sin_out_10m] <= 1;//n_in_256ĳһλ��1
                end
                else begin
                    if(cnt_for_sin_10m == set_period_cut_for_cpr && ~cpr_finish)begin//Ŀ��ֵһ��
                        cpr_finish <= 1;//���ӳ��
                        n_in_256[8 - cnt_for_sin_out_10m] <= 1;
                    end
                end
            end
        end

        if(cnt_for_sin_out_10m == 9)begin//10Mhz��������10��ʱ�����ڣ����ڵĽ�β9
            cpr_finish <= 1;//���ӳ�䣨Լ���ڣ�?
            //addra <= {n_in_256[7],n_in_256[6],n_in_256[5],n_in_256[4],n_in_256[3],n_in_256[2],n_in_256[1],n_in_256[0]};
            addra <= dout_tdata0[39:32];
            //dac_data <= douta;
            //dac_wr2_n <= 1;//����Ƕ԰���DAC��ĳһ����λ��ת�������ð���DACˢ��һ�����
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
