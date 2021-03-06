
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/console.h>
#include <linux/tty.h>
#include <linux/tty_driver.h>
#include <linux/tty_flip.h>
#include <linux/kthread.h>
#include <linux/sched.h>
#include <linux/semaphore.h>

#include "bbb_tty.h"

#define BT_FIFO_SIZE    256
#define NES_LF          0x8a


/*forward declarations...*/
static int nes_tty_write(struct tty_struct * tty, const unsigned char *buf, int count);
static int nes_tty_write_room(struct tty_struct *tty);
static int nes_tty_install(struct tty_driver *drv, struct tty_struct *tty);
static void nes_tty_cleanup(struct tty_struct *tty);
static int nes_tty_open(struct tty_struct *tty, struct file *file);
static void nes_tty_close(struct tty_struct *tty, struct file *file);
static void nes_tty_hangup(struct tty_struct *tty);
static void nes_console_write (struct console *co, const char *str, unsigned int count);
static struct tty_driver *nes_console_device(struct console *co, int *idx);
static int nes_console_setup(struct console *cp, char *arg);


/*static variables...*/
static const struct tty_port_operations bt_port_ops = { };

static struct tty_port    bbb_tty_port;

static struct tty_driver *bbb_tty_driver;

static const struct tty_operations nes_tty_ops = {
    .write      = nes_tty_write,
    .write_room = nes_tty_write_room,
    .install    = nes_tty_install,
    .cleanup    = nes_tty_cleanup,
    .open       = nes_tty_open,
    .close      = nes_tty_close,
    .hangup     = nes_tty_hangup,
};

static struct console nes_console_driver = {
    .name       = "ttynes",
    .write      = nes_console_write,
    .device     = nes_console_device,
    .setup      = nes_console_setup,
    .flags      = CON_PRINTBUFFER,
    .index      = -1,
};

static struct task_struct *bt_thread;
static struct semaphore gpio_sem;
static int received_gpio;

/*implementations...*/

static void bbb_tty_receiver(unsigned char ch) {
    int ret;

/*
    printk(KERN_INFO "receiver: bbb_tty_port.count %d\n", bbb_tty_port.count);
    printk(KERN_INFO "receiver: bbb_tty_port.buf.head %p\n", bbb_tty_port.buf.head);
    printk(KERN_INFO "receiver: bbb_tty_port.buf.tail %p\n", bbb_tty_port.buf.tail);
*/
    if (bbb_tty_port.count == 0) {
        /*tty is not open.*/
        return;
    }

    if (ch == NES_LF) {
        ch = '\n';
    }
    ret = tty_insert_flip_char(&bbb_tty_port, ch, TTY_NORMAL);
    if (ret != 1) {
        printk(KERN_INFO "tty_insert_filp failed. [%c]\n", ch);
    }
    tty_flip_buffer_push(&bbb_tty_port);
}

void bbb_tty_notify(int irq) {
    received_gpio = bt_irq2gpio(irq);
    up(&gpio_sem);
}

static int bt_data_recv_func(void *arg) {

    __set_current_state(TASK_RUNNING);
    printk(KERN_INFO "kthread started.\n");
    while (!kthread_should_stop()) {
        /*wait for interrupt...*/
        down(&gpio_sem);
        if (kthread_should_stop()) break;

        /*printk(KERN_INFO "recgpio %d.\n", received_gpio);*/
        if (received_gpio == GPIO_BBB_FIFO_EMPTY) {
            while (!get_bbb_fifo_empty()) {
                char ch = bt_i2c_getchr();
                /*printk(KERN_INFO "getch %c.\n", ch);*/
                bbb_tty_receiver(ch);
            }
        }
        /*CONFIG_HZ=250
        schedule_timeout_interruptible(HZ);*/
    }
    printk(KERN_INFO "kthread done.\n");

    return 0;
}

