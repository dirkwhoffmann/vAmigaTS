/*
	SetCPU V1.4
	Original version by Dave Haynie (released to the public domain)
   Slighly modified by Dirk W. Hoffmann

	MAIN PROGRAM

    V1.4
	I now add several commands in the assembly stub for manipulating
	a few of the MMU registers.  SetCPU now uses this to permit a
	simple relocation of the ROM Kernel into 32 bit memory, which is
	then translated back to the normal $00FC0000 base of the ROM
	Kernel.  This will increase system performance noticably.

    V1.3
	I now check for the existence of an MMU, and allow for testing of 
	different CPUs, for use in CLI scripts and that kind of thing.
	Apparently some 68020 boards out there don't fully decode CPU space
	addresses, and, as a result, their math chip shows up in all 8
	coprocessor slots.  This makes the MMU test hang, since instead of
	getting no MMU, I get instead an FPU responding to an MMU 
	instruction, which will probably hang the system.  The "NOMMUTEST"
	option allows for the rest of this program to work on such a 
	board.
	
    V1.2
	The program now defaults to "WALLOC" mode for '030 data cache, since
	that's the proper mode for Amiga data caches (user and supervisor
	modes share data).
	
    V1.1
	This program tells which Motorola CPU is in place, and allows the
	some cache control on 68020 and 68030 machines.  It also sets up
	the ExecBase->AttnFlags with 68030 information, so that any
	subsequent program can use the standard methods to identify if the
	system is a 68030 system.
	
*/

#define PROGRAM_VERSION	"V1.4"

#include <exec/types.h>
#include <exec/execbase.h>
#include <exec/nodes.h>
#include <exec/interrupts.h>

// DIRK
#include <exec/exec.h>
#include <exec/memory.h>
#include <proto/exec.h>
#include <stdio.h>
#include <stdlib.h>

/* ====================================================================== */

/* Define all bit components used for manipulation of the Cache Control
   Register. */

#define CACR_INST	(1L<<0)
#define CACR_DATA	(1L<<8)

#define CACR_WALLOC	5
#define CACR_BURST	4
#define CACR_CLEAR	3
#define CACR_ENTRY	2
#define CACR_FREEZE	1
#define CACR_ENABLE	0

/* ====================================================================== */

/* Define important bits used in various MMU registers. */

/* Here are the CRP definitions.  The CRP register is 64 bits long, but
   only the first 32 bits are control bits, the next 32 bits provide the
   base address of the table. */

#define	CRP_UPPER	(1L<<31)		/* Upper/lower limit mode */
#define CRP_LIMIT(x)	((ULONG)((x)&0x7fff)<<16)/* Upper/lower limit value */
#define CRP_SG		(1L<<9)			/* Indicates shared space */
#define CRP_DT_INVALID	0x00			/* Invalid root descriptor */
#define	CRP_DT_PAGE	0x01			/* Fixed offset, auto-genned */
#define CRP_DT_V4BYTE	0x02			/* Short root descriptor */
#define	CRP_DT_V8BYTE	0x03			/* Long root descriptor */

/* Here are the TC definitions.  The TC register is 32 bits long. */

#define	TC_ENB		(1L<<31)		/* Enable the MMU */
#define	TC_SRE		(1L<<25)		/* For separate Supervisor */
#define	TC_FCL		(1L<<24)		/* Use function codes? */
#define	TC_PS(x)	((ULONG)((x)&0x0f)<<20)	/* Page size */
#define TC_IS(x)	((ULONG)((x)&0x0f)<<16)	/* Logical shift */
#define	TC_TIA(x)	((ULONG)((x)&0x0f)<<12)	/* Table indices */
#define	TC_TIB(x)	((ULONG)((x)&0x0f)<<8)
#define TC_TIC(x)	((ULONG)((x)&0x0f)<<4)
#define	TC_TID(x)	((ULONG)((x)&0x0f)<<0)

/* Here are the page descriptor definitions, for short desctriptors only,
   since that's all I'm using at this point. */
   
