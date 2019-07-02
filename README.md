# schoolMIPS

A small MIPS CPU core originally based on Sarah L. Harris MIPS CPU ("Digital Design and Computer Arhitecture" by David Money Harris and Sarah L Harris). The first version of schoolMIPS was written for [Young Russian Chip Architects](http://www.silicon-russia.com/2017/06/09/arduino-and-fpga/) summer school.

The CPU have several versions (from simple to complex). Each of them is placed in the separate git branch:
- **00_simple** - the simplest CPU without data memory, programs compiled with GNU gcc;
- **01_mmio** - the same but with data memory, simple system bus and peripherals (pwm, gpio, als);
- **02_irq** - data memory, system timer, interrupts and exceptions (CP0 coprocessor);
- **03_pipeline** - the pipelined version of the simplest core with data memory 
- **04_pipeline_irq** - the pipelined version of 02_irq
- **05_pipeline_ahb** - 04_pipeline_irq with AHB-Lite bus support and Scratchpad RAM

For docs and CPU diagrams please visit the project [wiki](https://github.com/MIPSfpga/schoolMIPS/wiki)    
Examples of using this kernel as an element of a multiprocessor system:   
1. A.E. Ryazanova, A.A. Amerikanov, E. V Lezhnev, Development of multiprocessor system-on-chip based on soft processor cores schoolMIPS, J. Phys. Conf. Ser. 1163 (2019) 012026. [doi:10.1088/1742-6596/1163/1/012026](https://iopscience.iop.org/article/10.1088/1742-6596/1163/1/012026).
2. [Innovate FPGA 2019 project: EM028 » NoC-based multiprocessing system prototype](http://www.innovatefpga.com/cgi-bin/innovate/teams.pl?Id=EM028)
![CPU diagram](../../wiki/img/schoolMIPS_diagram.gif) 
