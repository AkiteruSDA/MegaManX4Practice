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
