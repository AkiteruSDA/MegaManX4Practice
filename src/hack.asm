.psx

.open "../build/SLUS_005_VANILLA.61", "../build/SLUS_005.61", 0x80010000-0x800

; Constants
STAGE_ID_SPIDER equ 0x01
STAGE_ID_PEACOCK equ 0x06
STAGE_ID_OWL equ 0x07
STAGE_ID_DRAGOON equ 0x04
STAGE_ID_STINGRAY equ 0x05
STAGE_ID_MUSHROOM equ 0x03
STAGE_ID_BEAST equ 0x08
STAGE_ID_WALRUS equ 0x02
; ROM(? it all seems to be ram in PS1) Addresses
STAGE_SELECT_TO_STAGE_ID_TABLE_HI equ 0x800F
STAGE_SELECT_TO_STAGE_ID_TABLE_LO equ 0x474C
STAGE_SELECT_TO_STAGE_ID_TABLE equ 0x800F474C
STAGE_ID_TO_STAGE_SELECT_TABLE_HI equ 0x800F
STAGE_ID_TO_STAGE_SELECT_TABLE_LO equ 0x4758
STAGE_ID_TO_STAGE_SELECT_TABLE equ 0x800F4758
; RAM Addresses
CURRENT_STAGE equ 0x801721CC
STAGE_PART equ 0x801721CD
INPUT_1_PREV equ 0x80166C09
INPUT_1_CURR equ 0x80166C0B
INPUT_1_NEXT equ 0x80166C0D
INPUT_2_PREV equ 0x80166C08
INPUT_2_CURR equ 0x80166C0A
INPUT_2_NEXT equ 0x80166C0C
MAVERICKS_DEFEATED equ 0x80172219

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

.include "tables.asm"
.include "stageselect.asm"

.endarea
.close
