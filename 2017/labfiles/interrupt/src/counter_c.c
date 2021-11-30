#include <linux/module.h>		// Needed to make kernel module
#include <linux/kernel.h>		// Needed for KERN_INFO
#include <linux/interrupt.h>	// Needed for register_irq

// #define IRQ 176	// GPIO_NR 10: IRQ #176
#define IRQ 175	// GPIO_NR 9: IRQ #175

/*
* Enables access to the gpio
*/
void setup( void );

/*
* Disables access to the GPIO
*/
void setdown( void );

/*
* Interrupt service routine
*/
irqreturn_t counter_isr(int,void*);

/*
* Module init function
*/

static int __init btnrpi_init(void)
{
  setup();
  if(request_irq(IRQ, counter_isr, IRQF_TRIGGER_FALLING, "counter#btn", NULL))
  {
    printk(KERN_ERR "COUNTER - Unable to request IRQ. Aborting.\n");
    free_irq(IRQ,NULL);
    return -EINVAL;
  }
  printk(KERN_INFO "COUNTER - Driver initialized.\n");
  return 0;
}

/**
* Module exit function
*/
static void __exit btnrpi_exit(void)
{
  printk(KERN_INFO "COUNTER - Unloading driver\n");
  setdown();
  free_irq(IRQ, NULL);
}

MODULE_LICENSE("GPLv3");
MODULE_DESCRIPTION("Linux LED driver");
MODULE_AUTHOR("Viktor Enfeldt, Björn Blomberg");

module_init(btnrpi_init);
module_exit(btnrpi_exit);
