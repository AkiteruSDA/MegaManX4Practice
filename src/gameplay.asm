.psx

; Always enable the exit capsule in refights.
@exit_capsule:
replace 0x800C78DC
    li v0,2 ; faking out the refight capsules as being in defeated state
endreplace @exit_capsule
