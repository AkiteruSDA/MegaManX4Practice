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
