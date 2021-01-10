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

; Show current checkpoint under health bar instead of lives.
@show_checkpoint:
replace 0x80024EA8
    lbu a1,CURRENT_CHECKPOINT
endreplace @show_checkpoint

; Select+INPUT hacks
@select_hacks:
replace 0x8001247C ; this only runs when the screen isn't fading out
    jal @select_hacks
    nop ; there's an lhu here, nopping out second part of 2-instruction
endreplace @select_hacks
    lhu v0,INPUT_1_PREV
    push t1
    push t2
    ; If not in a gameplay state, don't do anything. (0x0006 halfword)
    lhu t1,GAME_STATE_1
    nop
    subi t1,t1,0x0006
    bne t1,$zero,@@done
    ; If not pressing select already, don't do anything. (0x0100 on prev)
    andi v0,v0,0x0100
    subi v0,v0,0x0100
    bne v0,$zero,@@done
    lhu v0,INPUT_1_NEW
    nop
    andi t2,v0,0x0001
    li t1,0x0001
    beq t2,t1,@@select_l2
    andi t2,v0,0x8000
    li t1,0x8000
    beq t2,t1,@@select_left
    andi t2,v0,0x2000
    li t1,0x2000
    beq t2,t1,@@select_right
    nop
    j @@done
    nop
@@select_l2:
    li t1,0x0003
    sh t1,TELEPORT_VALUE_1
    li t1,0x00C0
    ; can't sh here, unaligned?
    sb t1,TELEPORT_VALUE_2
    srl t1,8
    sb t1,(TELEPORT_VALUE_2 + 1)
    j @@done
    nop
@@select_left:
    lb t1,CURRENT_STAGE
    lui t0,hi(org(stage_id_to_num_checkpoints))
    sll t1,t1,1
    addu t0,t0,t1
    lb t1,STAGE_PART
    nop
    addu t0,t0,t1
    lb t1,CURRENT_CHECKPOINT
    lb t0,lo(org(stage_id_to_num_checkpoints))(t0)
    subi t1,t1,1
    bge t1,$zero,@@finish_select_left
    ; Loop to highest possible checkpoint
    subi t0,t0,1
    addu t1,$zero,t0
@@finish_select_left:
    sb t1,CURRENT_CHECKPOINT
    j @@done
    nop
@@select_right:
    lb t1,CURRENT_STAGE
    lui t0,hi(org(stage_id_to_num_checkpoints))
    sll t1,t1,1
    addu t0,t0,t1
    lb t1,STAGE_PART
    nop
    addu t0,t0,t1
    lb t1,CURRENT_CHECKPOINT
    lb t0,lo(org(stage_id_to_num_checkpoints))(t0)
    addiu t1,t1,1
    blt t1,t0,@@finish_select_right
    nop
    li t1,0
@@finish_select_right:
    sb t1,CURRENT_CHECKPOINT
    j @@done
    nop
@@done:
    lhu v0,INPUT_1_PREV ; Overwritten code.
    pop t2
    pop t1
    jr ra
    nop

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
