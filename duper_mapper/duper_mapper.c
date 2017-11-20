#include <dlfcn.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>

#define __mapper_impl__

#include "tools.h"
#include "mapper.h"


static mp_set_addr_t set_rom_addr;
static mp_get_data_t get_rom_data;
static mp_set_data_t set_rom_data;

static mp_dbg_get_byte_t rom_dbg_get_byte;
static mp_dbg_get_short_t rom_dbg_get_short;


static unsigned short mapper_access_addr;

/*incoming data fifo.*/
static int fifo_data_len;
static unsigned char* fifo;
static unsigned char* fifo_head;


#define I2C_INPUT   "i2c_in"
#define I2C_OUTPUT  "i2c_out"
#define FIFO_MAX    1024
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
    printf("    you can send i2c more than one character at a time (max %d bytes).\n", FIFO_MAX);
    printf("    > echo -n \"abc\" > i2c_in\n");
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

    fifo_data_len = 0;
    fifo = NULL;
}

void mp_clean(void) {
    printf("duper mapper clean...\n");
    if (fifo != NULL) {
        free (fifo);
    }
}



void mp_set_addr(unsigned short addr) {
    mapper_access_addr = addr;
    (*set_rom_addr)(addr);
}

unsigned char mp_get_data(void) {

    if (mapper_access_addr == 0x7FF9) {
        unsigned char fifo_read_reg;
        fifo_read_reg = 0;
        /*read fifo reg.*/

        if (fifo != NULL) {
            fifo_read_reg = *fifo_head++;
            fifo_data_len--;
            if (fifo_data_len <= 0) {
                /*clean up fifo.*/
                free (fifo);
                fifo = NULL;
                printf("data consumed. fifo empty.\n");
/*
*/
            }
        }

        printf("duper mapper get fifo: %02x\n", fifo_read_reg);
        return fifo_read_reg;
    }
    else if (mapper_access_addr == 0x7FF8) {
        unsigned char fifo_status_reg;
        fifo_status_reg = 0;

/*
status bit...
4	read fifo empty
5	read fifo full
*/
        if (fifo == NULL) {
            int in_fifo;
            in_fifo = open(I2C_INPUT, O_RDONLY);
            if (in_fifo != -1) {
                fifo = malloc(FIFO_MAX);
                if (fifo == NULL) {
                    printf("duper mapper fifo allocation failed...\n");
                }
                else {
                    fifo_data_len = read(in_fifo, fifo, FIFO_MAX);
                    fifo_head = fifo;
                }
                close(in_fifo);
                remove(I2C_INPUT);
                printf("new data arrived..\n");
/*
*/
            }
        }
        if (fifo == NULL) {
            /*fifo empty.*/
            fifo_status_reg |= 0x10;
        }
        else {
            /*data ready.*/
            fifo_status_reg &= ~0x10;
        }

        /*TODO: check write full*/

/*
        printf("duper mapper get fifo status: %02x\n", fifo_status_reg);
*/
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
        int out_fifo;

        /*i2c output.*/
        out_fifo = open(I2C_OUTPUT, O_WRONLY | O_APPEND | O_CREAT);
        if (out_fifo != -1) {
            write(out_fifo, &data, 1);
            close(out_fifo);
        }
        printf("duper mapper set data: %02x\n", data);/**/
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

