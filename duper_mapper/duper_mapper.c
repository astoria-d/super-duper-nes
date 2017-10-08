#include <dlfcn.h>
#include <stdio.h>

#define __mapper_impl__

#include "tools.h"
#include "mapper.h"


static mp_set_addr_t set_rom_addr;
static mp_get_data_t get_rom_data;
static mp_dbg_get_byte_t rom_dbg_get_byte;
static mp_dbg_get_short_t rom_dbg_get_short;

int mp_init(mp_set_addr_t set_func, mp_get_data_t get_func) {
    printf("duper mapper init...\n");
    set_rom_addr = set_func;
    get_rom_data = get_func;
    
    rom_dbg_get_byte = NULL;
    rom_dbg_get_short = NULL;
}

void mp_clean(void) {
    printf("duper mapper clean...\n");
}



void mp_set_addr(unsigned short addr) {
/*    printf("duper mapper addr: %02x\n", addr);*/
    (*set_rom_addr)(addr);
}

unsigned char mp_get_data(void) {
    return (*get_rom_data)();
}

int mp_set_debugger(mp_dbg_get_byte_t byte_func, mp_dbg_get_short_t short_func) {
    rom_dbg_get_byte = byte_func;
    rom_dbg_get_short = short_func;
}

unsigned char mp_dbg_get_byte(unsigned short offset) {
    printf("mapper debugger...\n");
    return (*rom_dbg_get_byte)(offset);
}

unsigned short mp_dbg_get_short(unsigned short offset) {
    return (*rom_dbg_get_short)(offset);
}

