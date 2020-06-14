    .psx

    ; Go to stage select after character select.
	.org 0x8002E4D0
	lw r2,0x3A4(r1)

    ; Automatically scroll camera down on stage select.
    .org 0x8002E7E0
    nop ; nop is 4 bytes in MIPS

    ; Skip maverick intros.
    .org 0x8002EED8
    nop
