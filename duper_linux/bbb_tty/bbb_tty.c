
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/console.h>
#include <linux/tty.h>
#include <linux/tty_driver.h>

#include "bbb_tty.h"

static int nes_tty_write(struct tty_struct * tty,
        const unsigned char *buf, int c) {
    int i;

    for (i = 0; i < c; i++) {
        int res;
        res = bt_i2c_putchr(buf[i]);
        if (!res)
            break;
    }
    return i;
}

static int nes_tty_write_room(struct tty_struct *tty)
{
        return 1;
}


static const struct tty_operations nes_tty_ops = {
    .write      = nes_tty_write,
    .write_room = nes_tty_write_room,
/*
    .open       = nes_tty_open,
    .close      = nes_tty_close,
    .install    = nes_tty_install,
    .cleanup    = nes_tty_cleanup,
    .hangup     = nes_tty_hangup,
*/
};


static struct tty_driver *bbb_tty_driver;

static void nes_console_write (struct console *co, const char *str,
                       unsigned int count)
{
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
        pr_err("tty driver allocation error.\n");
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

