
#include <linux/kernel.h>
#include <linux/of.h>
#include <linux/gpio.h>

#include "bbb_tty.h"

#define GPIO_BBB_FIFO_EMPTY 115
#define GPIO_NES_FIFO_FULL  49

int bt_gpio_proc_show(struct seq_file *seq) {
    int val;

    seq_printf(seq, "gpio info:\n");

    val = gpio_get_value(GPIO_BBB_FIFO_EMPTY);
    seq_printf(seq, "   bbb_f_empty: %d\n", val);

    val = gpio_get_value(GPIO_NES_FIFO_FULL);
    seq_printf(seq, "   nes_f_full: %d\n", val);
    return 0;
}

int bt_gpio_init(void){

    printk(KERN_INFO "gpio init.\n");

    return 0;
}

void bt_gpio_exit(void){
    printk(KERN_INFO "gpio exit.\n");
}

