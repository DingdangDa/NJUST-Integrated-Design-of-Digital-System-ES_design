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

    reg [9:0] AD_read;//��ʱ����ADֵ������Ӧ�ûᱻ�ۺϳɴ�����
    reg [0:0] sq_wave_for_meas;//���������ڱ��Ⲩ����
    reg [31:0] cnt_sq_wave;//��ϵͳʱ��������������������������
    reg [0:0] AD_D_9_last ;
    reg [0:0] AD_D_9_period;
    reg [63:0] sq_wave_period;//����������Ƶ�ʣ���ˢ���ʣ�
    reg [31:0] cnt_flash;//��ˢ��������
    reg [0:0] cnt_sq_wave_set_0_enable;
    reg [63:0] sq_wave_period_last10 [9:0];

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
                if(AD_D_9_period == 1)begin
                    sq_wave_period <= cnt_sq_wave + 1;
                    cnt_sq_wave <= 0;
                    sq_wave_period_last10[0] <= sq_wave_period;
                    sq_wave_period_last10[1] <= sq_wave_period_last10[0];
                    sq_wave_period_last10[2] <= sq_wave_period_last10[1];
                    sq_wave_period_last10[3] <= sq_wave_period_last10[2];
                    sq_wave_period_last10[4] <= sq_wave_period_last10[3];
                    sq_wave_period_last10[5] <= sq_wave_period_last10[4];
                    sq_wave_period_last10[6] <= sq_wave_period_last10[5];
                    sq_wave_period_last10[7] <= sq_wave_period_last10[6];
                    sq_wave_period_last10[8] <= sq_wave_period_last10[7];
                    sq_wave_period_last10[9] <= sq_wave_period_last10[8];
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
            if(cnt_flash == 32'd50_000_000)begin//��ˢ��������
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
