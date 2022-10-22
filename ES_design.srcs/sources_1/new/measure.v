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
    output reg [31:0] sq_wave_period//������������ڣ�Ҳ�Ǳ��Ⲩ������
    );

    reg [9:0] AD_read;//��ʱ����ADֵ������Ӧ�ûᱻ�ۺϳɴ�����
    reg [0:0] sq_wave_for_meas;//���������ڱ��Ⲩ����
    reg [31:0] cnt_sq_wave;//��ϵͳʱ��������������������������


    always @(negedge clk or negedge sys_rst_n)begin//���������½��ز���AD������������AD�������ش�����������ADһ����ʱ��
        if(!sys_rst_n) begin
            AD_read <= 10'b0;

        end
        else begin
            AD_read <= AD_D;
        end
    end

    always @(posedge clk or negedge sys_rst_n)begin//�����ز���������
        if(!sys_rst_n) begin
            sq_wave_for_meas <= 0;//������λ
            cnt_sq_wave <= 0;
            sq_wave_period <= 0;
        end
        else begin
            if (AD_read[9] == 1)begin//��������
                sq_wave_for_meas <= 1;
            end
            else begin
                sq_wave_for_meas <= 0;
            end
            cnt_sq_wave = cnt_sq_wave + 1;//ÿ��ϵͳʱ����������
        end
    end

    always @(posedge sq_wave_for_meas or negedge sys_rst_n)begin//��������
        if(!sys_rst_n) begin
            cnt_sq_wave <= 0;
            sq_wave_period <= 0;
        end
        else begin
            sq_wave_period <= cnt_sq_wave;//����һ�������������м���ϵͳʱ������
            cnt_sq_wave <= 0;//���������

        end
    end

endmodule
