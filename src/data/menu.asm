.psx

.open "../build/ARC/MOJIPAT_VANILLA.ARC", "../build/ARC/MOJIPAT.ARC", 0

; Read 0 characters for Mission Completed "SAVE" option
@save_chars:
replace 0xB8
    db 0x00
endreplace @save_chars

; Read 8 characters for Mission Completed "CONTINUE WITHOUT SAVING" option
@continue_chars:
replace 0xBC
    db 0x08
endreplace @continue_chars

.close

.open "../build/ARC/ST0E_U0_VANILLA.ARC", "../build/ARC/ST0E_U0.ARC", 0

; Read 0 characters for title screen "CONTINUE" option
@continue_chars_title:
replace 0x14074
    db 0x00
endreplace @continue_chars_title

.close
