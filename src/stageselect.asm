.psx

; Go to stage select after character select.
stage_select_character_select:
replace 0x8002E4D0
    ; Calling function 3 in this jump table instead of 0
    lw v0, 0x398+3*4(at)
endreplace stage_select_character_select

; Automatically scroll camera down on stage select.
stage_select_camera_scroll:
replace 0x8002E7E0
    nop ; nop is 4 bytes in MIPS
endreplace stage_select_camera_scroll

; Skip maverick intros.
stage_select_skip_intros:
replace 0x8002EED8
    nop
endreplace stage_select_skip_intros

; Hacks for when a stage is selected.
stage_select_on_selection:
replace 0x8002ED44
    ; Replaced a load delay slot with this jump
    jal stage_select_on_selection
endreplace stage_select_on_selection
    ; Skipped code
    sb v0,0x0D(s0)

    push t1
    ; If select (?) is held, go to part 2 of stage.
    lb t1,INPUT_1_CURR
    nop ; load delay
    andi t1,t1,0x01
    sb t1,STAGE_PART
    pop t1
    jr ra
