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
    j @stage_end
    nop
@@set_mission_complete:
    j 0x80020348
    li v0,9
endreplace @stage_end
    ; I can't remember how much space left I have above to overwrite more existing code,
    ; so I'll just jump to my own space on going to part 2 of a stage for now.
    push t1
    push ra
    jal store_upgrades
    sb $zero,CHECKPOINT_STORAGE
    sb $zero,WEAPON_STORAGE
    pop ra
    pop t1
    j 0x80020348
    li v0,4 ; Game state 4 loads a stage. Existing code sets v0 to the game state after 0x80020348

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
    lbu a1,CHECKPOINT_STORAGE
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
    nop
    ; If ready to load checkpoint, just do that.
    lb t1,CHECKPOINT_LOAD_READY
    nop
    bne $zero,t1,@@checkpoint_loading
    nop
    ; If not pressing select already, don't do anything. (0x0100 on prev)
    andi v0,v0,0x0100
    subi v0,v0,0x0100
    bne v0,$zero,@@done
    lhu v0,INPUT_1_NEW
    nop
    andi t2,v0,0x0001
    li t1,0x0001
    beq t2,t1,@@select_l2
    andi t2,v0,0x0002
    li t1,0x0002
    beq t2,t1,@@select_r2
    andi t2,v0,0x8000
    li t1,0x8000
    beq t2,t1,@@select_left
    andi t2,v0,0x2000
    li t1,0x2000
    beq t2,t1,@@select_right
    andi t2,v0,0x1000
    li t1,0x1000
    beq t2,t1,@@select_up
    nop
    j @@done
    nop
@@select_l2:
    li t1,1
    sb t1,CHECKPOINT_LOAD_READY
    push ra
    jal load_upgrades
    nop
    jal refill_all
    nop
    lb t2,CHECKPOINT_STORAGE
    pop ra
    sb t2,CURRENT_CHECKPOINT
    j @@done
    nop
@@select_r2:
    push ra
    jal store_upgrades
    nop
    pop ra
    push a0
    push a1
    push a2
    push ra
    li a0,0
    li a1,MENU_SELECT_SOUND_ID
    jal PLAY_SOUND_SUB
    li a2,0
    pop ra
    pop a2
    pop a1
    pop a0
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
    lb t1,CHECKPOINT_STORAGE
    lb t0,lo(org(stage_id_to_num_checkpoints))(t0)
    subi t1,t1,1
    bge t1,$zero,@@finish_select_left
    ; Loop to highest possible checkpoint
    subi t0,t0,1
    addu t1,$zero,t0
@@finish_select_left:
    sb t1,CHECKPOINT_STORAGE
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
    lb t1,CHECKPOINT_STORAGE
    lb t0,lo(org(stage_id_to_num_checkpoints))(t0)
    addiu t1,t1,1
    blt t1,t0,@@finish_select_right
    nop
    li t1,0
@@finish_select_right:
    sb t1,CHECKPOINT_STORAGE
    j @@done
    nop
@@select_up:
    push ra
    jal refill_all
    nop
    pop ra
    j @@done
    nop
@@checkpoint_loading:
    li t1,0x0003
    sh t1,TELEPORT_VALUE_1
    li t1,0x00C0
    ;can't sh here, unaligned?
    sb t1,TELEPORT_VALUE_2
    srl t1,8
    sb t1,(TELEPORT_VALUE_2 + 1)
    sb $zero,CHECKPOINT_LOAD_READY
    ;j @@done
    ;nop
@@done:
    lhu v0,INPUT_1_PREV ; Overwritten code.
    pop t2
    pop t1
    jr ra
    nop

; Remove WARNING sirens before bosses.
; This copies the address from index 2 in a jump table over the address in index 1,
; where index 1 starts the WARNING siren and index 2 spawns the boss.
@warning_remove:
replace 0x8010BE84
    dw 0x800BAF04
endreplace @warning_remove

; Refill HP of Sigma forms on death and keep fight state at 0 (both alive)
@sigma_reset_state:
replace 0x8008F644
    ; Keep the fight state at 0 when one of the forms dies, and refill the HP.
    jal @sigma_reset_state
    nop
endreplace @sigma_reset_state
    ; v0 here is 2 if ground is dying, 1 if gunner is dying
    sb $zero,SIGMA_FIGHT_STATE
    push t0
    push t1
    ; Increment the lifecycle state to keep the logic above working.
    li t0,0x30
    la t1,ONE_BEFORE_SIGMA_HPS
    add t1,t1,v0
    sb t0,0(t1)
    pop t1
    pop t0
    jr ra
    nop

@flag_spawn_which_sigma:
replace 0x8008DBE8
    jal @flag_spawn_which_sigma
    nop
endreplace @flag_spawn_which_sigma
    ; v0 will be 4 here if spawning gunner
    push v1
    li v1,4
    beq v0,v1,@@flag_spawn_ground_next
    nop
    li v1,1
    sb v1,SPAWN_NEXT_SIGMA
    j @@end
    nop
@@flag_spawn_ground_next:
    sb $zero,SPAWN_NEXT_SIGMA
@@end:
    pop v1
    ; Overwritten code
    sb v0,5(s0)
    lbu v0,0x96(s0)
    nop
    jr ra
    nop

@check_spawn_gunner:
replace 0x8008DBC4 ; this runs when deciding whether to spawn gunner or not
    jal @check_spawn_gunner
    nop
    nop
    nop
endreplace @check_spawn_gunner
    lb v1,SPAWN_NEXT_SIGMA
    li v0,1
    beq v1,v0,@@spawn_gunner_trampoline
    nop
    jr ra
    nop
@@spawn_gunner_trampoline:
    j 0x8008DBE4
    li v0,2

@check_spawn_ground:
replace 0x8008DB6C ; this runs when deciding whether to spawn ground or not
    jal @check_spawn_ground
    nop
    nop
    nop
endreplace @check_spawn_ground
    lb v1,SPAWN_NEXT_SIGMA
    nop
    beq v1,$zero,@@spawn_ground_trampoline
    nop
    jr ra
    nop
@@spawn_ground_trampoline:
    j 0x8008DBE8
    li v0,6

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
