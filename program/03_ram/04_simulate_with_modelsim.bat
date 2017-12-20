rd /s /q sim
md sim
cd sim

copy ..\*.hex .

vsim -do ../modelsim_script.tcl

cd ..
