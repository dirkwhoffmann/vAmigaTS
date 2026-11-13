## Summary
---

Interrupt acceptance and the STOP instruction. The interrupts are provoked
with software requests (bits in INTREQ), so the IPL pins are stable long before
the CPU looks at them and the result does not depend on Paula's timing. The
shared harness `interrupt.i` is derived from `stackframe.i`. It records the
exception frame like the stack frame tests do. In addition, A4 counts the level
5 interrupts and A5 counts the level 6 interrupts (the last two result pairs).

| Test        | Question                                                              |
|-------------|-----------------------------------------------------------------------|
| interrupt1  | Does the stacked PC of an interrupt point to the next instruction?    |
| interrupt2  | `STOP #0` (clears S): does a pending interrupt wake the CPU normally, or does it raise a privilege violation? |
| interrupt3  | `STOP #$2200` with level 5 and 6 pending and stable: is level 6 taken first? |
| interrupt4  | Same, but INTREQ is written by the instruction right before STOP. Which level does the CPU see: only 6 (A4 = 0, A5 = 1) or 5 first (A4 = 1, A5 = 1)? |

The related test `StackFrame/stackframe6` checks the stacked PC of a CHK that
fails on the lower bound (negative operand).

## Background
---

These tests were derived from differences that a differential test between
Moira and the cycle-exact UAE core revealed (`sequenceuae` in the Moira
repository). Moira had the following problems, which are fixed now:

- The stacked PC of an interrupt was two bytes too high.
- The 68010 CHK pushed a PC that was two bytes too high.
- The stopped CPU took a stale interrupt level that was sampled before STOP
  loaded the new mask.

Moira also raised a privilege violation when a CPU, which STOP had put into
user mode, was woken up. That behavior had no known justification and was
removed.

## Expected values
---

The `expected000/010/020` arrays are predictions made with Moira. They have not
been verified on real hardware yet. Please check them on a real machine and
correct them where they differ.

Level 7 (the NMI) cannot be requested through Paula. The edge triggering of
level 7 is therefore only covered by the emulator tests.
