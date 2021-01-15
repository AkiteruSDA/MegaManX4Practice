.psx

; Hacks for game-wide things

; Store controller inputs in temp ram for access
; as well as blocking game-mappable inputs if holding select
; to avoid annoying item save conflicts
@controller_input:
replace 0x80012370
    j @controller_input
    nop
endreplace @controller_input
    ; a1 contains current controller inputs
    push t0
    lhu t0,CONTROLLER_INPUTS_1
    nop
    sh t0,CONTROLLER_INPUTS_1_PREV
    sh a1,CONTROLLER_INPUTS_1
    andi t0,a1,0x0100
    beq t0,$zero,@@dont_block_inputs ; Check if pressing select
    srl t0,a1,8
    sll t0,t0,8
    or a1,$zero,t0
@@dont_block_inputs:
    pop t0
    ; Overwritten code
    andi v1,a1,0xA000
    j (0x80012370 + 8) ; j instead of jr cause return address is important in the code that executes next
    ori v0,$zero,0xA000
