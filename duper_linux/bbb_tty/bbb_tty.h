
#ifndef __bbb_tth_h__
#define __bbb_tth_h__

#include <linux/seq_file.h>

int bbb_tty_init(void);
void bbb_tty_exit(void);

int bt_proc_init(void);
void bt_proc_exit(void);

int bt_i2c_init(void);
void bt_i2c_exit(void);
int bt_i2c_putchr(char ch);
unsigned char bt_i2c_getchr(void);

int bt_gpio_init(void);
void bt_gpio_exit(void);
int get_bbb_fifo_empty(void);
int get_nes_fifo_full(void);
int bt_irq2gpio(int irq);

void bbb_tty_notify(int irq);

int bt_i2c_proc_show(struct seq_file *seq, void *offset);
int bt_gpio_proc_show(struct seq_file *seq);

#define GPIO_BBB_FIFO_EMPTY 115
#define GPIO_NES_FIFO_FULL  49

#endif