#define	PD_ADDR(x)	((ULONG)(x)&~0x0f)	/* Translated Address */
#define	PD_WP		(1L<<2)			/* Write protect it! */
#define PD_DT_INVALID	0x00			/* Invalid root descriptor */
#define	PD_DT_PAGE	0x01			/* Fixed offset, auto-genned */
#define PD_DT_V4BYTE	0x02			/* Short root descriptor */
#define	PD_DT_V8BYTE	0x03			/* Long root descriptor */

/* ====================================================================== */

/* Some external declarations. */

void SetCACR(), GetCRP(), SetCRP(), SetTC();
ULONG GetCACR(), GetTC(), GetCPUType(), GetMMUType(), GetFPUType();

/* Checking logic */

#define	CK68000	0
#define CK68010	1
#define CK68020	2
#define CK68030	3
#define CK68851	4
#define CK68881	5
#define CK68882	6
#define CKFPU	7
#define CKMMU	8
#define CHECKS	9

#define	WARNING	5

struct checker { char *item; BOOL tag; };

struct checker checks[CHECKS] = {
   { "68000", FALSE },
   { "68010", FALSE },
   { "68020", FALSE },
   { "68030", FALSE },
   { "68851", FALSE },
   { "68881", FALSE },
   { "68882", FALSE },
   { "FPU",   FALSE },
   { "MMU",   FALSE }
};

USHORT code = 0L;	/* Program return code */

/* ====================================================================== */

/* This replaces the Lattice "stricmp()" function, plus it's a better form
   for my needs here. */
   
static BOOL striequ(s1,s2)
char *s1,*s2;
{
   BOOL aok;
   
   while (*s1 && *s2 && (aok = (*s1++ & 0xdf) == (*s2++ & 0xdf)));
   return (BOOL) (!*s1 && aok);
}

/* This routine prints FPU codes and sets things accordingly. */

static void PrintFPU(fpu)
ULONG fpu;
{
   if (fpu == 68881L) {
      printf("68881 ");
      if (checks[CK68881].tag) code = 0;
   } else if (fpu == 68882L) {
      printf("68882 ");
      if (checks[CK68882].tag) code = 0;
   }
   if (fpu && checks[CKFPU].tag) code = 0;
}

/* ====================================================================== */

/* Here's the MMU support stuff. */

#define ROUND		0x00001000L
#define ROMBASE		0x00FC0000L
#define ROMSIZE		0x00040000L
#define TABSIZE		(128L * sizeof(ULONG))

/* Page tables and other MMU stuff must be on a page sized boundary, and
   that boundary must be a power of two.  This routine allocates such an
   aligned block of memory. */

static void *AllocAligned(size,bound)
ULONG size;
ULONG bound;
{
   void *mem, *aligned;
   
   if (!(mem = AllocMem(size+bound,0L))) return NULL;   
   Forbid();
   aligned = (void *)(((ULONG)mem + bound - 1) & ~(bound - 1));
   FreeMem(mem,size+bound);
   mem = AllocAbs(size,aligned);
   Permit();
   return mem;
}

/* This routine creates the Fast ROM.  If the memory can't be allocated,
   it returns FALSE, otherwise, TRUE.  The "wrapbits" argument probably
   won't work for every case.  There's some magic here which I seem to
   have working, but don't understand completely.  Basically, the TC
   register must be correct, or you'll get a configuration exception,
   otherwise know as GURU #38.  The big constraint is that sum of the
   TIx fields from A to the first zero field, plus PS and IS, must be
   equal to 32. */

