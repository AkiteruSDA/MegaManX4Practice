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
PLAY_SOUND_SUB equ 0x8001540C ; plays sound id currently on a1
MENU_SELECT_SOUND_ID equ 0x22
; RAM Addresses
GAME_STATE_1 equ 0x801721C0
CURRENT_PLAYER equ 0x80172203
CURRENT_STAGE equ 0x801721CC
STAGE_PART equ 0x801721CD
CURRENT_CHECKPOINT equ 0x801721DD
MAX_HP equ 0x80172206
IFRAME_COUNTER equ 0x80141929
CURRENT_HP equ 0x80141924
CURRENT_WEAPON equ 0x8014195B
WEAPON_ENERGIES equ 0x80141970 ; 16 bytes, max at 0x30 each
SUB_HP_1 equ 0x8017221C
SUB_HP_2 equ 0x8017221D
WEP_HP equ 0x8017221E
HEARTS_OBTAINED equ 0x8017221A
TANKS_OBTAINED equ 0x8017221B ; upper 4 bits
ARMOR_OBTAINED equ 0x80172207 ; lower 4 bits
BUSTER_TYPE equ 0x80172208
CAM_X_CURR equ 0x801419B8
CAM_X_PREV equ 0x801419C4
CAM_Y_CURR equ 0x801419BC
CAM_Y_PREV equ 0x801419C8
INPUT_1_PREV equ 0x80166C08
INPUT_1_CURR equ 0x80166C0A
INPUT_1_NEW equ 0x80166C0C ; DPad, start, select
INPUT_2_PREV equ 0x80166C09
INPUT_2_CURR equ 0x80166C0B
INPUT_2_NEW equ 0x80166C0D ; Face buttons, shoulder buttons
MAVERICKS_DEFEATED equ 0x80172219
SELECTION_STAGE_ID_MINUS_ONE equ 0x80173DA7 ; only in stage select
REFIGHT_CAPSULE_STATES equ 0x801721EE ; 8 bytes. 00 is open, 01 is closing and 02 is closed.
TELEPORT_VALUE_1 equ 0x801418CC ; Set to 0x0003 when teleporting
TELEPORT_VALUE_2 equ 0x801721CF ; Set to 0x00C0 when teleporting
ONE_BEFORE_SIGMA_HPS equ 0x8013BF61 ; to use v0 as an offset in @sigma_infinite
GUNNER_SIGMA_HP equ 0x8013BF62
GROUND_SIGMA_HP equ 0x8013BF63
SIGMA_FIGHT_LIFECYCLE equ 0x8013BF66 ; will be 2 before ground spawns, 6 before gunner spawns
SIGMA_FIGHT_STATE equ 0x8013B8B8 ; 0 is both alive, 1 is gunner dead, 2 is ground dead
STAGE_SELECT_ICON_DATA_ZERO equ 0x801BD714
STAGE_SELECT_ICON_DATA_X equ 0x801BD2CC
STAGE_SELECT_ICON_DATA_LENGTH equ 256
TEMP_RAM equ 0x8011E3F0
TEMP_RAM_LENGTH equ 16
CONTROLLER_INPUTS_1 equ (TEMP_RAM + 0)
CONTROLLER_INPUTS_2 equ (TEMP_RAM + 1)
CONTROLLER_INPUTS_1_PREV equ (TEMP_RAM + 2)
CONTROLLER_INPUTS_2_PREV equ (TEMP_RAM + 3)
HEARTS_STORAGE equ (TEMP_RAM + 4)
TANKS_STORAGE equ (TEMP_RAM + 5)
ARMOR_STORAGE equ (TEMP_RAM + 6)
WEAPON_STORAGE equ (TEMP_RAM + 7)
CHECKPOINT_STORAGE equ (TEMP_RAM + 8)
SPAWN_NEXT_SIGMA equ (TEMP_RAM + 9) ; 0 to spawn ground, 1 to spawn gunner
CHECKPOINT_LOAD_READY equ (TEMP_RAM + 10) ; Using this to get loading checkpoint a frame to soak so weapon swaps don't crash etc
INPUT_1_DONT_COUNT equ (TEMP_RAM + 11)
CHECKPOINT_LOADING equ (TEMP_RAM + 12)
CAVE_1 equ 0x8011C200
CAVE_1_LENGTH equ 0x03F0
CAVE_2 equ 0x8011E400
CAVE_2_LENGTH equ 0x07D0

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
; There are 16 bytes here for storing temporary things in RAM
.org TEMP_RAM
.area TEMP_RAM_LENGTH
.dw 0x00000000
.dw 0x00000000
.dw 0x00000000
.dw 0x00000000
.endarea

; Split the code into 2 caves because only cave 2 was causing things to break after a while
.org CAVE_1 ; This is nearly full, so put stuff that won't change much
.area CAVE_1_LENGTH
; Assembly hacks
.include "asm/tables.asm"
.include "asm/utils.asm"
.include "asm/stageselect.asm"
.endarea
.org CAVE_2
.area CAVE_2_LENGTH
.include "asm/general.asm"
.include "asm/gameplay.asm"
.include "asm/menu.asm"
.include "asm/icons.asm"
.endarea
.close

; Non-assembly/data hacks. Files should be opened and closed where necessary since they can vary.
; These changes require you to delete the bin and build folders before building.
.include "data/menu.asm"
