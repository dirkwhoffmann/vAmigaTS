## Objective

Visualizes the stack contents when an IRQ is executed.

#### stack1 and stack2

These tests executes several interrupts. Inside the interrupt handlers, the stack pointer is manipulated to point into color space. Hence, the background color varies depending on when a value is written to the stack. The color reflects the value written value. Test stack1 varies the number of active biplanes from 0 to 5. Test stack2 enables 6 bitplanes in each zone.

#### stack3 and stack4
 
Similar to stack1 and stack2 for the TRAP instruction.

#### stack5 and stack6
 
Similar to stack1 and stack2 for the TRAPV instruction.


Dirk Hoffmann, 2022
