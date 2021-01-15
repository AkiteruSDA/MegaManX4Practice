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
    push t1
    push t2
    lhu t0,CONTROLLER_INPUTS_1
    nop
    sh t0,CONTROLLER_INPUTS_1_PREV
    sh a1,CONTROLLER_INPUTS_1
    andi t1,a1,0x0100
    beq t1,$zero,@@no_select ; Check if pressing select
    nop
    ; Get new input 1 inputs
    xor t1,t0,a1
    and t1,t1,a1
    lbu t2,INPUT_1_DONT_COUNT
    andi t1,t1,0xFF
    ; Set the new bits on the don't count register
    or t2,t2,t1
    sb t2,INPUT_1_DONT_COUNT
@@no_select:
    ; Get inputs that are no longer being held
    xor t1,t0,a1
    and t1,t1,t0
    lbu t2,INPUT_1_DONT_COUNT
    andi t1,t1,0xFF
    ; Unset the bits for inputs that are no longer being held
    not t1,t1
    and t2,t2,t1
    sb t2,INPUT_1_DONT_COUNT
    ; t2 now contains the inputs not counted. Unset the bits on a1 for uncounted inputs.
    not t2,t2
    and a1,a1,t2
    pop t2
    pop t1
    pop t0
    ; Overwritten code
    andi v1,a1,0xA000
    j (0x80012370 + 8) ; j instead of jr cause return address is important in the code that executes next
    ori v0,$zero,0xA000
