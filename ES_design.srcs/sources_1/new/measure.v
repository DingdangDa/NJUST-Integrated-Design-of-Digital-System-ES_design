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

    reg [0:0] sq_wave;
    reg [0:0] sq_wave_last2;
    reg [0:0] sq_wave_last1;

    reg [0:0] up;

    always @(posedge clk or negedge sys_rst_n)begin//
        if(!sys_rst_n) begin
            AD_D_9_last <= 0;
            AD_D_9_period <= 0;
            cnt_to_half_sec <= 0;
            sq_wave <= 0;
            up <= 0;
        end
        else begin
            AD_D_9_last <= AD_D[9];

            cnt_to_half_sec <= cnt_to_half_sec + 1;
/*
            if (AD_D[9] & (~AD_D_9_last))begin
                AD_D_9_period <= AD_D_9_period + 1;
            end
*/
            if(AD_D[9] != AD_D_9_last)begin
                up <= 1;
            end
            if(AD_D >= 10'b10_0010_0000 && up == 1)begin
                up <= 0;
                AD_D_9_period <= AD_D_9_period + 1;
            end
            
            if (cnt_to_half_sec == 32'd10_000_000)begin//���������ж��ٸ����ڣ�����Ƶ����
                cnt_to_half_sec <= 0;
                AD_D_9_period <= 0;
                meas_period <= AD_D_9_period;
            end
            else cnt_to_half_sec <= cnt_to_half_sec + 1;
/*
            if({AD_D[9],AD_D[8],AD_D[7]} >= 3'b101) sq_wave <= 1'b1;
            if({AD_D[9],AD_D[8],AD_D[7]} <= 3'b010) sq_wave <= 1'b0;
            sq_wave_last1 <= sq_wave;
            sq_wave_last2 <= sq_wave_last1;
            if((~sq_wave_last2) & sq_wave_last1)begin
                AD_D_9_period <= AD_D_9_period + 1;
            end
            */
        end
    end

endmodule
