.psx

; Go to stage select after character select.
@character_select:
replace 0x8002E4D0
    ; Calling function 3 in this jump table instead of 0
    lw v0,0x398+3*4(at)
endreplace @character_select

; Automatically scroll camera down on stage select.
@camera_scroll:
replace 0x8002E7E0
    nop
endreplace @camera_scroll

; Skip maverick intros.
@skip_intros:
replace 0x8002EED8
    nop
endreplace @skip_intros

; Always show undefeated stage icons.
@undefeated_stage_icons:
replace 0x8002E5EC
    li t1,0
endreplace @undefeated_stage_icons

; Make defeated stage icons flicker.
@defeated_icons_flicker:
replace 0x800CA978
    jal @defeated_icons_flicker
endreplace @defeated_icons_flicker
    ; v1 is a counter here. Increments every frame.
    ; Used to determine visibility on a given frame for flickering.
    lbu t1,MAVERICKS_DEFEATED
    li t0,0
@@visibility_loop:
    ; Get the visibility byte.
    ; 0x02 and 0x03 are visible. 0x01 is invisible.
    li t2,3
    andi t3,t1,1
    sub t2,t2,t3
    andi t3,v0,1
    sub t2,t2,t3
    ; Get the right offset for the stage icon
    lui t3,STAGE_ID_TO_STAGE_SELECT_TABLE_HI
    add t3,t3,t0
    lb t3,STAGE_ID_TO_STAGE_SELECT_TABLE_LO(t3)
    ; Calculate and store to the visibility byte address. Base address is 0x80173E24.
    li t4,0xC0 ; number of bytes between each foreground item
    mult t3,t4
    mflo t3
    lui t4,0x8017
    add t3,t4,t3
    sb t2,0x3E24(t3)
    ; Shift and iterate again if necessary
    addi t0,t0,1
    bne t0,8,@@visibility_loop
    srl t1,t1,1
    jr ra

; Hacks for when a stage is selected.
@on_selection:
replace 0x8002ED44
    jal @on_selection
endreplace @on_selection
    lb t1,INPUT_1_CURR
    nop ; load delay
    andi t1,t1,0x01
    sb t1,STAGE_PART
    jr ra
