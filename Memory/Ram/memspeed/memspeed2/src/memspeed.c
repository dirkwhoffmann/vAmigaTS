#include <proto/exec.h>
#include <exec/execbase.h>
#include <hardware/cia.h>
#include <resources/cia.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#ifdef __VBCC__
#define REG(reg, arg) __reg(#reg) arg
#else
#define REG(reg, arg) arg __asm(#reg)
#endif

#define N 10
#define ITER 200 // Number of iterations done by speed_test

#define ECLOCK_FREQ_HZ 709379
#define NS_PER_SEC 1000000000ULL
#define CCK_PER_ECLOCK 5

extern struct ExecBase* SysBase;

extern void tst_b();
extern void tst_l();
extern void lsr_1();
extern void lsr_2();
extern void lsr_3();
extern void lsr_4();
extern void lsr_5();
extern void lsr_6();
extern void lsr_7();
extern void lsr_8();
extern void pure_fast();

extern ULONG speed_test(REG(d0, UWORD), REG(a0, void (*)()));

static ULONG test(void (*func)(), const char* desc)
{
    const ULONG eclocks = speed_test(N, func);
    const ULONG iter_cck = eclocks * (1000 * CCK_PER_ECLOCK) / (N*ITER);
    printf("%-20s %10lu %2lu.%03lu\n", desc, eclocks, iter_cck / 1000, iter_cck % 1000);
    return eclocks * NS_PER_SEC / ((uint64_t)ECLOCK_FREQ_HZ * N * ITER);
}

static const char* mem_desc(const void* ptr)
{
    const UWORD attributes = TypeOfMem(ptr);
    if (attributes & MEMF_CHIP)
        return "chip";
    return (ULONG)ptr >= 0xc00000 && (ULONG)ptr <= 0xde0000 ? "slow" : "fast";
}

int main(void)
{
    printf("--------------------------------------------------\n");
    printf("Code running from %s memory ($%06lX)\n", mem_desc(&speed_test), (ULONG)&speed_test);
    printf("Description             Eclocks   CCKs\n");
    printf("--------------------------------------------------\n");
    test(&tst_b, "TST.B");
    test(&tst_l, "TST.L");
    test(&lsr_1, "LSR 1");
    test(&lsr_2, "LSR 2");
    test(&lsr_3, "LSR 3");
    test(&lsr_4, "LSR 4");
    test(&lsr_5, "LSR 5");
    test(&lsr_6, "LSR 6");
    test(&lsr_7, "LSR 7");
    test(&lsr_8, "LSR 8");
    ULONG est_freq = NS_PER_SEC * (70 + 10) / test(&pure_fast, "FAST");
    printf("Estimated frequency: %lu.%06lu MHz\n", est_freq/1000000, est_freq%1000000);
    return 0;
}