static BOOL CreateFastROM(wrapbits)
short wrapbits;
{
   ULONG i, myCRP[2], myTC, *ROM32 = NULL, *MMUTable = NULL;

  /* First off, get the memory for the 32 bit ROM and the MMU table. */

   ROM32 = AllocAligned(ROMSIZE,ROUND);
   MMUTable = AllocAligned(TABSIZE,ROUND);
   if (!ROM32 || !MMUTable) {
      if (MMUTable) FreeMem(MMUTable,TABSIZE);
      if (ROM32)    FreeMem(ROM32,ROMSIZE);
      return FALSE;
   }

  /* Here I set up the ROM, as quickly as possible! */

   CopyMemQuick((ULONG *)ROMBASE,(ULONG *)ROM32,ROMSIZE);

  /* Now I initialize the MMU table.  This translation is really very
     basic.  I set up one table level and use direct page translation
     on a grain of 128K per entry.  Everything's directly mapped except
     for the last two entries, which is for the $FC0000-$FFFFFF area.
     This I translate to my fastram ROM, and write protect it too. */

   for (i = 0; i < 126; i++) MMUTable[i] = PD_ADDR(i<<17)|PD_DT_PAGE;
   MMUTable[126] = PD_ADDR(ROM32)|PD_WP|PD_DT_PAGE;
   MMUTable[127] = PD_ADDR(((ULONG)ROM32)+0x20000L)|PD_WP|PD_DT_PAGE;

  /* Now I have to set up the MMU.  The CPU Root Pointer tells the MMU about 
     the table I've set up, and the Translation Control register will turn 
     the thing on.  Note that the first half of the CRP is control data, the
     second the address of my table. */

   myCRP[0] = CRP_LIMIT(0x007f)|CRP_SG|CRP_DT_V4BYTE;
   myCRP[1] = (ULONG)MMUTable;
   SetCRP(myCRP);

   myTC = TC_ENB|TC_PS(0x0c)|TC_IS(wrapbits)|
          TC_TIA(0x0f-wrapbits)|TC_TIB(0x05)|TC_TIC(0)|TC_TID(0);
   SetTC(myTC);
   return TRUE;
}

/* This routine remover the Fast ROM, and re-claims the memory previously
   allocated.  We've already checked to make sure that the MMU was 
   switched on. */

static void DeleteFastROM() {
   ULONG myCRP[2], *ROM32 = NULL, *MMUTable = NULL;

  /* First off, turn of the MMU.  This lets us muck with the table and
     reclaim memory without any trouble. */

   SetTC(0L);

  /* Now get the root pointer, which will tell where the memory has been
     allocated. */

   GetCRP(myCRP);
   MMUTable = (ULONG *)myCRP[1];
   ROM32 = (ULONG *)PD_ADDR(MMUTable[126]);

  /* Now I just free up the memory, and I'm done! */
  
   FreeMem(MMUTable,TABSIZE);
   FreeMem(ROM32,ROMSIZE);
}

/* ====================================================================== */

/* Codes for the FASTROM action. */

#define	FR_NO_ACTION	0
#define	FR_CREATE	1
#define	FR_DELETE	2

/* This be the main program. */

