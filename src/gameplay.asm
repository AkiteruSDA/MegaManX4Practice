.psx

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

; Hacks for when a stage is finished.
@after_stage:
; Maverick stages
replace 0x80020128
    li v0,0xFF ; Fake out all mavericks defeated
endreplace @after_stage
replace 0x8002013C
    li v0,3 ; Go to game state 3 (stage select) instead of 9 (mission complete)
endreplace @after_stage
; Intro stage
replace 0x800201AC
    li v0,3 ; Load 3 instead of 9 for game state
endreplace @after_stage
replace 0x8002E790
    li v0,2 ; Game State 2 should be 2 instead of 9 for stage select or else spaceport will open
endreplace @after_stage
; Colonel stage as Zero (and also not as zero??)
replace 0x8002EE9C
    li v0,3 ; Stage select instead of mission complete
endreplace @after_stage
; Space Port
replace 0x800201F4
    li v0,0 ; Set stage select state to 0 instead of 7, which is standard vs. final weapon
endreplace @after_stage
; Final Weapon 1-2
replace 0x80020208
    li v0,0 ; Set stage select state to 0 instead of A, which is standard vs. final weapon 2
endreplace @after_stage
; Final Weapon 2-2
replace 0x800201B4
    li v0,3 ; Game state 3 instead of B, which is ending FMV
endreplace @after_stage

; TEMP: INFINITE HP
@infinite_hp:
replace 0x8002DC18
    nop
endreplace @infinite_hp
