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
    ; Get mavericks defeated and fill tanks.
    lb t1,MAVERICKS_DEFEATED
    li t0,0x20
    sb t0,WEP_HP
    addi t0,t0,0xA080
    sh t0,SUB_HP_1 ; Filling both sub tanks at once
    ; Iterate across mavericks defeated and prepare the flags to set.
    li t0,0 ; count, finished at 8. is stageid - 1
    li t4,0 ; HEART FLAGS
    li t5,0 ; TANK/ARMOR FLAGS
@@items_loop:
    lui t3,hi(org(stage_id_to_item_table))
    sll t0,t0,2
    addu t3,t3,t0
    andi t2,t1,1
    beq t2,$zero,@@check_pt2 ; Maverick not defeated, so go to second check
    srl t0,t0,2
    j @@check_special
    nop
@@check_pt2:
    ; If iterating over the current stage and going to part 2, add the items from part 1.
    lb t2,CURRENT_STAGE
    addi t0,t0,1
    bne t0,t2,@@loop_check
    subi t0,t0,1
    lb t2,STAGE_PART
    nop
    bne t2,$zero,@@current_stage_pt_2
    nop
    j @@loop_check
    nop
@@check_special:
    ; SPECIAL CASE:
    ; If playing as X, currently iterating on Dragoon, and Current Stage ID is not:
    ; - Mushroom
    ; - Peacock
    ; - Space Port
    ; - Final Weapon 1
    ; - Final Weapon 2
    ; do not set any flags.
    ; This is because in the X 100% route, the items in this stage are obtained in a revisit
    ; after the other 6 mavs besides Mushroom and Peacock are defeated.
    lb t2,CURRENT_PLAYER
    nop
    bne t2,$zero,@@do_standard ; Player ID for X is 0
    lb t2,CURRENT_STAGE
    nop
    subi t2,t2,STAGE_ID_MUSHROOM
    beq t2,$zero,@@do_standard
    subi t2,t2,3
    beq t2,$zero,@@do_standard ; if 0, on peacock
    subi t2,t2,4
    beq t2,$zero,@@do_standard ; if 0, on space port
    subi t2,t2,1
    beq t2,$zero,@@do_standard ; if 0, on final weapon 1
    subi t2,t2,1
    beq t2,$zero,@@do_standard ; if 0, on final weapon 2
    li t2,STAGE_ID_DRAGOON
    addi t0,t0,1
    beq t0,t2,@@loop_check
    subi t0,t0,1
@@do_standard:
    j @@flags_loop
@@current_stage_pt_2:
    lw t2,lo(org(stage_id_to_item_table))(t3) ; this runs in the delay slot of the above jump as well
    nop
    andi t2,t2,0xFFFF
@@flags_loop:
    nop
    beq t2,$zero,@@loop_check
    or t4,t4,t2
    srl t2,t2,8
    or t5,t5,t2
    j @@flags_loop
    srl t2,t2,8
@@loop_check:
    addi t0,t0,1
    bne t0,8,@@items_loop
    srl t1,t1,1
    ; Set hearts obtained and max HP.
    andi t4,t4,0xFF
    sb t4,HEARTS_OBTAINED
    li t1,0x20
@@max_hp_loop:
    andi t2,t4,1
    sll t2,t2,1
    add t1,t1,t2
    bne t4,$zero,@@max_hp_loop
    srl t4,t4,1
    sb t1,MAX_HP
    ; Set tanks and armor.
    andi t1,t5,0x0F
    sb t1,ARMOR_OBTAINED
    andi t1,t5,4
    srl t1,t1,2
    sb t1,BUSTER_TYPE ; If buster upgrade was obtained, set buster type to 1 (4-shot)
    andi t1,t5,0xF0
    sb t1,TANKS_OBTAINED
    lh t1,HEARTS_OBTAINED
    lb t2,ARMOR_OBTAINED
    sh t1,HEARTS_STORAGE
    sb t2,ARMOR_STORAGE
    jr ra
    nop
