.psx

; When loading stage select (Game State 3), always load cutscene state 3,
; which is standard immediate boss selection. Does not affect middle selection
; availability, that's something different.
@stage_select_mode:
replace 0x8002E4B0
    li v1,3
endreplace @stage_select_mode

; When stage select initially reads mavericks defeated, load 0 instead.
; This stops some special stage selection states (after 4 mavs, after 8 mavs etc)
@mav_check:
replace 0x8002E50C
    li a1,0
endreplace @mav_check

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
    ; overwriting an 8 byte pseudoinstruction
    li t1,0
    nop
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

; Press select to toggle the defeated state of a maverick.
@toggle_defeated:
replace 0x8002EC90
    jal @toggle_defeated
    nop ; An instruction here was clobbering v0 in the branch delay slot before I had a chance to use it...
endreplace @toggle_defeated
    ; New input bytes are loaded in v0 here as a halfword
    andi t0,v0,0x0100 ; Select is 0x01 on Input 2
    beq t0,$zero,@@done
    li t2,1
    lb t0,SELECTION_STAGE_ID_MINUS_ONE
    lb t1,MAVERICKS_DEFEATED
    sllv t2,t2,t0
    xor t1,t1,t2
    sb t1,MAVERICKS_DEFEATED
@@done:
    jr ra
    andi v0,v0,0x0840 ; This was the clobbering instruction mentioned above

; Hacks for when a stage is selected.
@on_selection:
replace 0x8002ED44
    jal @on_selection
endreplace @on_selection
    lb t0,INPUT_1_CURR
    lb t1,CURRENT_STAGE
    andi t0,t0,0x0C
    ; Hold L1 to go to part 2 of a maverick stage. (L1 is 0x04 on input 1)
    srl t0,t0,2
    andi t2,t0,1
    sb t2,STAGE_PART
    srl t2,t0,1
    beq t2,$zero,@@set_items
    ; Hold R1 to go to a non-maverick stage. (R1 is 0x08 on input 1)
    subi t1,t1,1 ; Mav stage IDs start at 1 so zero-index it for the table
    add t1,t1,t1 ; Table is of halfwords so double the index
    lui t0,hi(org(stage_id_to_alt_stage_table))
    add t0,t0,t1
    lh t1,lo(org(stage_id_to_alt_stage_table))(t0)
    nop
    sh t1,CURRENT_STAGE
@@set_items:
    ; Do later
    jr ra
