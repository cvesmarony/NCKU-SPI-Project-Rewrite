wvConvertFile -win $_nWave1 -o \
           "/home/trucngu/NCKU-SPI-Project-Rewrite/wave.vcd.fsdb" "wave.vcd"
wvSetPosition -win $_nWave1 {("G1" 0)}
wvResizeWindow -win $_nWave1 54 237 960 332
wvOpenFile -win $_nWave1 {/home/trucngu/NCKU-SPI-Project-Rewrite/wave.vcd.fsdb}
wvSetPosition -win $_nWave1 {("G1" 0)}
nMemSetPreference
wvResizeWindow -win $_nWave1 0 23 1463 843
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/clkgen_tb"
wvSetPosition -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G1" 8)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/clkgen_tb/CPOL} \
{/clkgen_tb/CS} \
{/clkgen_tb/GO} \
{/clkgen_tb/divider\[7:0\]} \
{/clkgen_tb/rst} \
{/clkgen_tb/TIP} \
{/clkgen_tb/clk} \
{/clkgen_tb/clk_out} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 )} 
wvSetPosition -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G1" 8)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/clkgen_tb/CPOL} \
{/clkgen_tb/CS} \
{/clkgen_tb/GO} \
{/clkgen_tb/divider\[7:0\]} \
{/clkgen_tb/rst} \
{/clkgen_tb/TIP} \
{/clkgen_tb/clk} \
{/clkgen_tb/clk_out} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 )} 
wvSetPosition -win $_nWave1 {("G1" 8)}
wvGetSignalClose -win $_nWave1
wvResizeWindow -win $_nWave1 0 23 1463 843
wvResizeWindow -win $_nWave1 0 23 1463 843
wvResizeWindow -win $_nWave1 0 23 1463 843
wvZoomAll -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 7 8 )} 
wvSelectSignal -win $_nWave1 {( "G1" 6 7 8 )} 
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSetPosition -win $_nWave1 {("G1" 7)}
wvSetPosition -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetCursor -win $_nWave1 73.333649 -snap {("G3" 0)}
wvSelectGroup -win $_nWave1 {G3}
wvSelectGroup -win $_nWave1 {G2}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSelectSignal -win $_nWave1 {( "G2" 3 )} 
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvZoom -win $_nWave1 51.538683 53.846386
wvZoomAll -win $_nWave1
wvSelectGroup -win $_nWave1 {G3}
