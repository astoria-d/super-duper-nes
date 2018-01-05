
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/console.h>
#include <linux/tty.h>
#include <linux/tty_driver.h>
#include <linux/tty_flip.h>

#include "bbb_tty.h"

static const struct tty_port_operations bt_port_ops = {
};
static struct tty_port    bbb_tty_port;

void bbb_tty_receiver(char ch) {
    int ret;

    ret = tty_insert_flip_char(&bbb_tty_port, ch, TTY_NORMAL);
    if (ret) {
        printk(KERN_INFO "tty_insert_filp failed. [%c]\n", ch);
    }

    tty_flip_buffer_push(&bbb_tty_port);
}


static int nes_tty_write(struct tty_struct * tty,
        const unsigned char *buf, int count) {
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
        return 1;
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

    return 0;
}

static void nes_tty_cleanup(struct tty_struct *tty) {
    tty_port_destroy(&bbb_tty_port);
}

static int nes_tty_open(struct tty_struct *tty, struct file *file) {
    return tty_port_open(&bbb_tty_port, tty, file);
}

static void nes_tty_close(struct tty_struct *tty, struct file *file) {
    tty_port_close(&bbb_tty_port, tty, file);
}

static void nes_tty_hangup(struct tty_struct *tty) {
    tty_port_hangup(&bbb_tty_port);
}


static const struct tty_operations nes_tty_ops = {
    .write      = nes_tty_write,
    .write_room = nes_tty_write_room,
    .install    = nes_tty_install,
    .cleanup    = nes_tty_cleanup,
    .open       = nes_tty_open,
    .close      = nes_tty_close,
    .hangup     = nes_tty_hangup,
};


static struct tty_driver *bbb_tty_driver;

static void nes_console_write (struct console *co, const char *str,
                       unsigned int count) {
    while (count--) {
        bt_i2c_putchr( *str++ );
    }
}

static struct tty_driver *nes_console_device(struct console *co, int *idx) {
    *idx = co->index;
    return bbb_tty_driver;
}

int nes_console_setup(struct console *cp, char *arg) {
    return 0;
}

static struct console nes_console_driver = {
    .name       = "ttynes",
    .write      = nes_console_write,
    .device     = nes_console_device,
    .setup      = nes_console_setup,
    .flags      = CON_PRINTBUFFER,
    .index      = -1,
};

int __init bbb_tty_init(void){
    int ret;

    printk(KERN_INFO "bbb_tty init.\n");

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
    ret = tty_register_driver(bbb_tty_driver);
    if (ret) {
        printk(KERN_ERR "tty driver registration failed.\n");
        return -1;
    }

    //register_console(&nes_console_driver);

    return 0;
}

void __exit bbb_tty_exit(void){
    //unregister_console(&nes_console_driver);
    tty_unregister_driver(bbb_tty_driver);
    put_tty_driver(bbb_tty_driver);

    printk(KERN_INFO "bbb_tty exit.\n");
}

