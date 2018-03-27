# super-duper-nes

==========  Super-duper NES project!  ==========

This is a project that extends NES (Nintendo Entertainment System) with FPGA (DE0-CV board).

Architecture:
![alt text](https://github.com/astoria-d/super-duper-nes/blob/master/architecture.png )

User application ROM is deployed on FPGA ROM area. NES and DE0-CV board is connected through the NES 60 pin connector. User application has the Linux console screen. FPGA then has the I2C controler that connects FPGA and Linux board (Beagle bone black SBC). This will enable controling Linux from NES.

Demo:

<a href="http://www.youtube.com/watch?feature=player_embedded&v=RXIwD2YRAUA" target="_blank"><img src="http://img.youtube.com/vi/RXIwD2YRAUA/0.jpg" alt="super duper nes demo" width="240" height="180" border="10" /></a>

https://youtu.be/RXIwD2YRAUA


It can extend NES capability to infinity!

--astoria-d

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

