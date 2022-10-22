`timescale 1ns / 1ps
/*
����ʱ�䣺2022.10.20
�����ߣ�������
ƽ̨��EGO1
˵����
Ƶ��ֵת��Ϊ��ʾ��8��������ϵĶ��źţ�8*8��С��
����һ��ʱ��ǳ�ͷ�۵ĳ��򡣡���������
����˼ά��
���ǵ�n������ܣ�n��8��0
    Ƶ��ֵ��ȥ10��(n-1)�η����ܼ����Σ��Ǹ�����ܾ��Ǽ�������9��
���˼ά����2��forѭ��������72�Σ������۾������㲻����Verilogдѭ��
��֪ĳ���������ʾ���Ǽ�����Ҫȷ������ܶ�ֵ��Ҫ����8������ܣ�������8��ѭ�����������㲻��дѭ��
9�ε�ѭ�����ÿ�������ȡ10����������д80�ε�ѭ����ͨ������
�����м��зָ��ߣ��ָ���ǰ�������������ʾ������Ӧ���Ǽ����ⲿ�ֳ��������80�Ĵ�����
�ָ��ߺ���ȷ������ܶ�ֵ������80������ʵ��ѭ��
*/
module freq_set2display(
    input sys_rst_n, clk,
    input [31:0] set_freq,
    output reg [63:0] display_freq_num//�������ʾ�Ķ�ֵ
    );

reg [7:0] sw_pin_trans;//��߲��뿪�������ת��
reg [3:0] freq_num [7:0];//���飬ÿһ������Ӧһ������ܣ���ʾ�������ʾ�����֣������������֮����һ���������㣬��Ҫ��freq_num_nice�ݴ�
reg [3:0] freq_num_nice [7:0];//Ϊ�������������������ж�case
reg [7:0] display_freq_num_make [7:0];//�������ʾ�Ķ�ֵ�Ĳ�֣�Ϊ��display_freq_num����
reg [31:0] set_freq_rfi;//set_freq������reg��so��set_freq_reg_for_input���м����
reg [31:0] dec_power_for_compare = 32'd0;//power means �ݣ����ڼ�Ƶ��ֵ�ļ���

reg [3:0] cnt_for_freq_num;//����ֵ������8������
reg [3:0] cnt_for_display_freq_num;//����ֵ������10��һ��

always @(posedge clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        display_freq_num <= 32'b0;
        set_freq_rfi <= 32'b0;
        dec_power_for_compare <= 32'b1;
        cnt_for_display_freq_num <= 0;
        cnt_for_freq_num <= 7;
    end
    else begin

        if(cnt_for_display_freq_num == 9) begin//һ������
            cnt_for_display_freq_num <= 0;
        end
        else cnt_for_display_freq_num <= cnt_for_display_freq_num + 1;

        if(cnt_for_display_freq_num == 0)begin//����������˳��76543210
            if(cnt_for_freq_num == 0) begin//˫0���ڳ�ʼ����������ֻ���ʼ��ִ��һ��
                cnt_for_freq_num <= 7;
                dec_power_for_compare <= 32'd1;
                set_freq_rfi <= 0;
                freq_num_nice[0] <= 0;freq_num_nice[1] <= 0;freq_num_nice[2] <= 0;freq_num_nice[3] <= 0;
                freq_num_nice[4] <= 0;freq_num_nice[5] <= 0;freq_num_nice[6] <= 0;freq_num_nice[7] <= 0;
            end
            else cnt_for_freq_num <= cnt_for_freq_num - 1;
        end

        case(cnt_for_freq_num)//��������ֵ������8�����ھ�������
            4'd0: dec_power_for_compare <= 32'd1;
            4'd1: dec_power_for_compare <= 32'd10;
            4'd2: dec_power_for_compare <= 32'd100;
            4'd3: dec_power_for_compare <= 32'd1000;
            4'd4: dec_power_for_compare <= 32'd10000;
            4'd5: dec_power_for_compare <= 32'd100000;
            4'd6: dec_power_for_compare <= 32'd1000000;
            4'd7: dec_power_for_compare <= 32'd10000000;
        endcase

        if(cnt_for_freq_num == 7 && cnt_for_display_freq_num == 1)begin//��������80�Ĵ����ڵĵ�2����
            set_freq_rfi <= set_freq;//��ȡ���õ�Ƶ��ֵ
            freq_num[0] <= 0;freq_num[1] <= 0;freq_num[2] <= 0;freq_num[3] <= 0;//��ʼ��
            freq_num[4] <= 0;freq_num[5] <= 0;freq_num[6] <= 0;freq_num[7] <= 0;
            //�����ݴ�Ƶ��ֵ��էһ�������������ڿ�ͷ���У�����ʵ��ʱ���Ѿ��ӳٵ�����һ�����ڡ�����
            freq_num_nice[0] <= freq_num[0];freq_num_nice[1] <= freq_num[1];freq_num_nice[2] <= freq_num[2];freq_num_nice[3] <= freq_num[3];
            freq_num_nice[4] <= freq_num[4];freq_num_nice[5] <= freq_num[5];freq_num_nice[6] <= freq_num[6];freq_num_nice[7] <= freq_num[7];
        end

        if(set_freq_rfi >= dec_power_for_compare)begin//��Ƶ��ֵ����10���ݣ���ֵ���������ֵ�仯
            set_freq_rfi <= set_freq_rfi - dec_power_for_compare;//����ÿ��һ�����ڶ�����ֱ����Ƶ��ֵС��10����
            freq_num[cnt_for_freq_num] <= freq_num[cnt_for_freq_num] + 1;//�ڡ���������ֵ����������Ӧ����ʾ�����ּ�1
        end
        //---------------------------------�ָ���-------------------------------------//
        if(cnt_for_freq_num == 3)begin//��4���������Ҫ��С���㣬��ֵ��һ��
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
