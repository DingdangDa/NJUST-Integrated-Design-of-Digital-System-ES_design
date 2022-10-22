`timescale 1ns / 1ps
/*
�������ڣ�2022.10.19
�����ߣ�������
ƽ̨��EGO1
˵������������ܵĳ���
*/
module Digit_LED (
    input sys_rst_n, clk, // 10k
    input [31:0] data_in,//��ʾ��4��������ϵĶ��źţ�8������ܵ�ǰ4���4
    output reg [3:0] cs,//λѡ
    output reg [7:0] data//��ѡ
);

reg [1:0] cnt;

always @(posedge clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        cnt <= 2'b0;
        cs <= 4'b1;
        data <= 8'b0;
    end
    else begin
        if(!cs) cs <= 4'b0001;//csȫΪ0ʱզ�ƶ���0�����Ը�1
        else if(cs == 4'b1000)//1�ܵ������
            cs <= 4'b0001;
        else cs <= cs << 1'b1;
        case(cnt)//���ﲻ�ǰ�˳�����е���Ҳû�취�������Ӿ�����
            2'b10: data <= data_in[7:0];
            2'b01: data <= data_in[15:8];
            2'b00: data <= data_in[23:16];
            2'b11: data <= data_in[31:24];
        endcase
        cnt <= cnt + 1'b1;//cnt�޹��������ͨ��2λ����Ȼ���ʵ������4��ѭ��
    end
end

endmodule
