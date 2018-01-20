# schoolMIPS

A small MIPS CPU core originally based on Sarah L. Harris MIPS CPU ("Digital Design and Computer Arhitecture" by David Money Harris and Sarah L Harris). The first version of schoolMIPS was written for [Young Russian Chip Architects](http://www.silicon-russia.com/2017/06/09/arduino-and-fpga/) summer school.

The CPU have several versions (from simple to complex). Each of them is placed in the separate git branch:
- **00_simple** - the simplest CPU without data memory, programs compiled with GNU gcc;
- **01_mmio** - the same but with data memory, simple system bus and peripherals (pwm, gpio, als);
- **02_irq** - data memory, system timer, interrupts and exceptions (CP0 coprocessor);
- **03_pipeline** - the pipelined version of the simplest core with data memory 
- **04_pipeline_irq** - the pipelined version of 02_irq

For docs and CPU diagrams please visit the project [wiki](https://github.com/MIPSfpga/schoolMIPS/wiki)

![CPU diagram](../../wiki/img/schoolMIPS_diagram.gif) 
