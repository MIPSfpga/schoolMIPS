rd /s /q sim
md sim
cd sim

copy ..\*.hex .

vsim -novopt -do ../modelsim_script.tcl

cd ..