static int nes_tty_write(struct tty_struct * tty, const unsigned char *buf, int count) {
    int i;

    //printk("nes_tty_write start.count:%d.\n", count);
    for (i = 0; i < count; i++) {
        int res;
        res = bt_i2c_putchr(buf[i]);
        if (!res)
            break;
    }
    //printk("nes_tty_write done.i:%d.\n", i);
    return i;
}

static int nes_tty_write_room(struct tty_struct *tty) {
        return BT_FIFO_SIZE;
}

static int nes_tty_install(struct tty_driver *drv, struct tty_struct *tty) {
    int ret;

    tty_port_init(&bbb_tty_port);
    bbb_tty_port.ops = &bt_port_ops;

    ret = tty_port_install(&bbb_tty_port, drv, tty);
    if (ret) {
        printk(KERN_INFO "tty_port_install failed.\n");
        return ret;
    }
/*
    printk(KERN_INFO "install: bbb_tty_port.buf.head %p\n", bbb_tty_port.buf.head);
    printk(KERN_INFO "install: bbb_tty_port.buf.tail %p\n", bbb_tty_port.buf.tail);
*/
    return 0;
}

static void nes_tty_cleanup(struct tty_struct *tty) {
    tty_port_destroy(&bbb_tty_port);
}

static int nes_tty_open(struct tty_struct *tty, struct file *file) {
    tty_port_tty_set(&bbb_tty_port, tty);
    return tty_port_open(&bbb_tty_port, tty, file);
}

static void nes_tty_close(struct tty_struct *tty, struct file *file) {
    tty_port_tty_set(&bbb_tty_port, NULL);
    tty_port_close(&bbb_tty_port, tty, file);
}

static void nes_tty_hangup(struct tty_struct *tty) {
    tty_port_hangup(&bbb_tty_port);
}


static void nes_console_write (struct console *co, const char *str, unsigned int count) {
    while (count--) {
        bt_i2c_putchr( *str++ );
    }
}

static struct tty_driver *nes_console_device(struct console *co, int *idx) {
    *idx = co->index;
    return bbb_tty_driver;
}

static int nes_console_setup(struct console *cp, char *arg) {
    return 0;
}

int __init bbb_tty_init(void){
    int ret;

    printk(KERN_INFO "bbb_tty init.\n");

    received_gpio = 0;
    sema_init(&gpio_sem, 0);

    bt_thread = kthread_create(bt_data_recv_func, NULL, "ttynes_th");
    if (!bt_thread) {
        printk(KERN_INFO "failed to craete kernel thread.\n");
        return -1;
    }
    wake_up_process(bt_thread);

    bbb_tty_driver = alloc_tty_driver(1);
    if (!bbb_tty_driver) {
        printk(KERN_INFO "tty driver allocation error.\n");
        return -ENOMEM;
    }

    bbb_tty_driver->driver_name     = "bbb_tty_driver";
    bbb_tty_driver->name            = "ttyNES";
    bbb_tty_driver->num             = 1;
    bbb_tty_driver->type            = TTY_DRIVER_TYPE_SERIAL;
    bbb_tty_driver->subtype         = SERIAL_TYPE_NORMAL;
    bbb_tty_driver->flags           = TTY_DRIVER_REAL_RAW;
    bbb_tty_driver->init_termios    = tty_std_termios;

    tty_set_operations(bbb_tty_driver, &nes_tty_ops);
    tty_port_link_device(&bbb_tty_port, bbb_tty_driver, 0);
    ret = tty_register_driver(bbb_tty_driver);
    if (ret) {
        printk(KERN_ERR "tty driver registration failed.\n");
        return -1;
    }

    register_console(&nes_console_driver);

    return 0;
}

void __exit bbb_tty_exit(void){
    unregister_console(&nes_console_driver);
    tty_unregister_driver(bbb_tty_driver);
    put_tty_driver(bbb_tty_driver);
    up(&gpio_sem);
    kthread_stop(bt_thread);

    printk(KERN_INFO "bbb_tty exit.\n");
}

