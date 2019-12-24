;------------------------------
; Example inspired by Photon's Tutorial:
;  https://www.youtube.com/user/ScoopexUs
;
;---------- Includes ----------
              INCDIR      "include"
              INCLUDE     "hw.i"
              INCLUDE     "funcdef.i"
              INCLUDE     "exec/exec_lib.i"
              INCLUDE     "graphics/graphics_lib.i"
              INCLUDE     "hardware/cia.i"
;---------- Const ----------

CIAA            = $00bfe001
COPPERLIST_SIZE = 1000                                 ;Size of the copperlist
LINE            = 100                                  ;<= 255

init:
              movem.l     d0-a6,-(sp)
 
              lea         CUSTOM,a6                    ; adresse de base
              move.w      INTENAR(a6),INTENARSave      ; Copie de la valeur des interruptions 
              move.w      DMACONR(a6),DMACONSave       ; sauvegarde du dmacon 
              move.w      #$138,d0                     ; wait for eoframe paramètre pour la routine de WaitRaster - position à attendre
              bsr.w       WaitRaster                   ; Appel de la routine wait raster - bsr = jmp,mais pour des adresses moins distantes
              move.w      #$206c,INTENA(a6)            ; désactivation de toutes les interruptions bits : valeur + masque sur 7b
              move.w      #$7fff,INTREQ(a6)            ; disable all bits in INTREQ
              move.w      #$7fff,DMACON(a6)            ; disable all bits in DMACON
              move.w      #$87e0,DMACON(a6)            ; Activation classique pour démo


******************************************************************	
mainloop:
		; Wait for vertical blank
              ;--move.w      #$0c,d0                      ;No buffering, so wait until raster
              
              
              move.w      #50,d0
              bsr.w       WaitRaster                   ;is below the Display Window.
              move.w      #$ff0,COLOR00(a6)

              move.w      #150,d0
              bsr.w       WaitRaster                   ;is below the Display Window.
              move.w      #$0a0,COLOR00(a6)


              clr.l       d1
              move.l      #100,d1
loop: 
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0
              bchg        d0,d0

              subq        #1,d1
              bne.b       loop
              move.w      #$3f3,COLOR00(a6)

              clr.l       d1
              move.l      #100,d1
loop2: 
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0
              ori         #0,d0

              subq        #1,d1
              bne.b       loop2
              move.w      #$00f,COLOR00(a6)


;----------- main loop ------------------
              move.w      #$138,d0                     ;No buffering, so wait until raster
              bsr.w       WaitRaster                   ;is below the Display Window.

              lea         CUSTOM,a6
              move.w      #$f00,COLOR00(a6)
              jmp         mainloop 

;----------- end main loop ------------------

checkmouse:
;--              btst        #CIAB_GAMEPORT0,CIAA+ciapra
;--              bne.b       mainloop

exit:
              move.w      #$7fff,DMACON(a6)            ; disable all bits in DMACON
              or.w        #$8200,(DMACONSave)          ; Bit mask inversion for activation
              move.w      (DMACONSave),DMACON(a6)      ; Restore values
              move.l      (CopperSave),COP1LC(a6)      ; Restore values
              or          #$c000,(INTENARSave)         
              move        (INTENARSave),INTENA(a6)     ; interruptions reactivation
              movem.l     (sp)+,d0-a6
              clr         d0                           ; Return code of the program
              rts                                      ; End
	
WaitRaster:				              ;Wait for scanline d0. Trashes d1.
.l:           move.l      vposr(a6),d1
              lsr.l       #1,d1
              lsr.w       #7,d1
              cmp.w       d0,d1
              bne.s       .l                           ;wait until it matches (eq)
              rts
******************************************************************	
gfxname:
              GRAFNAME                                 ; inserts the graphics library name

              EVEN

DMACONSave:   DC.w        1
CopperSave:   DC.l        1
INTENARSave:  DC.w        1
waitras1:     DC.L        0
waitras2:     DC.L        0
copperlist:   DC.L        0

