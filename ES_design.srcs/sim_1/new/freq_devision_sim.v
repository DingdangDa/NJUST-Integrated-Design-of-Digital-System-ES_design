`timescale 1ns / 1ps
module fp_sim;

reg sys_rst_n;
reg sys_clk_in;
reg [7:0] sw_pin;
reg [7:0] dip_pin;
wire [7:0] seg_cs_pin;
wire [7:0] seg_data_0_pin;
wire [7:0] seg_data_1_pin;
wire [9:0] AD_D;
wire [13:0] DA_D;

main_progress u_main (
    .sys_rst_n(sys_rst_n),
    .sys_clk_in(sys_clk_in),
    .sw_pin(sw_pin),
    .dip_pin(dip_pin),//右边拨码开关输入
    .AD_D(AD_D),//外接AD

    .seg_cs_pin(seg_cs_pin),
    .seg_data_0_pin(seg_data_0_pin),
    .seg_data_1_pin(seg_data_1_pin),
    .dac_ile(),
    .dac_cs_n(),
    .dac_wr1_n(),
    .dac_wr2_n(),
    .dac_xfer_n(),
    .dac_data(),//板载DAC_0832
    .CLK_AD(),//外接AD
    .CLK_DA(),//外接DA
    .DA_D(DA_D)//外接DA
);

initial begin
    sys_clk_in = 1'b0;
    sys_rst_n = 1'b1;
    sw_pin = 8'b10010000;
    dip_pin = 8'b0100_0000;
    #5 sys_rst_n = 1'b0;
    #5 sys_rst_n = 1'b1;
    //AD_D[9:0] = 10'b0;


end

assign AD_D[9:0] = DA_D[13:4];

always #5 sys_clk_in = ~sys_clk_in;
/*
always begin
    #5000 AD_D[9] = 1;
    #5000 AD_D[9] = 0;
end
*/
endmodule
