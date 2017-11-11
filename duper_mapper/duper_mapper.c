#include <dlfcn.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#define __mapper_impl__

#include "tools.h"
#include "mapper.h"


static mp_set_addr_t set_rom_addr;
static mp_get_data_t get_rom_data;
static mp_set_data_t set_rom_data;

static mp_dbg_get_byte_t rom_dbg_get_byte;
static mp_dbg_get_short_t rom_dbg_get_short;


static unsigned short mapper_access_addr;
static unsigned char fifo_read_reg;
static unsigned char fifo_write_reg;
static unsigned char fifo_status_reg;

#define I2C_INPUT   "i2c_in"

/*
0xfff9	w: push fifo register
	r: pop fifo register
0xfff8	fifo status register
	
	
	firo status register

bit	
0	write fifo empty
1	write fifo full
2	always 0
3	always 0
4	read fifo empty
5	read fifo full
6	always 0
7	always 0
*/

int mp_init(mp_set_addr_t set_a_func, mp_get_data_t get_d_func, mp_set_data_t set_d_func) {
    printf("duper mapper init...\n");

    printf("duper mapper i2c emuration:\n");
    printf("    to send a data to NES: [i2c_in].\n");
    printf("    to receive a data from NES: [i2c_out].\n");
    printf("    you can send i2c one character at a time.\n");
    printf("    > echo -n \"a\" > i2c_in\n");
    printf("    you can receive from i2c\n");
    printf("    > cat i2c_out\n");
    printf(" #write fifo empty/full is not implemented.\n");
    printf(" #read fifo full register is not implemented.\n");

    set_rom_addr = set_a_func;
    get_rom_data = get_d_func;
    set_rom_data = set_d_func;
    
    rom_dbg_get_byte = NULL;
    rom_dbg_get_short = NULL;

    mapper_access_addr = 0;
    fifo_read_reg = 0;
    fifo_write_reg = 0;
    fifo_status_reg = 0;
}

void mp_clean(void) {
    printf("duper mapper clean...\n");
}



void mp_set_addr(unsigned short addr) {
    mapper_access_addr = addr;
    (*set_rom_addr)(addr);
}

unsigned char mp_get_data(void) {
    int in_fifo;

    if (mapper_access_addr == 0x7FF9) {
        /*read fifo reg.*/

        in_fifo = open(I2C_INPUT, O_RDONLY);
        if (in_fifo != -1) {
            read(in_fifo, &fifo_read_reg, 1);
            close(in_fifo);
            /*clean up fifo.*/
            remove(I2C_INPUT);
        }

        printf("duper mapper get fifo: %02x\n", fifo_read_reg);
        return fifo_read_reg;
    }
    else if (mapper_access_addr == 0x7FF8) {

/*
status bit...
4	read fifo empty
5	read fifo full
*/
        in_fifo = open(I2C_INPUT, O_RDONLY);
        if (in_fifo == -1) {
            /*fifo empty.*/
            fifo_status_reg |= 0x10;
        }
        else {
/*
            printf("fifo input...\n");
*/
            fifo_status_reg &= ~0x10;
            close(in_fifo);
        }

        /*TODO: check write full*/

        printf("duper mapper get fifo status: %02x\n", fifo_status_reg);
        return fifo_status_reg;
    }
    else {
        /*read rom.*/
        /*
        printf("duper mapper get data: %04x\n", mapper_access_addr);
        */
        return (*get_rom_data)();
    }
}

void mp_set_data(unsigned char data) {
    if (mapper_access_addr == 0x7FF9) {
        /*write fifo reg.*/
        printf("duper mapper set data: %02x\n", data);/**/
        fifo_write_reg = data;
    }
    else {
        /*write rom.*/
        (*set_rom_data)(data);
    }
}

int mp_set_debugger(mp_dbg_get_byte_t byte_func, mp_dbg_get_short_t short_func) {
    rom_dbg_get_byte = byte_func;
    rom_dbg_get_short = short_func;
}

unsigned char mp_dbg_get_byte(unsigned short offset) {
/*    printf("mapper debugger...\n");*/
    return (*rom_dbg_get_byte)(offset);
}

unsigned short mp_dbg_get_short(unsigned short offset) {
    return (*rom_dbg_get_short)(offset);
}

