.psx

; Reusable subroutines to do desirable things.

; Refill your hp, tanks, and weapon energies.
; Uses:
; - t1
refill_all:
    ; Fill sub tanks and weapon tank
    li t1,0x20
    sb t1,WEP_HP
    addi t1,t1,0xA080
    sh t1,SUB_HP_1 ; Filling both sub tanks at once
    ; Fill all weapon energy
    lui t1,0x3030
    addiu t1,t1,0x3030
    sw t1,WEAPON_ENERGIES
    sw t1,(WEAPON_ENERGIES + 4)
    sw t1,(WEAPON_ENERGIES + 8)
    lb t1,MAX_HP
    nop
    sb t1,CURRENT_HP
    jr ra
    nop

; Stores your current upgrades in temporary memory.
; Uses:
; - t1
store_upgrades:
    lh t1,HEARTS_OBTAINED
    nop
    sh t1,HEARTS_STORAGE
    lb t1,ARMOR_OBTAINED
    nop
    sb t1,ARMOR_STORAGE
    jr ra
    nop

; Loads upgrades from temporary memory, and sets Max HP based on hearts.
; Uses:
; - t1
; - t2
; - t3
load_upgrades:
    lh t1,HEARTS_STORAGE
    lb t2,ARMOR_STORAGE
    sh t1,HEARTS_OBTAINED
    sb t2,ARMOR_OBTAINED
    lbu t2,HEARTS_OBTAINED
    li t1,0x20
@@max_hp_loop:
    andi t3,t2,1
    sll t3,t3,1
    add t1,t1,t3
    bne t2,$zero,@@max_hp_loop
    srl t2,t2,1
    sb t1,MAX_HP
    jr ra
    nop
