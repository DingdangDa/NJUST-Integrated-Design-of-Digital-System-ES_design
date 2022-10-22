`timescale 1ns / 1ps
module fp_sim;

reg sys_rst_n;
reg sys_clk_in;
reg [7:0] sw_pin;
reg [7:0] dip_pin;
wire [7:0] seg_cs_pin;
wire [7:0] seg_data_0_pin;
wire [7:0] seg_data_1_pin;
reg [9:0] AD_D;
reg [7:0] sin_data [255:0];
reg [7:0] i;

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
    .DA_D()//外接DA
);

initial begin
    sys_clk_in = 1'b0;
    sys_rst_n = 1'b1;
    sw_pin = 8'b10010000;
    dip_pin = 8'b0100_0000;
    #5 sys_rst_n = 1'b0;
    #5 sys_rst_n = 1'b1;
    AD_D[1:0] = 2'b00;

sin_data[0] = 128;
sin_data[1] = 131;
sin_data[2] = 134;
sin_data[3] = 137;
sin_data[4] = 140;
sin_data[5] = 143;
sin_data[6] = 146;
sin_data[7] = 149;
sin_data[8] = 152;
sin_data[9] = 155;
sin_data[10] = 158;
sin_data[11] = 161;
sin_data[12] = 164;
sin_data[13] = 167;
sin_data[14] = 170;
sin_data[15] = 173;
sin_data[16] = 176;
sin_data[17] = 179;
sin_data[18] = 182;
sin_data[19] = 185;
sin_data[20] = 187;
sin_data[21] = 190;
sin_data[22] = 193;
sin_data[23] = 195;
sin_data[24] = 198;
sin_data[25] = 201;
sin_data[26] = 203;
sin_data[27] = 206;
sin_data[28] = 208;
sin_data[29] = 210;
sin_data[30] = 213;
sin_data[31] = 215;
sin_data[32] = 217;
sin_data[33] = 219;
sin_data[34] = 222;
sin_data[35] = 224;
sin_data[36] = 226;
sin_data[37] = 228;
sin_data[38] = 230;
sin_data[39] = 231;
sin_data[40] = 233;
sin_data[41] = 235;
sin_data[42] = 236;
sin_data[43] = 238;
sin_data[44] = 240;
sin_data[45] = 241;
sin_data[46] = 242;
sin_data[47] = 244;
sin_data[48] = 245;
sin_data[49] = 246;
sin_data[50] = 247;
sin_data[51] = 248;
sin_data[52] = 249;
sin_data[53] = 250;
sin_data[54] = 251;
sin_data[55] = 251;
sin_data[56] = 252;
sin_data[57] = 253;
sin_data[58] = 253;
sin_data[59] = 254;
sin_data[60] = 254;
sin_data[61] = 254;
sin_data[62] = 254;
sin_data[63] = 254;
sin_data[64] = 255;
sin_data[65] = 254;
sin_data[66] = 254;
sin_data[67] = 254;
sin_data[68] = 254;
sin_data[69] = 254;
sin_data[70] = 253;
sin_data[71] = 253;
sin_data[72] = 252;
sin_data[73] = 251;
sin_data[74] = 251;
sin_data[75] = 250;
sin_data[76] = 249;
sin_data[77] = 248;
sin_data[78] = 247;
sin_data[79] = 246;
sin_data[80] = 245;
sin_data[81] = 244;
sin_data[82] = 242;
sin_data[83] = 241;
sin_data[84] = 240;
sin_data[85] = 238;
sin_data[86] = 236;
sin_data[87] = 235;
sin_data[88] = 233;
sin_data[89] = 231;
sin_data[90] = 230;
sin_data[91] = 228;
sin_data[92] = 226;
sin_data[93] = 224;
sin_data[94] = 222;
sin_data[95] = 219;
sin_data[96] = 217;
sin_data[97] = 215;
sin_data[98] = 213;
sin_data[99] = 210;
sin_data[100] = 208;
sin_data[101] = 206;
sin_data[102] = 203;
sin_data[103] = 201;
sin_data[104] = 198;
sin_data[105] = 195;
sin_data[106] = 193;
sin_data[107] = 190;
sin_data[108] = 187;
sin_data[109] = 185;
sin_data[110] = 182;
sin_data[111] = 179;
sin_data[112] = 176;
sin_data[113] = 173;
sin_data[114] = 170;
sin_data[115] = 167;
sin_data[116] = 164;
sin_data[117] = 161;
sin_data[118] = 158;
sin_data[119] = 155;
sin_data[120] = 152;
sin_data[121] = 149;
sin_data[122] = 146;
sin_data[123] = 143;
sin_data[124] = 140;
sin_data[125] = 137;
sin_data[126] = 134;
sin_data[127] = 131;
sin_data[128] = 128;
sin_data[129] = 125;
sin_data[130] = 122;
sin_data[131] = 119;
sin_data[132] = 116;
sin_data[133] = 113;
sin_data[134] = 110;
sin_data[135] = 107;
sin_data[136] = 104;
sin_data[137] = 101;
sin_data[138] = 98;
sin_data[139] = 95;
sin_data[140] = 92;
sin_data[141] = 89;
sin_data[142] = 86;
sin_data[143] = 83;
sin_data[144] = 80;
sin_data[145] = 77;
sin_data[146] = 74;
sin_data[147] = 71;
sin_data[148] = 69;
sin_data[149] = 66;
sin_data[150] = 63;
sin_data[151] = 61;
sin_data[152] = 58;
sin_data[153] = 55;
sin_data[154] = 53;
sin_data[155] = 50;
sin_data[156] = 48;
sin_data[157] = 46;
sin_data[158] = 43;
sin_data[159] = 41;
sin_data[160] = 39;
sin_data[161] = 37;
sin_data[162] = 34;
sin_data[163] = 32;
sin_data[164] = 30;
sin_data[165] = 28;
sin_data[166] = 26;
sin_data[167] = 25;
sin_data[168] = 23;
sin_data[169] = 21;
sin_data[170] = 20;
sin_data[171] = 18;
sin_data[172] = 16;
sin_data[173] = 15;
sin_data[174] = 14;
sin_data[175] = 12;
sin_data[176] = 11;
sin_data[177] = 10;
sin_data[178] = 9;
sin_data[179] = 8;
sin_data[180] = 7;
sin_data[181] = 6;
sin_data[182] = 5;
sin_data[183] = 5;
sin_data[184] = 4;
sin_data[185] = 3;
sin_data[186] = 3;
sin_data[187] = 2;
sin_data[188] = 2;
sin_data[189] = 2;
sin_data[190] = 2;
sin_data[191] = 2;
sin_data[192] = 1;
sin_data[193] = 2;
sin_data[194] = 2;
sin_data[195] = 2;
sin_data[196] = 2;
sin_data[197] = 2;
sin_data[198] = 3;
sin_data[199] = 3;
sin_data[200] = 4;
sin_data[201] = 5;
sin_data[202] = 5;
sin_data[203] = 6;
sin_data[204] = 7;
sin_data[205] = 8;
sin_data[206] = 9;
sin_data[207] = 10;
sin_data[208] = 11;
sin_data[209] = 12;
sin_data[210] = 14;
sin_data[211] = 15;
sin_data[212] = 16;
sin_data[213] = 18;
sin_data[214] = 20;
sin_data[215] = 21;
sin_data[216] = 23;
sin_data[217] = 25;
sin_data[218] = 26;
sin_data[219] = 28;
sin_data[220] = 30;
sin_data[221] = 32;
sin_data[222] = 34;
sin_data[223] = 37;
sin_data[224] = 39;
sin_data[225] = 41;
sin_data[226] = 43;
sin_data[227] = 46;
sin_data[228] = 48;
sin_data[229] = 50;
sin_data[230] = 53;
sin_data[231] = 55;
sin_data[232] = 58;
sin_data[233] = 61;
sin_data[234] = 63;
sin_data[235] = 66;
sin_data[236] = 69;
sin_data[237] = 71;
sin_data[238] = 74;
sin_data[239] = 77;
sin_data[240] = 80;
sin_data[241] = 83;
sin_data[242] = 86;
sin_data[243] = 89;
sin_data[244] = 92;
sin_data[245] = 95;
sin_data[246] = 98;
sin_data[247] = 101;
sin_data[248] = 104;
sin_data[249] = 107;
sin_data[250] = 110;
sin_data[251] = 113;
sin_data[252] = 116;
sin_data[253] = 119;
sin_data[254] = 122;
sin_data[255] = 125;


end

always #5 sys_clk_in = ~sys_clk_in;

always begin
    for(i=0;i<255;i=i+1)begin
        #5;
        AD_D[9:2] = sin_data[i];
    end
end

endmodule
