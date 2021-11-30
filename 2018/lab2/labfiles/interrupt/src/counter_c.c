#include <linux/module.h>		// Needed to make kernel module
#include <linux/kernel.h>		// Needed for KERN_INFO
#include <linux/interrupt.h>	// Needed for register_irq

#define IRQ1 176	// Byt ut 0 mot IRQ för knapp som räknar upp
#define IRQ2 175	// Byt ut 0 mot IRQ för knapp som räknar ner

/*
 * Enables access to the gpio
 */
void setup( void );
/*
 * Disables access to the GPIO
 */
void setdown( void );
/*
 * Interrupt service routines
 */
irqreturn_t counter_isr_up(int,void*);
irqreturn_t counter_isr_down(int, void*);

/*
 * Module init function
 */
static int __init btnrpi_init(void)
{
	setup();
	if(request_irq(IRQ1, counter_isr_up, IRQF_TRIGGER_FALLING, "counterUp#btn", NULL)){
		printk(KERN_ERR "COUNTER - Unable to request IRQ. Aborting.\n");
		free_irq(IRQ1,NULL);
		return -EINVAL;
	}
	if(request_irq(IRQ2, counter_isr_down, IRQF_TRIGGER_FALLING, "counterDown#btn", NULL)){
		printk(KERN_ERR "COUNTER - Unable to request IRQ. Aborting.\n");
		//free_irq(IRQ1,NULL);
		free_irq(IRQ2,NULL);
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
	// free irqs
	free_irq(IRQ1, NULL);
	free_irq(IRQ2, NULL);

}

MODULE_LICENSE("GPLv3");
MODULE_DESCRIPTION("Linux LED driver");
MODULE_AUTHOR("ERA NAMN HÄR");

module_init(btnrpi_init);
module_exit(btnrpi_exit);
