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

; Maps stage IDs to items obtained in that stage. Each has 4 bytes, 2 bytes per part of the stage.
; Least significant byte is hearts, most significant byte is tanks and X armor (least significant bits are armor, most significant are tanks)
stage_id_to_item_table:
    dh 0b0000100000000000 ; Spider, part 1 (boots)
    dh 0b0000000000000001 ; Spider, part 2 (heart)
    dh 0b1000000000000010 ; Walrus, part 1 (heart, ex tank)
    dh 0b0100000000000000 ; Walrus, part 2 (weapon tank)
    dh 0b0000000000000000 ; Mushroom, part 1 (nothing)
    dh 0b0000000000000100 ; Mushroom, part 2 (heart)
    dh 0b0000000000000000 ; Dragoon, part 1 (nothing)
    dh 0b0000001000001000 ; Dragoon, part 2 (heart, body)
    dh 0b0000000000010000 ; Stingray, part 1 (heart)
    dh 0b0010000000000000 ; Stingray, part 2 (sub tank)
    dh 0b0001000100100000 ; Peacock, part 1 (heart, sub tank, helmet)
    dh 0b0000000000000000 ; Peacock, area 2 (nothing)
    dh 0b0000000001000000 ; Owl, part 1 (heart)
    dh 0b0000010000000000 ; Owl, part 2 (buster)
    dh 0b0000000000000000 ; Beast, part 1 (nothing)
    dh 0b0000000010000000 ; Beast, part 2 (heart)
    dh 0x0000 ; Padding for alignment

; NOT (STAGE ID - 1) LIKE THE OTHERS SINCE IT INCLUDES MORE THAN JUST MAVS, One byte per part
stage_id_to_num_checkpoints:
    dh 0x0303 ; 0, Intro
    dh 0x0605 ; 1, Spider
    dh 0x0405 ; 2, Walrus
    dh 0x0404 ; 3, Mushroom
    dh 0x0402 ; 4, Dragoon
    dh 0x0201 ; 5, Stingray
    dh 0x0206 ; 6, Peacock
    dh 0x0403 ; 7, Owl
    dh 0x0403 ; 8, Beast
    dh 0x0001 ; 9, Colonel fight (X only)
    dh 0x0003 ; 10, Space Port
    dh 0x0302 ; 11, Final Weapon 1
    dh 0x010B ; 12, Final Weapon 2
