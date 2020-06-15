.psx

.open "../build/SLUS_005_VANILLA.61", "../build/SLUS_005.61", 0x80010000-0x800

.macro replace,dest
	.org dest
.endmacro

.macro endreplace,nextlabel
	.org org(nextlabel)
.endmacro

; This block is the main area for now.
.org 0x8011C200
.area 0x03F0

.include "stageselect.asm"

.endarea
.close
