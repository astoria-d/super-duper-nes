#include <dlfcn.h>
#include <stdio.h>

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

/*
0xfff9	w: push fifo register
	    r: pop fifo register
0xfff8	fifo status register
*/

int mp_init(mp_set_addr_t set_a_func, mp_get_data_t get_d_func, mp_set_data_t set_d_func) {
    printf("duper mapper init...\n");
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
    if (mapper_access_addr == 0x7FF9) {
        /*read fifo reg.*/
        printf("duper mapper get fifo: %02x\n", fifo_read_reg);
        return fifo_read_reg;
    }
    else if (mapper_access_addr == 0x7FF8) {
        /*read fifo status reg.*/
        printf("duper mapper get status: %02x\n", fifo_status_reg);
        return fifo_read_reg;
    }
    else {
        /*read rom.*/
        printf("duper mapper get data: %04x\n", mapper_access_addr);/**/
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

