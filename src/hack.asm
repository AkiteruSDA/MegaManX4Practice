.psx

.open "../build/SLUS_005_VANILLA.61", "../build/SLUS_005.61", 0x80010000-0x800

; RAM Addresses
STAGE_PART equ 0x801721CD
INPUT_1_CURR equ 0x80166C0B ; Maybe? Not important whether it's curr/prev/etc right now

; Macros for replacing existing code and then jumping back to cave org
.macro replace,dest
	.org dest
.endmacro
.macro endreplace,nextlabel
	.org org(nextlabel)
.endmacro

; Stack macros
.macro push,reg
	addiu sp,sp,-4
	sw reg,(sp)
.endmacro
.macro pop,reg
	lw reg,(sp)
	addiu sp,sp,4
.endmacro

; This block is the main area for now.
.org 0x8011C200
.area 0x03F0

.include "stageselect.asm"

.endarea
.close
