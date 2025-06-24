wvConvertFile -win $_nWave1 -o \
           "/home/trucngu/NCKU-SPI-Project-Rewrite/clkgen.vcd.fsdb" \
           "clkgen.vcd"
wvSetPosition -win $_nWave1 {("G1" 0)}
wvResizeWindow -win $_nWave1 0 23 1463 843
wvOpenFile -win $_nWave1 {/home/trucngu/NCKU-SPI-Project-Rewrite/clkgen.vcd.fsdb}
wvSetPosition -win $_nWave1 {("G1" 0)}
nMemSetPreference
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/clkgen_tb"
wvSetPosition -win $_nWave1 {("G1" 10)}
wvSetPosition -win $_nWave1 {("G1" 10)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/clkgen_tb/CPHA} \
{/clkgen_tb/CPOL} \
{/clkgen_tb/CS} \
{/clkgen_tb/TIP} \
{/clkgen_tb/shift} \
{/clkgen_tb/sys_clk} \
{/clkgen_tb/clk_out} \
{/clkgen_tb/divider\[7:0\]} \
{/clkgen_tb/rst} \
{/clkgen_tb/sample} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 )} 
wvSetPosition -win $_nWave1 {("G1" 10)}
wvSetPosition -win $_nWave1 {("G1" 10)}
wvSetPosition -win $_nWave1 {("G1" 10)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/clkgen_tb/CPHA} \
{/clkgen_tb/CPOL} \
{/clkgen_tb/CS} \
{/clkgen_tb/TIP} \
{/clkgen_tb/shift} \
{/clkgen_tb/sys_clk} \
{/clkgen_tb/clk_out} \
{/clkgen_tb/divider\[7:0\]} \
{/clkgen_tb/rst} \
{/clkgen_tb/sample} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 )} 
wvSetPosition -win $_nWave1 {("G1" 10)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 7 )} 
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSelectSignal -win $_nWave1 {( "G1" 6 7 )} 
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSetPosition -win $_nWave1 {("G1" 7)}
wvSetPosition -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G1" 9)}
wvSetPosition -win $_nWave1 {("G1" 10)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvZoomAll -win $_nWave1
wvSetCursor -win $_nWave1 204.147904 -snap {("G3" 0)}
wvSelectGroup -win $_nWave1 {G3}
wvZoomAll -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 )} {( "G2" 1 2 )} 
wvExit
