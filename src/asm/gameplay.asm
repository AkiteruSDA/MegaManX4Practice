.psx

; Overwrite the logic for ending a stage to always either go to part 2 or go to mission complete
@stage_end:
replace 0x800200FC
    lb v0,CURRENT_STAGE
    lb v1,STAGE_PART
    subi v0,v0,9 ; Will now be 0 if this is X's Colonel fight
    beq v0,$zero,@@set_mission_complete
    subi v0,v0,1 ; Will now be 0 if this is Space Port
    beq v0,$zero,@@set_mission_complete
    subi v1,1 ; Will now be 0 if already on part 2 of the stage
    beq v1,$zero,@@set_mission_complete
    li v1,1
    sb v1,STAGE_PART
    j 0x80020348
    li v0,4 ; Game state 4 loads a stage. Existing code sets v0 to the game state after 0x80020348
@@set_mission_complete:
    j 0x80020348
    li v0,9
endreplace @stage_end

; Always keep refight capsules enabled.
@capsules_enabled:
replace 0x800C78DC
    li v0,2 ; Exit. Faking out the refight capsules as being in disabled state.
endreplace @capsules_enabled
replace 0x8008026C
    sb $zero,0x21EC(at) ; Dragoon
endreplace @capsules_enabled
replace 0x800758C8
    sb $zero,0x21EC(at) ; Owl
endreplace @capsules_enabled
replace 0x80072894
    sb $zero,0x21EC(at) ; Walrus
endreplace @capsules_enabled
replace 0x8006C244
    sb $zero,0x21EC(at) ; Beast
endreplace @capsules_enabled
replace 0x80079078
    sb $zero,0x21EC(at) ; Mushroom
endreplace @capsules_enabled
replace 0x800720E8
    sb $zero,0x21EC(at) ; Stingray
endreplace @capsules_enabled
replace 0x8007DBA8
    sb $zero,0x21EC(at) ; Peacock
endreplace @capsules_enabled
replace 0x80065504
    sb $zero,0x21EC(at) ; Spider
endreplace @capsules_enabled

; Move player's return position after a refight to not re-teleport back into the fight.
; All are offset by 10 pixels in the appropriate direction.
@capsule_respawn_positions:
replace 0x800F3DA0
    db 0x52 ; Exit
endreplace @capsule_respawn_positions
replace 0x800F3F08
    db 0x26 ; Dragoon
endreplace @capsule_respawn_positions
replace 0x800F3F98
    db 0xE6 ; Owl
endreplace @capsule_respawn_positions
replace 0x800F4004
    db 0xA6 ; Walrus
endreplace @capsule_respawn_positions
replace 0x800F3FE0
    db 0x86 ; Beast
endreplace @capsule_respawn_positions
replace 0x800F3F50
    db 0x0A ; Mushroom
endreplace @capsule_respawn_positions
replace 0x800F3F74
    db 0xEA ; Stingray
endreplace @capsule_respawn_positions
replace 0x800F3F2C
    db 0xAA ; Peacock
endreplace @capsule_respawn_positions
replace 0x800F3FBC
    db 0x6A ; Spider
endreplace @capsule_respawn_positions

; Infinite lives
@infinite_lives:
replace 0x800202C0
    nop
endreplace @infinite_lives

; Enable Escape option in start menu in all stages.
@escape_option:
replace 0x80017514
    nop ; Don't skip over updating start menu stuff based on current stage
endreplace @escape_option
replace 0x80017568
    nop ; Always draw escape button regardless of if current stage is flagged defeated
endreplace @escape_option
replace 0x8002FF48
    nop ; Nop out branch depending on current stage, which would disable escape option
endreplace @escape_option
replace 0x8002FF64
    nop ; Nop out branch on mav not defeated for this stage, so every mav stage and endgame stages have escape option
endreplace @escape_option
