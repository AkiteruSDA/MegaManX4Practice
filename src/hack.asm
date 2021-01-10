.psx

.open "../build/SLUS_005_VANILLA.61", "../build/SLUS_005.61", 0x80010000-0x800

; Constants
PLAYER_ID_X equ 0x00
PLAYER_ID_ZERO equ 0x01
STAGE_ID_SPIDER equ 0x01
STAGE_ID_PEACOCK equ 0x06
STAGE_ID_OWL equ 0x07
STAGE_ID_DRAGOON equ 0x04
STAGE_ID_STINGRAY equ 0x05
STAGE_ID_MUSHROOM equ 0x03
STAGE_ID_BEAST equ 0x08
STAGE_ID_WALRUS equ 0x02
STAGE_ID_SPACE_PORT equ 0x0A
STAGE_ID_FINAL_WEAPON_1 equ 0x0B
STAGE_ID_FINAL_WEAPON_2 equ 0x0C
; ROM(? it all seems to be ram in PS1) Addresses
STAGE_SELECT_TO_STAGE_ID_TABLE_HI equ 0x800F
STAGE_SELECT_TO_STAGE_ID_TABLE_LO equ 0x474C
STAGE_SELECT_TO_STAGE_ID_TABLE equ 0x800F474C
STAGE_ID_TO_STAGE_SELECT_TABLE_HI equ 0x800F
STAGE_ID_TO_STAGE_SELECT_TABLE_LO equ 0x4758
STAGE_ID_TO_STAGE_SELECT_TABLE equ 0x800F4758
; RAM Addresses
GAME_STATE_1 equ 0x801721C0
CURRENT_PLAYER equ 0x80172203
CURRENT_STAGE equ 0x801721CC
STAGE_PART equ 0x801721CD
CURRENT_CHECKPOINT equ 0x801721DD
MAX_HP equ 0x80172206
SUB_HP_1 equ 0x8017221C
SUB_HP_2 equ 0x8017221D
WEP_HP equ 0x8017221E
HEARTS_OBTAINED equ 0x8017221A
TANKS_OBTAINED equ 0x8017221B ; upper 4 bits
ARMOR_OBTAINED equ 0x80172207 ; lower 4 bits
BUSTER_TYPE equ 0x80172208
INPUT_1_PREV equ 0x80166C08
INPUT_1_CURR equ 0x80166C0A
INPUT_1_NEW equ 0x80166C0C
INPUT_2_PREV equ 0x80166C09
INPUT_2_CURR equ 0x80166C0B
INPUT_2_NEW equ 0x80166C0D
MAVERICKS_DEFEATED equ 0x80172219
SELECTION_STAGE_ID_MINUS_ONE equ 0x80173DA7 ; only in stage select
REFIGHT_CAPSULE_STATES equ 0x801721EE ; 8 bytes. 00 is open, 01 is closing and 02 is closed.
TELEPORT_VALUE_1 equ 0x801418CC ; Set to 0x0003 when teleporting
TELEPORT_VALUE_2 equ 0x801721CF ; Set to 0x00C0 when teleporting

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
.org 0x8011E3F0
.area 0x08E0

; Assembly hacks
.include "asm/tables.asm"
.include "asm/stageselect.asm"
.include "asm/gameplay.asm"
.include "asm/menu.asm"

.endarea
.close

; Non-assembly/data hacks. Files should be opened and closed where necessary since they can vary.
; These changes require you to delete the bin and build folders before building.
.include "data/menu.asm"