int main(argc,argv)
int argc;
char *argv[];
{
   BOOL worked, dommutest = TRUE, fastrom = FR_NO_ACTION;
   ULONG cacr,op,mode,test,cpu,fpu,mmu = 0;
   USHORT i,j;
   short wrapbits = 8;

   /* If they're just asking for help */

   if (argc >= 2 && argv[1][0] == '?') {
      printf("\2337mSetCPU %s by Dave Haynie\2330m\n",PROGRAM_VERSION);
      printf("Usage: SetCPU [INST|DATA] [[NO]CACHE|[NO]BURST]\n");
      printf("              [[NO]FASTROM [TRAP]] [NOMMUTEST]\n");
      printf("              [CHECK 680x0|68851|6888x|MMU|FPU]\n");
      exit(0);
   }

  /* Now we parse the command line.  The default cache operation acts on 
     both data and instruction caches.  The way all the cache control
     functions are defined, they're just NOPs on machines without the
     appropriate caches. */
   
   mode = CACR_INST | CACR_DATA;
   cacr = GetCACR();

   if (argc > 1) {
      for (i = 1; i < argc; ++i) {
         if (code == WARNING) for (j = 0; j < CHECKS; ++j)
            if (striequ(checks[j].item,argv[i])) {
               checks[j].tag = TRUE;
               break;
            }
         if (striequ(argv[i],"CHECK"))		code = WARNING;
         else if (striequ(argv[i],"FASTROM"))	fastrom = FR_CREATE;
         else if (striequ(argv[i],"NOFASTROM"))	fastrom = FR_DELETE;
         else if (striequ(argv[i],"TRAP"))	wrapbits = 0;
         else if (striequ(argv[i],"NOMMUTEST"))	dommutest = FALSE;
         else if (striequ(argv[i],"DATA"))	mode = CACR_DATA;
         else if (striequ(argv[i],"INST"))	mode = CACR_INST;
         else if (striequ(argv[i],"CACHE"))	cacr |=   mode << CACR_ENABLE;
         else if (striequ(argv[i],"NOCACHE"))	cacr &= ~(mode << CACR_ENABLE);
         else if (striequ(argv[i],"BURST"))	cacr |=   mode << CACR_BURST;
         else if (striequ(argv[i],"NOBURST"))	cacr &= ~(mode << CACR_BURST);
      }

     /* We ALWAYs want to be in Word Allocate mode, AmigaOS won't run 
        otherwise. */

      SetCACR(cacr | CACR_DATA << CACR_WALLOC);
   }

  /* Let's find out what we have, and perform the ROM translation, if it's
     requested and hasn't been done already. */

   cpu = GetCPUType();
   fpu = GetFPUType();
   if (dommutest && (mmu = GetMMUType())) {
      if (!(GetTC() & TC_ENB)) {
         if (fastrom == FR_CREATE && !CreateFastROM(wrapbits)) {
            printf("Error: Can't get memory for FASTROM translation\n");
            exit(10);
         }
      } else if (fastrom == FR_DELETE)
         DeleteFastROM();
   }

   printf("SYSTEM: ");

   /* If they're not on a 68020/68030, we can't set anything.  For 
      compatibility across systems, I don't consider a cache setting 
      request an error, just ignore it. */

   if (cpu <= 68010L) {
      if (cpu == 68010L) {
         printf("68010 ");
         if (checks[CK68010].tag) code = 0;
      } else {
         printf("68000 ");
         if (checks[CK68000].tag) code = 0;
      }
      PrintFPU(fpu);
      printf("\n");
      exit(code);
   }

   /* Now we're on a 32 bit system.  But EXEC doesn't know which.  If you
      run SetCPU on a 68030 system once, the '030 flag's set, otherwise, 
      we'll test for it. */

   if (cpu == 68030L) {
      printf("68030 ");
      if (checks[CK68030].tag) code = 0;
   } else {
      printf("68020 ");
      if (checks[CK68020].tag) code = 0;
   }

   PrintFPU(fpu);

   if (mmu == 68851L) {
      printf("68851 ");
      if (checks[CK68851].tag) code = 0;
   }
   if (mmu && checks[CKMMU].tag) code = 0;
   if (mmu && (GetTC() & TC_ENB)) printf("FASTROM ");

   /* We always print the results, even if nothing has changed. */
   
   cacr = GetCACR();
   printf("(INST: ");
   if (!(cacr & (CACR_INST << CACR_ENABLE))) printf("NO");
   printf("CACHE");

   if (cpu == 68030L) {
      printf(" ");
      if (!(cacr & (CACR_INST << CACR_BURST))) printf("NO");
      printf("BURST) (DATA: ");
      if (!(cacr & (CACR_DATA << CACR_ENABLE))) 
         printf("NOCACHE ");
      else
         printf("CACHE ");

      if (!(cacr & (CACR_DATA << CACR_BURST))) printf("NO");
      printf("BURST");
   }
   printf(")\n");

   /* For safety's sake, or personal paranoia, or whatever, I dump the
      data cache before I go away. */

   if (cpu = 68030L) SetCACR(cacr|(CACR_DATA << CACR_CLEAR));
   exit(code);
}

