`timescale 1ns / 1ps
/*
创建日期：2022.10.27
开发者：黄炫宇
平台：EGO1
说明：让xadc以0.5s刷新率返回
*/
module xadc_low_flash(
    input sys_rst_n, clk,
    input [15:0] xdac_out_16,
    output reg [15:0] xdac_low_flash_out_16
    );

    reg [15:0] xdac_out_16_save;
    reg [31:0] cnt_to_half_sec;//会数到半秒的数

    always @(posedge clk or negedge sys_rst_n)begin
        if(!sys_rst_n) begin
            xdac_low_flash_out_16 <= 0;
            xdac_out_16_save <= 0;
        end
        else begin
            xdac_out_16_save <= xdac_out_16;
            if (cnt_to_half_sec == 32'd50_000_000)begin//半秒一次，刷新xdac_low_flash_out_16
                xdac_low_flash_out_16 <= xdac_out_16_save;
            end
            else cnt_to_half_sec <= cnt_to_half_sec + 1;
        end
    end

endmodule
