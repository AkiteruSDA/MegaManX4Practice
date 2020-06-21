.psx

; Maps maverick stage IDs (minus one) to alternate stages and parts for when holding R1 on stage select.
stage_id_to_alt_stage_table:
    dh 0x0000 ; Spider   -> Intro stage, part 1
    dh 0x010C ; Walrus   -> Final Weapon 2, part 2
    dh 0x010B ; Mushroom -> Final Weapon 1, part 2
    dh 0x000A ; Dragoon  -> Space Port
    dh 0x000B ; Stingray -> Final Weapon 1, part 1
    dh 0x0100 ; Peacock  -> Intro stage, part 2
    dh 0x0009 ; Owl      -> Colonel fight (X only)
    dh 0x000C ; Beast    -> Final Weapon 2, part 1
