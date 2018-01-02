
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

#include "bbb_tty.h"

MODULE_LICENSE("GPL");
MODULE_AUTHOR("astoria-d");
MODULE_DESCRIPTION("super-duper-nes bbb tty module.");
MODULE_VERSION("0.1");

static char *mod_name = "bbb_tty";
module_param(mod_name, charp, 0444);
MODULE_PARM_DESC(name, "module name @ /sys/module/bbb_tty/parameters/mod_name");


static int __init bbb_tty_init(void){
    int ret;

    printk(KERN_INFO "%s initialize.\n", mod_name);

    ret = bbb_tty_proc_init();
    if (ret) {
        printk(KERN_ERR "bbb_tty_proc_init failed.\n");
        return -1;
    }

    return 0;
}

static void __exit bbb_tty_exit(void){
    bbb_tty_proc_exit();
    printk(KERN_INFO "%s exit.\n", mod_name);
}

module_init(bbb_tty_init);
module_exit(bbb_tty_exit);

