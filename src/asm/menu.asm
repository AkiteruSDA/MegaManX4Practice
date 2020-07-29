.psx

; Set initial option to 1 in Mission Completed
@initial_option:
replace 0x80020B34
    lui t1,0x8014
    li t2,1
endreplace @initial_option
replace 0x80020B4C
    sb t2,0x1BDF(t1)
endreplace @initial_option

; Wrap around bottom to option 1 in Mission Completed
@bottom_wrap:
replace 0x80020558
    j @bottom_wrap
    nop
endreplace @bottom_wrap
    lb t0,GAME_STATE_1
    nop
    seq t0,t0,9 ; If game state is 9 (mission completed), will be option 1. Otherwise, will be 0.
    j 0x80020568
    sb t0,0(s0)

; Wrap around top from option 1 to option 2 in Mission Completed
@top_wrap:
replace 0x8002050C
    j @top_wrap
    nop
endreplace @top_wrap
    lb t0,GAME_STATE_1
    nop
    seq t0,t0,9 ; If game state is 9 (mission completed), will be option 1. Otherwise, will be 0.
    bne v0,t0,@@not_top
    addu v1,v0,$zero ; overwritten code
    j 0x80020514
    nop
@@not_top:
    j 0x8002051C
    nop
