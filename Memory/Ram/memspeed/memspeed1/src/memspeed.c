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
#define ITER 1000 // Number of iterations done by speed_test

#define ECLOCK_FREQ_HZ 709379
#define NS_PER_SEC 1000000000ULL

extern struct ExecBase* SysBase;

extern ULONG speed_test(REG(d0, UWORD), REG(a0, const void*));

static ULONG test(const void* addr, const char* desc)
{
    const ULONG t = speed_test(N, addr);
    const uint64_t at = NS_PER_SEC * t / ECLOCK_FREQ_HZ / N / ITER;
    printf("%-20s %10lu %10llu\n", desc, t, at);
    return (ULONG)at;
}

static const char* mem_desc(const void* ptr)
{
    const UWORD attributes = TypeOfMem(ptr);
    if (attributes & MEMF_CHIP)
        return "Chip";
    return (ULONG)ptr >= 0xc00000 && (ULONG)ptr <= 0xde0000 ? "Slow" : "Fast";
}

int main(void)
{
    printf("--------------------------------------------------\n");
    printf("Code running from %s memory\n", mem_desc(&speed_test));
    printf("Number of iterations: %lu\n\n", (ULONG)N*ITER);
    printf("Description             Eclocks   Access time (ns)\n");
    printf("--------------------------------------------------\n");
    test((void*)0xbfd000, "CIA");
    test((void*)0xdff002, "Custom chips");
    test((void*)0xf80000, "ROM");

    struct MemHeader* mh = (struct MemHeader*)SysBase->MemList.lh_Head;
    for (; mh->mh_Node.ln_Succ; mh = (struct MemHeader*)mh->mh_Node.ln_Succ) {
        char desc[21];
        snprintf(desc, sizeof(desc), "$%06lX (%s)", (ULONG)mh->mh_Lower & ~0xfff, mem_desc(mh->mh_Lower));
        test(mh->mh_Lower, desc);
    }

    const ULONG at = test((void*)&speed_test, "Code mem");
    uint64_t cpufreq = NS_PER_SEC * 8 / at;
    printf("\nCPU frequency (assuming real fast): %lu.%06lu MHz\n", (ULONG)(cpufreq / 1000000), (ULONG)(cpufreq % 1000000));
    return 0;
}
