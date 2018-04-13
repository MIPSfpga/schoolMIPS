
echo off

rem START Simulation default params

rem testbench top module name
set TOPMODULE=sm_testbench
rem simulation clock cycles count
set SIMULATION_CYCLES=120

rem END Simulation default params

rem read simulation params from local icarus config file
for /f "delims=" %%x in (icarus.cfg) do (set "%%x")

rem iverilog compile settings
set IVARG=-g2005 
set IVARG=%IVARG% -D SIMULATION
set IVARG=%IVARG% -D ICARUS
set IVARG=%IVARG% -D SIMULATION_CYCLES=%SIMULATION_CYCLES%
set IVARG=%IVARG% -I ..\..\..\src
set IVARG=%IVARG% -I ..\..\..\testbench
set IVARG=%IVARG% -s %TOPMODULE%
set IVARG=%IVARG% ..\..\..\src\*.v
set IVARG=%IVARG% ..\..\..\testbench\*.v

rem checks that iverilog & vvp are installed
where iverilog.exe
if errorlevel 1 (
    echo "iverilog.exe not found!"
    echo "Please install IVERILOG and add 'iverilog\bin' and 'iverilog\gtkwave\bin' directories to PATH"
    goto return
)

where vvp.exe
if errorlevel 1 (
    echo "vvp.exe not found!"
    echo "Please install IVERILOG and add 'iverilog\bin' and 'iverilog\gtkwave\bin' directories to PATH"
    goto return
)

where gtkwave.exe
if errorlevel 1 (
    echo "gtkwave.exe not found!"
    echo "Please install IVERILOG and add 'iverilog\bin' and 'iverilog\gtkwave\bin' directories to PATH"
    goto return
)

rem old simulation clear
rd /s /q sim
md sim
cd sim

copy ..\*.hex .

rem compile
iverilog %IVARG%

rem simulation
vvp -la.lst -n a.out -vcd

rem output
gtkwave dump.vcd

cd ..

:return
