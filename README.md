# super-duper-nes

==========  Super-duper NES project!  ==========

This is a project that extends NES (Nintendo Entertainment System) with FPGA (DE0-CV board). Remember Nintendo Disk System? This Super-duper NES is similar to that legendary system. We impliment original ROM on the FPGA and add new feature to NES. With this FPGA, NES will bocome the one that never existed before. You can add your own feature with FPGA.

astoria-d

-------

# source tree:
  
    top  
    |-- circuit-diagram             (obsolete)  
    |-- doc                         Technical documents.  
    |   |-- craft-work-diary        Electronic handcrafts pictures  
    |   |   |-- yyyymmdd  
    |   |   |-- ....  
    |   |   `-- yyyymmdd  
    |   `-- memo                    Linux work memo  
    |-- duper_cartridge             NES FPGA cartridge implementation (ROM, I2C slave, FIFO etc.)  
    |   `-- simulation              Modelsim scripts  
    |-- duper_linux                 Linux modules  
    |   |-- bbb_tty                 NES tty driver for BBB  
    |   |-- nes_shell  
    |   `-- tools  
    |-- duper_mapper                motonesemu mapper module.  
    |-- duper_rom                   NES cardridge ROM code  
    `-- test  

