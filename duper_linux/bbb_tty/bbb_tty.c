
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("astoria-d");
MODULE_DESCRIPTION("super-duper-nes bbb tty module.");
MODULE_VERSION("0.1");

static char *mod_name = "bbb_tty";
module_param(mod_name, charp, S_IRUGO);
MODULE_PARM_DESC(name, "The name to display in /var/log/kern.log");

static int __init bbb_tty_init(void){
    printk(KERN_INFO "%s initialize.\n", mod_name);
    return 0;
}

static void __exit bbb_tty_exit(void){
    printk(KERN_INFO "%s exit.\n", mod_name);
}

module_init(bbb_tty_init);
module_exit(bbb_tty_exit);

