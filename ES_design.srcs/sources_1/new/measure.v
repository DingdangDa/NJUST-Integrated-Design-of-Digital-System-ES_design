`timescale 1ns / 1ps
/*
�������ڣ�2022.10.19
�����ߣ�������
ƽ̨��EGO1
˵����Ƶ�ʲ������ⲿADC����
*/
module measure(
    input sys_rst_n, clk,
    input [9:0] AD_D,//AD������
    input [0:0] meas_high_flash,//�ߵ�ˢ����
    output reg [31:0] meas_period//������������ڣ�Ҳ�Ǳ��Ⲩ������
    );

    reg [0:0] AD_D_9_last ;//��һ��ϵͳʱ�����ڵ�AD_D[9]��ֵ
    reg [31:0] AD_D_9_period;//AD_D[9]�仯�İ�����
    reg [31:0] cnt_to_half_sec;//�������������


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

            if (cnt_to_half_sec == 32'd50_000_000)begin//�����������ж��ٸ������ڣ�����Ƶ����
                cnt_to_half_sec <= 0;
                AD_D_9_period <= 1;
                meas_period <= AD_D_9_period;
            end
            else cnt_to_half_sec <= cnt_to_half_sec + 1;

        end
    end

endmodule
