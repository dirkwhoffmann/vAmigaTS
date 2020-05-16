## Objective

Visualizes the stack contents when an IRQ is executed.

#### stack1

This test executes several interrupts. Inside the interrupt handlers,
the stack pointer is manipulated to point into color space. Hence, the background color varies depending on when a value is written to the stack. The color reflects the value written value. 


Dirk Hoffmann, 2020
