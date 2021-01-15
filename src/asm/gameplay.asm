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
    push t1
    push t2
    push t3
    push t4
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
    lhu v0,CONTROLLER_INPUTS_1
    lhu t2,CONTROLLER_INPUTS_1_PREV
@@check_select_l2:
    li t1,0x0101
    andi t3,v0,0x0101
    andi t4,t2,0x0101
    bgeu t4,t3,@@check_select_r2
    nop
    beq t3,t1,@@select_l2
    nop
@@check_select_r2:
    li t1,0x0102
    andi t3,v0,0x0102
    andi t4,t2,0x0102
    bgeu t4,t3,@@check_select_left
    nop
    beq t3,t1,@@select_r2
    nop
@@check_select_left:
    li t1,0x8100
    andi t3,v0,0x8100
    andi t4,t2,0x8100
    bgeu t4,t3,@@check_select_right
    nop
    beq t3,t1,@@select_left
    nop
@@check_select_right:
    li t1,0x2100
    andi t3,v0,0x2100
    andi t4,t2,0x2100
    bgeu t4,t3,@@check_select_up
    nop
    beq t3,t1,@@select_right
    nop
@@check_select_up:
    li t1,0x1100
    andi t3,v0,0x1100
    andi t4,t2,0x1100
    bgeu t4,t3,@@done
    nop
    beq t3,t1,@@select_up
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
    li t1,1
    sb t1,CHECKPOINT_LOADING
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
    pop t4
    pop t3
    pop t2
    pop t1
    jr ra
    nop

@prevent_stun:
replace 0x800343C0 ; Sets stunned state (0x801418CD) to 2, or not stunned
    j org(@prevent_stun)
    nop
endreplace @prevent_stun
    push t1
    lb t1,CHECKPOINT_LOADING
    nop
    beq t1,$zero,@@not_preventing
    sb $zero,CHECKPOINT_LOADING
    ; When the top bit of HP is set (negative), player becomes stunned.
    ; So unset that bit here.
    lb t1,CURRENT_HP
    nop
    andi t1,t1,0x7F
    sb t1,CURRENT_HP
@@not_preventing:
    pop t1
    ; Overwritten code
    lb v1,2(s0)
    j (0x800343C0 + 8)
    sb v0,5(s0)

; Remove WARNING sirens before bosses.
; This overwrites the subroutine address for starting the siren.
; Also wait until camera stops before spawning bosses.
@warning_remove:
replace 0x8010BE84
    dw org(@warning_remove)
endreplace @warning_remove
    push t0
    push t1
    lw t0,CAM_X_CURR
    nop
    lw t1,CAM_X_PREV
    nop
    bne t0,t1,@@wait_for_camera
    nop
    lw t0,CAM_Y_CURR
    nop
    lw t1,CAM_Y_PREV
    nop
    bne t0,t1,@@wait_for_camera
    nop
    pop t1
    pop t0
    j 0x800BAF04 ; Subroutine addr next in table
    nop
@@wait_for_camera:
    pop t1
    pop t0
    jr ra
    nop

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

; Fix checkpoint 0x03 in Mushroom so player ends up with the correct Y position.
; This adds the correct Y position into a lookup table based on stage and checkpoint IDs,
; where for some reason Mushroom checkpoint 3 had a Y position of 0.
@mushroom_checkpoint_fix:
replace 0x800F8B5E
    dh 0x02CB
endreplace @mushroom_checkpoint_fix

; 0x8003593C sets y position to 0x09CB if the current stage part is not equal to 0.
; This position is not correct for part 2 checkpoint 0, so X dies immediately.
; Add some code to check for Peacock stage, part 2, checkpoint 0.
@peacock_checkpoint_fix:
replace 0x8003593C
    j org(@peacock_checkpoint_fix)
    li v0,0x09CB
endreplace @peacock_checkpoint_fix
    push t0
    push t1
    lb t0,STAGE_PART
    nop
    beq t0,$zero,@@skip
    nop
    lb t0,CURRENT_STAGE
    li t1,STAGE_ID_PEACOCK
    bne t0,t1,@@end
    lb t0,STAGE_PART
    li t1,1
    bne t0,t1,@@end
    nop
    lb t0,CURRENT_CHECKPOINT
    nop
    bne t0,$zero,@@end
    nop
    li v0,0x03CB ; The correct Y position for this checkpoint
@@end:
    pop t1
    pop t0
    j 0x800359A0 ; Where the game was conditionally branching in the replaced code
    nop
@@skip:
    ; Since the original code was a BNE this accounts for the false case
    pop t1
    pop t0
    j (0x8003593C + 8)
    nop
