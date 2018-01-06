
#include <linux/kernel.h>
#include <linux/of.h>
#include <linux/gpio.h>
#include <linux/interrupt.h>
#include <linux/irq.h>

#include "bbb_tty.h"

static int gpio_bbb_f_emp_irq;
static int gpio_nes_f_ful_irq;

int get_bbb_fifo_empty(void) {
    return gpio_get_value(GPIO_BBB_FIFO_EMPTY);
}

int get_nes_fifo_full(void) {
    return gpio_get_value(GPIO_NES_FIFO_FULL);
}

int bt_irq2gpio(int irq) {
    if (irq == gpio_bbb_f_emp_irq) {
        return GPIO_BBB_FIFO_EMPTY;
    }
    else if (irq == gpio_nes_f_ful_irq) {
        return GPIO_NES_FIFO_FULL;
    }
    else {
        return 0;
    }
}

int bt_gpio_proc_show(struct seq_file *seq) {
    int val;

    seq_printf(seq, "gpio info:\n");

    val = gpio_get_value(GPIO_BBB_FIFO_EMPTY);
    seq_printf(seq, "   bbb_f_empty: %d\n", val);

    val = gpio_get_value(GPIO_NES_FIFO_FULL);
    seq_printf(seq, "   nes_f_full: %d\n", val);
    return 0;
}

static irq_handler_t bt_gpio_irq_handler(unsigned int irq, void *dev_id, struct pt_regs *regs){
    printk(KERN_INFO "gpio interrupt. irq:%d\n", irq);
    bbb_tty_notify(irq);
    return (irq_handler_t) IRQ_HANDLED;
}

int bt_gpio_init(void){
    int ret;

    /*initialize gpio pin*/
    gpio_request(GPIO_BBB_FIFO_EMPTY, "sysfs");
    gpio_direction_input(GPIO_BBB_FIFO_EMPTY);
    gpio_bbb_f_emp_irq = gpio_to_irq(GPIO_BBB_FIFO_EMPTY);

    gpio_request(GPIO_NES_FIFO_FULL, "sysfs");
    gpio_direction_input(GPIO_NES_FIFO_FULL);
    gpio_nes_f_ful_irq = gpio_to_irq(GPIO_NES_FIFO_FULL);

    /*register interrupt hander.
     triggered when fifo is not empty.
     bbb_tty_gpio_handler appears @ /proc/interrupts */
    ret = request_irq(gpio_bbb_f_emp_irq, (irq_handler_t) bt_gpio_irq_handler,
            IRQF_TRIGGER_FALLING, "bbb_tty_bbb_f_emp", NULL);
    if (ret) {
        printk(KERN_INFO "error! irq:%d, ret:%d\n", gpio_bbb_f_emp_irq, ret);
    }
    ret = request_irq(gpio_nes_f_ful_irq, (irq_handler_t) bt_gpio_irq_handler,
            IRQF_TRIGGER_FALLING, "bbb_tty_nes_f_ful", NULL);
    if (ret) {
        printk(KERN_INFO "error! irq:%d, ret:%d\n", gpio_nes_f_ful_irq, ret);
    }

    printk(KERN_INFO "gpio init done.\n");

    return ret;
}

void bt_gpio_exit(void){
    free_irq(gpio_bbb_f_emp_irq, NULL);
    free_irq(gpio_nes_f_ful_irq, NULL);
    gpio_free(GPIO_BBB_FIFO_EMPTY);
    gpio_free(GPIO_NES_FIFO_FULL);
    printk(KERN_INFO "gpio exit.\n");
}

