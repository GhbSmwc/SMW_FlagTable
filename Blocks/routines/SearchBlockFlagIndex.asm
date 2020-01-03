;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Functions to make it easy to to list the coordinates into $C800 index.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function GetC800IndexHorizLvl(RAM13D7, XPos, YPos) = (RAM13D7*(XPos/16))+(YPos*16)+(XPos%16)
function GetC800IndexVertiLvl(XPos, YPos) = (512*(YPos/16))+(256*(XPos/16))+((YPos%16)*16)+(XPos%16)
;Make sure you have [math round on] to prevent unexpected rounded numbers.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This routine takes the current block $C800 index (first convert its XY coordinate into $C800 index)
;compares it to a list of $C800 indexes determine what flag number the block is assigned to.
;
;The reason of having a list of indexes instead of XY coordinates is because each XY coordinate takes up a total of 4
;bytes (2 bytes for each axis, X and Y) per flag, while $C800_index takes only 2 bytes per flag.
;
;Input:
;-$00-$01: The $C800 index (Execute [BlkCoords2C800Index.asm] subroutine first)
;-[$010B|!addr] to [$010C|!addr]: Current level number. No need to write on this since it is pre-written.
;
;Output:
;-A (16-bit): the flag number, times 2 (so if it is flag 3, then A = $0006). With 16 (maximum) group-256s, A would range
; from 0 to 4094 ($0000 to $0FFE).
; Recommended to add a check X=$FFFE as a failsafe in case of a bug could happen or if you accidentally placed a block
; at a location that isn't assigned.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	PHX							;>This is needed if you are going to have sprites interacting with this block.
	PHB							;>Preserve bank
	PHK							;\Adjust bank for any $xxxx,y
	PLB							;/
	REP #$30						;>16-bit XY, thankfully, with the number of group-128 at max, not even close to 32768 ($8000) on the index for flag number.
	LDX.w #(?GetFlagNumberC800IndexEnd-?GetFlagNumberC800IndexStart)-2 ;>Start at the last index.
	LDY.w #((?GetFlagNumberC800IndexEnd-?GetFlagNumberC800IndexStart)/2)-1
	-
	LDA $010B|!addr						;>Current level number
	CMP.l ?GetFlagNumberLevelIndexStart,x			;\If level number not match, next
	BNE ++							;/
	SEP #$20
	LDA $1933|!addr						;\If layer 1 or 2 does not match, next
	CMP.w ?GetFlagNumberLayerProcessingStart,y		;|
	REP #$20
	BNE ++							;/
	LDA $00							;\If C800 index number not match, next
	CMP.l ?GetFlagNumberC800IndexStart,x			;/
	BNE ++
	BRA +							;>Match found.
	++
	DEY
	DEX #2							;>Next item.
	BPL -							;>Loop till X=$FFFE (no match found), thankfully, 255*2 = 510 ($01FE) is less than 32768 ($8000).
	+
	TXA							;>Transfer indexCount*2 to A
	SEP #$30
	PLB							;>Restore bank.
	PLX							;>Restore potential sprite index.
	RTL
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;List of level numbers. This is essentially what level the flags are in.
;
;Note: you CAN have duplicate level numbers here if you have multiple flags
;in a single level.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
?GetFlagNumberLevelIndexStart:
	dw $FFFF		;>Flag $0 -> LM's CM16 $0
	dw $FFFF		;>Flag $1 -> LM's CM16 $1
	dw $FFFF		;>Flag $2 -> LM's CM16 $2
	dw $FFFF		;>Flag $3 -> LM's CM16 $3
	dw $FFFF		;>Flag $4 -> LM's CM16 $4
	dw $FFFF		;>Flag $5 -> LM's CM16 $5
	dw $FFFF		;>Flag $6 -> LM's CM16 $6
	dw $FFFF		;>Flag $7 -> LM's CM16 $7
	dw $FFFF		;>Flag $8 -> LM's CM16 $8
	dw $FFFF		;>Flag $9 -> LM's CM16 $9
	dw $FFFF		;>Flag $A -> LM's CM16 $A
	dw $FFFF		;>Flag $B -> LM's CM16 $B
	dw $FFFF		;>Flag $C -> LM's CM16 $C
	dw $FFFF		;>Flag $D -> LM's CM16 $D
	dw $FFFF		;>Flag $E -> LM's CM16 $E
	dw $FFFF		;>Flag $F -> LM's CM16 $F
	dw $FFFF		;>Flag $10 -> LM's CM16 $10
	dw $FFFF		;>Flag $11 -> LM's CM16 $11
	dw $FFFF		;>Flag $12 -> LM's CM16 $12
	dw $FFFF		;>Flag $13 -> LM's CM16 $13
	dw $FFFF		;>Flag $14 -> LM's CM16 $14
	dw $FFFF		;>Flag $15 -> LM's CM16 $15
	dw $FFFF		;>Flag $16 -> LM's CM16 $16
	dw $FFFF		;>Flag $17 -> LM's CM16 $17
	dw $FFFF		;>Flag $18 -> LM's CM16 $18
	dw $FFFF		;>Flag $19 -> LM's CM16 $19
	dw $FFFF		;>Flag $1A -> LM's CM16 $1A
	dw $FFFF		;>Flag $1B -> LM's CM16 $1B
	dw $FFFF		;>Flag $1C -> LM's CM16 $1C
	dw $FFFF		;>Flag $1D -> LM's CM16 $1D
	dw $FFFF		;>Flag $1E -> LM's CM16 $1E
	dw $FFFF		;>Flag $1F -> LM's CM16 $1F
	dw $FFFF		;>Flag $20 -> LM's CM16 $20
	dw $FFFF		;>Flag $21 -> LM's CM16 $21
	dw $FFFF		;>Flag $22 -> LM's CM16 $22
	dw $FFFF		;>Flag $23 -> LM's CM16 $23
	dw $FFFF		;>Flag $24 -> LM's CM16 $24
	dw $FFFF		;>Flag $25 -> LM's CM16 $25
	dw $FFFF		;>Flag $26 -> LM's CM16 $26
	dw $FFFF		;>Flag $27 -> LM's CM16 $27
	dw $FFFF		;>Flag $28 -> LM's CM16 $28
	dw $FFFF		;>Flag $29 -> LM's CM16 $29
	dw $FFFF		;>Flag $2A -> LM's CM16 $2A
	dw $FFFF		;>Flag $2B -> LM's CM16 $2B
	dw $FFFF		;>Flag $2C -> LM's CM16 $2C
	dw $FFFF		;>Flag $2D -> LM's CM16 $2D
	dw $FFFF		;>Flag $2E -> LM's CM16 $2E
	dw $FFFF		;>Flag $2F -> LM's CM16 $2F
	dw $FFFF		;>Flag $30 -> LM's CM16 $30
	dw $FFFF		;>Flag $31 -> LM's CM16 $31
	dw $FFFF		;>Flag $32 -> LM's CM16 $32
	dw $FFFF		;>Flag $33 -> LM's CM16 $33
	dw $FFFF		;>Flag $34 -> LM's CM16 $34
	dw $FFFF		;>Flag $35 -> LM's CM16 $35
	dw $FFFF		;>Flag $36 -> LM's CM16 $36
	dw $FFFF		;>Flag $37 -> LM's CM16 $37
	dw $FFFF		;>Flag $38 -> LM's CM16 $38
	dw $FFFF		;>Flag $39 -> LM's CM16 $39
	dw $FFFF		;>Flag $3A -> LM's CM16 $3A
	dw $FFFF		;>Flag $3B -> LM's CM16 $3B
	dw $FFFF		;>Flag $3C -> LM's CM16 $3C
	dw $FFFF		;>Flag $3D -> LM's CM16 $3D
	dw $FFFF		;>Flag $3E -> LM's CM16 $3E
	dw $FFFF		;>Flag $3F -> LM's CM16 $3F
	dw $FFFF		;>Flag $40 -> LM's CM16 $40
	dw $FFFF		;>Flag $41 -> LM's CM16 $41
	dw $FFFF		;>Flag $42 -> LM's CM16 $42
	dw $FFFF		;>Flag $43 -> LM's CM16 $43
	dw $FFFF		;>Flag $44 -> LM's CM16 $44
	dw $FFFF		;>Flag $45 -> LM's CM16 $45
	dw $FFFF		;>Flag $46 -> LM's CM16 $46
	dw $FFFF		;>Flag $47 -> LM's CM16 $47
	dw $FFFF		;>Flag $48 -> LM's CM16 $48
	dw $FFFF		;>Flag $49 -> LM's CM16 $49
	dw $FFFF		;>Flag $4A -> LM's CM16 $4A
	dw $FFFF		;>Flag $4B -> LM's CM16 $4B
	dw $FFFF		;>Flag $4C -> LM's CM16 $4C
	dw $FFFF		;>Flag $4D -> LM's CM16 $4D
	dw $FFFF		;>Flag $4E -> LM's CM16 $4E
	dw $FFFF		;>Flag $4F -> LM's CM16 $4F
	dw $FFFF		;>Flag $50 -> LM's CM16 $50
	dw $FFFF		;>Flag $51 -> LM's CM16 $51
	dw $FFFF		;>Flag $52 -> LM's CM16 $52
	dw $FFFF		;>Flag $53 -> LM's CM16 $53
	dw $FFFF		;>Flag $54 -> LM's CM16 $54
	dw $FFFF		;>Flag $55 -> LM's CM16 $55
	dw $FFFF		;>Flag $56 -> LM's CM16 $56
	dw $FFFF		;>Flag $57 -> LM's CM16 $57
	dw $FFFF		;>Flag $58 -> LM's CM16 $58
	dw $FFFF		;>Flag $59 -> LM's CM16 $59
	dw $FFFF		;>Flag $5A -> LM's CM16 $5A
	dw $FFFF		;>Flag $5B -> LM's CM16 $5B
	dw $FFFF		;>Flag $5C -> LM's CM16 $5C
	dw $FFFF		;>Flag $5D -> LM's CM16 $5D
	dw $FFFF		;>Flag $5E -> LM's CM16 $5E
	dw $FFFF		;>Flag $5F -> LM's CM16 $5F
	dw $FFFF		;>Flag $60 -> LM's CM16 $60
	dw $FFFF		;>Flag $61 -> LM's CM16 $61
	dw $FFFF		;>Flag $62 -> LM's CM16 $62
	dw $FFFF		;>Flag $63 -> LM's CM16 $63
	dw $FFFF		;>Flag $64 -> LM's CM16 $64
	dw $FFFF		;>Flag $65 -> LM's CM16 $65
	dw $FFFF		;>Flag $66 -> LM's CM16 $66
	dw $FFFF		;>Flag $67 -> LM's CM16 $67
	dw $FFFF		;>Flag $68 -> LM's CM16 $68
	dw $FFFF		;>Flag $69 -> LM's CM16 $69
	dw $FFFF		;>Flag $6A -> LM's CM16 $6A
	dw $FFFF		;>Flag $6B -> LM's CM16 $6B
	dw $FFFF		;>Flag $6C -> LM's CM16 $6C
	dw $FFFF		;>Flag $6D -> LM's CM16 $6D
	dw $FFFF		;>Flag $6E -> LM's CM16 $6E
	dw $FFFF		;>Flag $6F -> LM's CM16 $6F
	dw $FFFF		;>Flag $70 -> LM's CM16 $70
	dw $FFFF		;>Flag $71 -> LM's CM16 $71
	dw $FFFF		;>Flag $72 -> LM's CM16 $72
	dw $FFFF		;>Flag $73 -> LM's CM16 $73
	dw $FFFF		;>Flag $74 -> LM's CM16 $74
	dw $FFFF		;>Flag $75 -> LM's CM16 $75
	dw $FFFF		;>Flag $76 -> LM's CM16 $76
	dw $FFFF		;>Flag $77 -> LM's CM16 $77
	dw $FFFF		;>Flag $78 -> LM's CM16 $78
	dw $FFFF		;>Flag $79 -> LM's CM16 $79
	dw $FFFF		;>Flag $7A -> LM's CM16 $7A
	dw $FFFF		;>Flag $7B -> LM's CM16 $7B
	dw $FFFF		;>Flag $7C -> LM's CM16 $7C
	dw $FFFF		;>Flag $7D -> LM's CM16 $7D
	dw $FFFF		;>Flag $7E -> LM's CM16 $7E
	dw $FFFF		;>Flag $7F -> LM's CM16 $7F
	dw $FFFF		;>Flag $80 -> LM's CM16 $0
	dw $FFFF		;>Flag $81 -> LM's CM16 $1
	dw $FFFF		;>Flag $82 -> LM's CM16 $2
	dw $FFFF		;>Flag $83 -> LM's CM16 $3
	dw $FFFF		;>Flag $84 -> LM's CM16 $4
	dw $FFFF		;>Flag $85 -> LM's CM16 $5
	dw $FFFF		;>Flag $86 -> LM's CM16 $6
	dw $FFFF		;>Flag $87 -> LM's CM16 $7
	dw $FFFF		;>Flag $88 -> LM's CM16 $8
	dw $FFFF		;>Flag $89 -> LM's CM16 $9
	dw $FFFF		;>Flag $8A -> LM's CM16 $A
	dw $FFFF		;>Flag $8B -> LM's CM16 $B
	dw $FFFF		;>Flag $8C -> LM's CM16 $C
	dw $FFFF		;>Flag $8D -> LM's CM16 $D
	dw $FFFF		;>Flag $8E -> LM's CM16 $E
	dw $FFFF		;>Flag $8F -> LM's CM16 $F
	dw $FFFF		;>Flag $90 -> LM's CM16 $10
	dw $FFFF		;>Flag $91 -> LM's CM16 $11
	dw $FFFF		;>Flag $92 -> LM's CM16 $12
	dw $FFFF		;>Flag $93 -> LM's CM16 $13
	dw $FFFF		;>Flag $94 -> LM's CM16 $14
	dw $FFFF		;>Flag $95 -> LM's CM16 $15
	dw $FFFF		;>Flag $96 -> LM's CM16 $16
	dw $FFFF		;>Flag $97 -> LM's CM16 $17
	dw $FFFF		;>Flag $98 -> LM's CM16 $18
	dw $FFFF		;>Flag $99 -> LM's CM16 $19
	dw $FFFF		;>Flag $9A -> LM's CM16 $1A
	dw $FFFF		;>Flag $9B -> LM's CM16 $1B
	dw $FFFF		;>Flag $9C -> LM's CM16 $1C
	dw $FFFF		;>Flag $9D -> LM's CM16 $1D
	dw $FFFF		;>Flag $9E -> LM's CM16 $1E
	dw $FFFF		;>Flag $9F -> LM's CM16 $1F
	dw $FFFF		;>Flag $A0 -> LM's CM16 $20
	dw $FFFF		;>Flag $A1 -> LM's CM16 $21
	dw $FFFF		;>Flag $A2 -> LM's CM16 $22
	dw $FFFF		;>Flag $A3 -> LM's CM16 $23
	dw $FFFF		;>Flag $A4 -> LM's CM16 $24
	dw $FFFF		;>Flag $A5 -> LM's CM16 $25
	dw $FFFF		;>Flag $A6 -> LM's CM16 $26
	dw $FFFF		;>Flag $A7 -> LM's CM16 $27
	dw $FFFF		;>Flag $A8 -> LM's CM16 $28
	dw $FFFF		;>Flag $A9 -> LM's CM16 $29
	dw $FFFF		;>Flag $AA -> LM's CM16 $2A
	dw $FFFF		;>Flag $AB -> LM's CM16 $2B
	dw $FFFF		;>Flag $AC -> LM's CM16 $2C
	dw $FFFF		;>Flag $AD -> LM's CM16 $2D
	dw $FFFF		;>Flag $AE -> LM's CM16 $2E
	dw $FFFF		;>Flag $AF -> LM's CM16 $2F
	dw $FFFF		;>Flag $B0 -> LM's CM16 $30
	dw $FFFF		;>Flag $B1 -> LM's CM16 $31
	dw $FFFF		;>Flag $B2 -> LM's CM16 $32
	dw $FFFF		;>Flag $B3 -> LM's CM16 $33
	dw $FFFF		;>Flag $B4 -> LM's CM16 $34
	dw $FFFF		;>Flag $B5 -> LM's CM16 $35
	dw $FFFF		;>Flag $B6 -> LM's CM16 $36
	dw $FFFF		;>Flag $B7 -> LM's CM16 $37
	dw $FFFF		;>Flag $B8 -> LM's CM16 $38
	dw $FFFF		;>Flag $B9 -> LM's CM16 $39
	dw $FFFF		;>Flag $BA -> LM's CM16 $3A
	dw $FFFF		;>Flag $BB -> LM's CM16 $3B
	dw $FFFF		;>Flag $BC -> LM's CM16 $3C
	dw $FFFF		;>Flag $BD -> LM's CM16 $3D
	dw $FFFF		;>Flag $BE -> LM's CM16 $3E
	dw $FFFF		;>Flag $BF -> LM's CM16 $3F
	dw $FFFF		;>Flag $C0 -> LM's CM16 $40
	dw $FFFF		;>Flag $C1 -> LM's CM16 $41
	dw $FFFF		;>Flag $C2 -> LM's CM16 $42
	dw $FFFF		;>Flag $C3 -> LM's CM16 $43
	dw $FFFF		;>Flag $C4 -> LM's CM16 $44
	dw $FFFF		;>Flag $C5 -> LM's CM16 $45
	dw $FFFF		;>Flag $C6 -> LM's CM16 $46
	dw $FFFF		;>Flag $C7 -> LM's CM16 $47
	dw $FFFF		;>Flag $C8 -> LM's CM16 $48
	dw $FFFF		;>Flag $C9 -> LM's CM16 $49
	dw $FFFF		;>Flag $CA -> LM's CM16 $4A
	dw $FFFF		;>Flag $CB -> LM's CM16 $4B
	dw $FFFF		;>Flag $CC -> LM's CM16 $4C
	dw $FFFF		;>Flag $CD -> LM's CM16 $4D
	dw $FFFF		;>Flag $CE -> LM's CM16 $4E
	dw $FFFF		;>Flag $CF -> LM's CM16 $4F
	dw $FFFF		;>Flag $D0 -> LM's CM16 $50
	dw $FFFF		;>Flag $D1 -> LM's CM16 $51
	dw $FFFF		;>Flag $D2 -> LM's CM16 $52
	dw $FFFF		;>Flag $D3 -> LM's CM16 $53
	dw $FFFF		;>Flag $D4 -> LM's CM16 $54
	dw $FFFF		;>Flag $D5 -> LM's CM16 $55
	dw $FFFF		;>Flag $D6 -> LM's CM16 $56
	dw $FFFF		;>Flag $D7 -> LM's CM16 $57
	dw $FFFF		;>Flag $D8 -> LM's CM16 $58
	dw $FFFF		;>Flag $D9 -> LM's CM16 $59
	dw $FFFF		;>Flag $DA -> LM's CM16 $5A
	dw $FFFF		;>Flag $DB -> LM's CM16 $5B
	dw $FFFF		;>Flag $DC -> LM's CM16 $5C
	dw $FFFF		;>Flag $DD -> LM's CM16 $5D
	dw $FFFF		;>Flag $DE -> LM's CM16 $5E
	dw $FFFF		;>Flag $DF -> LM's CM16 $5F
	dw $FFFF		;>Flag $E0 -> LM's CM16 $60
	dw $FFFF		;>Flag $E1 -> LM's CM16 $61
	dw $FFFF		;>Flag $E2 -> LM's CM16 $62
	dw $FFFF		;>Flag $E3 -> LM's CM16 $63
	dw $FFFF		;>Flag $E4 -> LM's CM16 $64
	dw $FFFF		;>Flag $E5 -> LM's CM16 $65
	dw $FFFF		;>Flag $E6 -> LM's CM16 $66
	dw $FFFF		;>Flag $E7 -> LM's CM16 $67
	dw $FFFF		;>Flag $E8 -> LM's CM16 $68
	dw $FFFF		;>Flag $E9 -> LM's CM16 $69
	dw $FFFF		;>Flag $EA -> LM's CM16 $6A
	dw $FFFF		;>Flag $EB -> LM's CM16 $6B
	dw $FFFF		;>Flag $EC -> LM's CM16 $6C
	dw $FFFF		;>Flag $ED -> LM's CM16 $6D
	dw $FFFF		;>Flag $EE -> LM's CM16 $6E
	dw $FFFF		;>Flag $EF -> LM's CM16 $6F
	dw $FFFF		;>Flag $F0 -> LM's CM16 $70
	dw $FFFF		;>Flag $F1 -> LM's CM16 $71
	dw $FFFF		;>Flag $F2 -> LM's CM16 $72
	dw $FFFF		;>Flag $F3 -> LM's CM16 $73
	dw $FFFF		;>Flag $F4 -> LM's CM16 $74
	dw $FFFF		;>Flag $F5 -> LM's CM16 $75
	dw $FFFF		;>Flag $F6 -> LM's CM16 $76
	dw $FFFF		;>Flag $F7 -> LM's CM16 $77
	dw $FFFF		;>Flag $F8 -> LM's CM16 $78
	dw $FFFF		;>Flag $F9 -> LM's CM16 $79
	dw $FFFF		;>Flag $FA -> LM's CM16 $7A
	dw $FFFF		;>Flag $FB -> LM's CM16 $7B
	dw $FFFF		;>Flag $FC -> LM's CM16 $7C
	dw $FFFF		;>Flag $FD -> LM's CM16 $7D
	dw $FFFF		;>Flag $FE -> LM's CM16 $7E
	dw $FFFF		;>Flag $FF -> LM's CM16 $7F
?GetFlagNumberLevelIndexEnd:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;List of what layer the flag is on. Put "$01" for layer 2 blocks if you
;are using a layer 2 level and have that flagged block on that layer, otherwise put "$00" instead.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
?GetFlagNumberLayerProcessingStart:
	db $00		;>Flag $0 -> LM's CM16 $0
	db $00		;>Flag $1 -> LM's CM16 $1
	db $00		;>Flag $2 -> LM's CM16 $2
	db $00		;>Flag $3 -> LM's CM16 $3
	db $00		;>Flag $4 -> LM's CM16 $4
	db $00		;>Flag $5 -> LM's CM16 $5
	db $00		;>Flag $6 -> LM's CM16 $6
	db $00		;>Flag $7 -> LM's CM16 $7
	db $00		;>Flag $8 -> LM's CM16 $8
	db $00		;>Flag $9 -> LM's CM16 $9
	db $00		;>Flag $A -> LM's CM16 $A
	db $00		;>Flag $B -> LM's CM16 $B
	db $00		;>Flag $C -> LM's CM16 $C
	db $00		;>Flag $D -> LM's CM16 $D
	db $00		;>Flag $E -> LM's CM16 $E
	db $00		;>Flag $F -> LM's CM16 $F
	db $00		;>Flag $10 -> LM's CM16 $10
	db $00		;>Flag $11 -> LM's CM16 $11
	db $00		;>Flag $12 -> LM's CM16 $12
	db $00		;>Flag $13 -> LM's CM16 $13
	db $00		;>Flag $14 -> LM's CM16 $14
	db $00		;>Flag $15 -> LM's CM16 $15
	db $00		;>Flag $16 -> LM's CM16 $16
	db $00		;>Flag $17 -> LM's CM16 $17
	db $00		;>Flag $18 -> LM's CM16 $18
	db $00		;>Flag $19 -> LM's CM16 $19
	db $00		;>Flag $1A -> LM's CM16 $1A
	db $00		;>Flag $1B -> LM's CM16 $1B
	db $00		;>Flag $1C -> LM's CM16 $1C
	db $00		;>Flag $1D -> LM's CM16 $1D
	db $00		;>Flag $1E -> LM's CM16 $1E
	db $00		;>Flag $1F -> LM's CM16 $1F
	db $00		;>Flag $20 -> LM's CM16 $20
	db $00		;>Flag $21 -> LM's CM16 $21
	db $00		;>Flag $22 -> LM's CM16 $22
	db $00		;>Flag $23 -> LM's CM16 $23
	db $00		;>Flag $24 -> LM's CM16 $24
	db $00		;>Flag $25 -> LM's CM16 $25
	db $00		;>Flag $26 -> LM's CM16 $26
	db $00		;>Flag $27 -> LM's CM16 $27
	db $00		;>Flag $28 -> LM's CM16 $28
	db $00		;>Flag $29 -> LM's CM16 $29
	db $00		;>Flag $2A -> LM's CM16 $2A
	db $00		;>Flag $2B -> LM's CM16 $2B
	db $00		;>Flag $2C -> LM's CM16 $2C
	db $00		;>Flag $2D -> LM's CM16 $2D
	db $00		;>Flag $2E -> LM's CM16 $2E
	db $00		;>Flag $2F -> LM's CM16 $2F
	db $00		;>Flag $30 -> LM's CM16 $30
	db $00		;>Flag $31 -> LM's CM16 $31
	db $00		;>Flag $32 -> LM's CM16 $32
	db $00		;>Flag $33 -> LM's CM16 $33
	db $00		;>Flag $34 -> LM's CM16 $34
	db $00		;>Flag $35 -> LM's CM16 $35
	db $00		;>Flag $36 -> LM's CM16 $36
	db $00		;>Flag $37 -> LM's CM16 $37
	db $00		;>Flag $38 -> LM's CM16 $38
	db $00		;>Flag $39 -> LM's CM16 $39
	db $00		;>Flag $3A -> LM's CM16 $3A
	db $00		;>Flag $3B -> LM's CM16 $3B
	db $00		;>Flag $3C -> LM's CM16 $3C
	db $00		;>Flag $3D -> LM's CM16 $3D
	db $00		;>Flag $3E -> LM's CM16 $3E
	db $00		;>Flag $3F -> LM's CM16 $3F
	db $00		;>Flag $40 -> LM's CM16 $40
	db $00		;>Flag $41 -> LM's CM16 $41
	db $00		;>Flag $42 -> LM's CM16 $42
	db $00		;>Flag $43 -> LM's CM16 $43
	db $00		;>Flag $44 -> LM's CM16 $44
	db $00		;>Flag $45 -> LM's CM16 $45
	db $00		;>Flag $46 -> LM's CM16 $46
	db $00		;>Flag $47 -> LM's CM16 $47
	db $00		;>Flag $48 -> LM's CM16 $48
	db $00		;>Flag $49 -> LM's CM16 $49
	db $00		;>Flag $4A -> LM's CM16 $4A
	db $00		;>Flag $4B -> LM's CM16 $4B
	db $00		;>Flag $4C -> LM's CM16 $4C
	db $00		;>Flag $4D -> LM's CM16 $4D
	db $00		;>Flag $4E -> LM's CM16 $4E
	db $00		;>Flag $4F -> LM's CM16 $4F
	db $00		;>Flag $50 -> LM's CM16 $50
	db $00		;>Flag $51 -> LM's CM16 $51
	db $00		;>Flag $52 -> LM's CM16 $52
	db $00		;>Flag $53 -> LM's CM16 $53
	db $00		;>Flag $54 -> LM's CM16 $54
	db $00		;>Flag $55 -> LM's CM16 $55
	db $00		;>Flag $56 -> LM's CM16 $56
	db $00		;>Flag $57 -> LM's CM16 $57
	db $00		;>Flag $58 -> LM's CM16 $58
	db $00		;>Flag $59 -> LM's CM16 $59
	db $00		;>Flag $5A -> LM's CM16 $5A
	db $00		;>Flag $5B -> LM's CM16 $5B
	db $00		;>Flag $5C -> LM's CM16 $5C
	db $00		;>Flag $5D -> LM's CM16 $5D
	db $00		;>Flag $5E -> LM's CM16 $5E
	db $00		;>Flag $5F -> LM's CM16 $5F
	db $00		;>Flag $60 -> LM's CM16 $60
	db $00		;>Flag $61 -> LM's CM16 $61
	db $00		;>Flag $62 -> LM's CM16 $62
	db $00		;>Flag $63 -> LM's CM16 $63
	db $00		;>Flag $64 -> LM's CM16 $64
	db $00		;>Flag $65 -> LM's CM16 $65
	db $00		;>Flag $66 -> LM's CM16 $66
	db $00		;>Flag $67 -> LM's CM16 $67
	db $00		;>Flag $68 -> LM's CM16 $68
	db $00		;>Flag $69 -> LM's CM16 $69
	db $00		;>Flag $6A -> LM's CM16 $6A
	db $00		;>Flag $6B -> LM's CM16 $6B
	db $00		;>Flag $6C -> LM's CM16 $6C
	db $00		;>Flag $6D -> LM's CM16 $6D
	db $00		;>Flag $6E -> LM's CM16 $6E
	db $00		;>Flag $6F -> LM's CM16 $6F
	db $00		;>Flag $70 -> LM's CM16 $70
	db $00		;>Flag $71 -> LM's CM16 $71
	db $00		;>Flag $72 -> LM's CM16 $72
	db $00		;>Flag $73 -> LM's CM16 $73
	db $00		;>Flag $74 -> LM's CM16 $74
	db $00		;>Flag $75 -> LM's CM16 $75
	db $00		;>Flag $76 -> LM's CM16 $76
	db $00		;>Flag $77 -> LM's CM16 $77
	db $00		;>Flag $78 -> LM's CM16 $78
	db $00		;>Flag $79 -> LM's CM16 $79
	db $00		;>Flag $7A -> LM's CM16 $7A
	db $00		;>Flag $7B -> LM's CM16 $7B
	db $00		;>Flag $7C -> LM's CM16 $7C
	db $00		;>Flag $7D -> LM's CM16 $7D
	db $00		;>Flag $7E -> LM's CM16 $7E
	db $00		;>Flag $7F -> LM's CM16 $7F
	db $00		;>Flag $80 -> LM's CM16 $0
	db $00		;>Flag $81 -> LM's CM16 $1
	db $00		;>Flag $82 -> LM's CM16 $2
	db $00		;>Flag $83 -> LM's CM16 $3
	db $00		;>Flag $84 -> LM's CM16 $4
	db $00		;>Flag $85 -> LM's CM16 $5
	db $00		;>Flag $86 -> LM's CM16 $6
	db $00		;>Flag $87 -> LM's CM16 $7
	db $00		;>Flag $88 -> LM's CM16 $8
	db $00		;>Flag $89 -> LM's CM16 $9
	db $00		;>Flag $8A -> LM's CM16 $A
	db $00		;>Flag $8B -> LM's CM16 $B
	db $00		;>Flag $8C -> LM's CM16 $C
	db $00		;>Flag $8D -> LM's CM16 $D
	db $00		;>Flag $8E -> LM's CM16 $E
	db $00		;>Flag $8F -> LM's CM16 $F
	db $00		;>Flag $90 -> LM's CM16 $10
	db $00		;>Flag $91 -> LM's CM16 $11
	db $00		;>Flag $92 -> LM's CM16 $12
	db $00		;>Flag $93 -> LM's CM16 $13
	db $00		;>Flag $94 -> LM's CM16 $14
	db $00		;>Flag $95 -> LM's CM16 $15
	db $00		;>Flag $96 -> LM's CM16 $16
	db $00		;>Flag $97 -> LM's CM16 $17
	db $00		;>Flag $98 -> LM's CM16 $18
	db $00		;>Flag $99 -> LM's CM16 $19
	db $00		;>Flag $9A -> LM's CM16 $1A
	db $00		;>Flag $9B -> LM's CM16 $1B
	db $00		;>Flag $9C -> LM's CM16 $1C
	db $00		;>Flag $9D -> LM's CM16 $1D
	db $00		;>Flag $9E -> LM's CM16 $1E
	db $00		;>Flag $9F -> LM's CM16 $1F
	db $00		;>Flag $A0 -> LM's CM16 $20
	db $00		;>Flag $A1 -> LM's CM16 $21
	db $00		;>Flag $A2 -> LM's CM16 $22
	db $00		;>Flag $A3 -> LM's CM16 $23
	db $00		;>Flag $A4 -> LM's CM16 $24
	db $00		;>Flag $A5 -> LM's CM16 $25
	db $00		;>Flag $A6 -> LM's CM16 $26
	db $00		;>Flag $A7 -> LM's CM16 $27
	db $00		;>Flag $A8 -> LM's CM16 $28
	db $00		;>Flag $A9 -> LM's CM16 $29
	db $00		;>Flag $AA -> LM's CM16 $2A
	db $00		;>Flag $AB -> LM's CM16 $2B
	db $00		;>Flag $AC -> LM's CM16 $2C
	db $00		;>Flag $AD -> LM's CM16 $2D
	db $00		;>Flag $AE -> LM's CM16 $2E
	db $00		;>Flag $AF -> LM's CM16 $2F
	db $00		;>Flag $B0 -> LM's CM16 $30
	db $00		;>Flag $B1 -> LM's CM16 $31
	db $00		;>Flag $B2 -> LM's CM16 $32
	db $00		;>Flag $B3 -> LM's CM16 $33
	db $00		;>Flag $B4 -> LM's CM16 $34
	db $00		;>Flag $B5 -> LM's CM16 $35
	db $00		;>Flag $B6 -> LM's CM16 $36
	db $00		;>Flag $B7 -> LM's CM16 $37
	db $00		;>Flag $B8 -> LM's CM16 $38
	db $00		;>Flag $B9 -> LM's CM16 $39
	db $00		;>Flag $BA -> LM's CM16 $3A
	db $00		;>Flag $BB -> LM's CM16 $3B
	db $00		;>Flag $BC -> LM's CM16 $3C
	db $00		;>Flag $BD -> LM's CM16 $3D
	db $00		;>Flag $BE -> LM's CM16 $3E
	db $00		;>Flag $BF -> LM's CM16 $3F
	db $00		;>Flag $C0 -> LM's CM16 $40
	db $00		;>Flag $C1 -> LM's CM16 $41
	db $00		;>Flag $C2 -> LM's CM16 $42
	db $00		;>Flag $C3 -> LM's CM16 $43
	db $00		;>Flag $C4 -> LM's CM16 $44
	db $00		;>Flag $C5 -> LM's CM16 $45
	db $00		;>Flag $C6 -> LM's CM16 $46
	db $00		;>Flag $C7 -> LM's CM16 $47
	db $00		;>Flag $C8 -> LM's CM16 $48
	db $00		;>Flag $C9 -> LM's CM16 $49
	db $00		;>Flag $CA -> LM's CM16 $4A
	db $00		;>Flag $CB -> LM's CM16 $4B
	db $00		;>Flag $CC -> LM's CM16 $4C
	db $00		;>Flag $CD -> LM's CM16 $4D
	db $00		;>Flag $CE -> LM's CM16 $4E
	db $00		;>Flag $CF -> LM's CM16 $4F
	db $00		;>Flag $D0 -> LM's CM16 $50
	db $00		;>Flag $D1 -> LM's CM16 $51
	db $00		;>Flag $D2 -> LM's CM16 $52
	db $00		;>Flag $D3 -> LM's CM16 $53
	db $00		;>Flag $D4 -> LM's CM16 $54
	db $00		;>Flag $D5 -> LM's CM16 $55
	db $00		;>Flag $D6 -> LM's CM16 $56
	db $00		;>Flag $D7 -> LM's CM16 $57
	db $00		;>Flag $D8 -> LM's CM16 $58
	db $00		;>Flag $D9 -> LM's CM16 $59
	db $00		;>Flag $DA -> LM's CM16 $5A
	db $00		;>Flag $DB -> LM's CM16 $5B
	db $00		;>Flag $DC -> LM's CM16 $5C
	db $00		;>Flag $DD -> LM's CM16 $5D
	db $00		;>Flag $DE -> LM's CM16 $5E
	db $00		;>Flag $DF -> LM's CM16 $5F
	db $00		;>Flag $E0 -> LM's CM16 $60
	db $00		;>Flag $E1 -> LM's CM16 $61
	db $00		;>Flag $E2 -> LM's CM16 $62
	db $00		;>Flag $E3 -> LM's CM16 $63
	db $00		;>Flag $E4 -> LM's CM16 $64
	db $00		;>Flag $E5 -> LM's CM16 $65
	db $00		;>Flag $E6 -> LM's CM16 $66
	db $00		;>Flag $E7 -> LM's CM16 $67
	db $00		;>Flag $E8 -> LM's CM16 $68
	db $00		;>Flag $E9 -> LM's CM16 $69
	db $00		;>Flag $EA -> LM's CM16 $6A
	db $00		;>Flag $EB -> LM's CM16 $6B
	db $00		;>Flag $EC -> LM's CM16 $6C
	db $00		;>Flag $ED -> LM's CM16 $6D
	db $00		;>Flag $EE -> LM's CM16 $6E
	db $00		;>Flag $EF -> LM's CM16 $6F
	db $00		;>Flag $F0 -> LM's CM16 $70
	db $00		;>Flag $F1 -> LM's CM16 $71
	db $00		;>Flag $F2 -> LM's CM16 $72
	db $00		;>Flag $F3 -> LM's CM16 $73
	db $00		;>Flag $F4 -> LM's CM16 $74
	db $00		;>Flag $F5 -> LM's CM16 $75
	db $00		;>Flag $F6 -> LM's CM16 $76
	db $00		;>Flag $F7 -> LM's CM16 $77
	db $00		;>Flag $F8 -> LM's CM16 $78
	db $00		;>Flag $F9 -> LM's CM16 $79
	db $00		;>Flag $FA -> LM's CM16 $7A
	db $00		;>Flag $FB -> LM's CM16 $7B
	db $00		;>Flag $FC -> LM's CM16 $7C
	db $00		;>Flag $FD -> LM's CM16 $7D
	db $00		;>Flag $FE -> LM's CM16 $7E
	db $00		;>Flag $FF -> LM's CM16 $7F
?GetFlagNumberLayerProcessingEnd:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;List of positions.
;With the help of asar's function (not sure if Xkas first made this or not),
;adding a location to the table is very easy. Format:
;
;dw GetC800IndexHorizLvl($HHHH, $XXXX, $YYYY)
;dw GetC800IndexVertiLvl($XXXX, $YYYY)
;
;-$HHHH is the level height (in pixels), basically RAM address $13D7. Fastest way to
; know what value is this in a level is in lunar magic, hover your mouse on the last
; row of blocks, and the status bar on the window (<XPos_in_hex>,<YPos_in_hex>:<TileNumber>),
; take the  and add 1 AND THEN multiply by $10 (or just add a zero at the end;
; example: ($1A + 1)*$10 = $1B0)
;-$XXXX and $YYYY are the block coordinates, in units of 16x16 blocks (not pixels).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
?GetFlagNumberC800IndexStart:
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $0 -> LM's CM16 $0
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $1 -> LM's CM16 $1
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $2 -> LM's CM16 $2
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $3 -> LM's CM16 $3
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $4 -> LM's CM16 $4
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $5 -> LM's CM16 $5
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $6 -> LM's CM16 $6
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $7 -> LM's CM16 $7
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $8 -> LM's CM16 $8
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $9 -> LM's CM16 $9
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $A -> LM's CM16 $A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $B -> LM's CM16 $B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $C -> LM's CM16 $C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $D -> LM's CM16 $D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $E -> LM's CM16 $E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $F -> LM's CM16 $F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $10 -> LM's CM16 $10
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $11 -> LM's CM16 $11
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $12 -> LM's CM16 $12
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $13 -> LM's CM16 $13
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $14 -> LM's CM16 $14
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $15 -> LM's CM16 $15
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $16 -> LM's CM16 $16
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $17 -> LM's CM16 $17
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $18 -> LM's CM16 $18
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $19 -> LM's CM16 $19
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $1A -> LM's CM16 $1A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $1B -> LM's CM16 $1B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $1C -> LM's CM16 $1C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $1D -> LM's CM16 $1D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $1E -> LM's CM16 $1E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $1F -> LM's CM16 $1F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $20 -> LM's CM16 $20
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $21 -> LM's CM16 $21
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $22 -> LM's CM16 $22
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $23 -> LM's CM16 $23
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $24 -> LM's CM16 $24
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $25 -> LM's CM16 $25
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $26 -> LM's CM16 $26
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $27 -> LM's CM16 $27
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $28 -> LM's CM16 $28
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $29 -> LM's CM16 $29
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $2A -> LM's CM16 $2A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $2B -> LM's CM16 $2B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $2C -> LM's CM16 $2C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $2D -> LM's CM16 $2D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $2E -> LM's CM16 $2E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $2F -> LM's CM16 $2F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $30 -> LM's CM16 $30
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $31 -> LM's CM16 $31
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $32 -> LM's CM16 $32
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $33 -> LM's CM16 $33
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $34 -> LM's CM16 $34
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $35 -> LM's CM16 $35
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $36 -> LM's CM16 $36
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $37 -> LM's CM16 $37
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $38 -> LM's CM16 $38
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $39 -> LM's CM16 $39
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $3A -> LM's CM16 $3A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $3B -> LM's CM16 $3B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $3C -> LM's CM16 $3C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $3D -> LM's CM16 $3D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $3E -> LM's CM16 $3E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $3F -> LM's CM16 $3F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $40 -> LM's CM16 $40
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $41 -> LM's CM16 $41
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $42 -> LM's CM16 $42
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $43 -> LM's CM16 $43
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $44 -> LM's CM16 $44
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $45 -> LM's CM16 $45
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $46 -> LM's CM16 $46
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $47 -> LM's CM16 $47
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $48 -> LM's CM16 $48
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $49 -> LM's CM16 $49
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $4A -> LM's CM16 $4A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $4B -> LM's CM16 $4B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $4C -> LM's CM16 $4C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $4D -> LM's CM16 $4D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $4E -> LM's CM16 $4E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $4F -> LM's CM16 $4F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $50 -> LM's CM16 $50
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $51 -> LM's CM16 $51
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $52 -> LM's CM16 $52
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $53 -> LM's CM16 $53
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $54 -> LM's CM16 $54
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $55 -> LM's CM16 $55
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $56 -> LM's CM16 $56
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $57 -> LM's CM16 $57
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $58 -> LM's CM16 $58
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $59 -> LM's CM16 $59
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $5A -> LM's CM16 $5A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $5B -> LM's CM16 $5B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $5C -> LM's CM16 $5C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $5D -> LM's CM16 $5D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $5E -> LM's CM16 $5E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $5F -> LM's CM16 $5F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $60 -> LM's CM16 $60
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $61 -> LM's CM16 $61
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $62 -> LM's CM16 $62
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $63 -> LM's CM16 $63
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $64 -> LM's CM16 $64
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $65 -> LM's CM16 $65
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $66 -> LM's CM16 $66
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $67 -> LM's CM16 $67
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $68 -> LM's CM16 $68
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $69 -> LM's CM16 $69
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $6A -> LM's CM16 $6A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $6B -> LM's CM16 $6B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $6C -> LM's CM16 $6C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $6D -> LM's CM16 $6D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $6E -> LM's CM16 $6E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $6F -> LM's CM16 $6F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $70 -> LM's CM16 $70
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $71 -> LM's CM16 $71
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $72 -> LM's CM16 $72
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $73 -> LM's CM16 $73
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $74 -> LM's CM16 $74
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $75 -> LM's CM16 $75
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $76 -> LM's CM16 $76
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $77 -> LM's CM16 $77
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $78 -> LM's CM16 $78
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $79 -> LM's CM16 $79
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $7A -> LM's CM16 $7A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $7B -> LM's CM16 $7B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $7C -> LM's CM16 $7C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $7D -> LM's CM16 $7D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $7E -> LM's CM16 $7E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $7F -> LM's CM16 $7F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $80 -> LM's CM16 $0
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $81 -> LM's CM16 $1
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $82 -> LM's CM16 $2
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $83 -> LM's CM16 $3
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $84 -> LM's CM16 $4
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $85 -> LM's CM16 $5
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $86 -> LM's CM16 $6
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $87 -> LM's CM16 $7
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $88 -> LM's CM16 $8
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $89 -> LM's CM16 $9
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $8A -> LM's CM16 $A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $8B -> LM's CM16 $B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $8C -> LM's CM16 $C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $8D -> LM's CM16 $D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $8E -> LM's CM16 $E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $8F -> LM's CM16 $F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $90 -> LM's CM16 $10
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $91 -> LM's CM16 $11
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $92 -> LM's CM16 $12
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $93 -> LM's CM16 $13
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $94 -> LM's CM16 $14
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $95 -> LM's CM16 $15
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $96 -> LM's CM16 $16
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $97 -> LM's CM16 $17
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $98 -> LM's CM16 $18
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $99 -> LM's CM16 $19
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $9A -> LM's CM16 $1A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $9B -> LM's CM16 $1B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $9C -> LM's CM16 $1C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $9D -> LM's CM16 $1D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $9E -> LM's CM16 $1E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $9F -> LM's CM16 $1F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $A0 -> LM's CM16 $20
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $A1 -> LM's CM16 $21
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $A2 -> LM's CM16 $22
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $A3 -> LM's CM16 $23
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $A4 -> LM's CM16 $24
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $A5 -> LM's CM16 $25
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $A6 -> LM's CM16 $26
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $A7 -> LM's CM16 $27
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $A8 -> LM's CM16 $28
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $A9 -> LM's CM16 $29
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $AA -> LM's CM16 $2A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $AB -> LM's CM16 $2B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $AC -> LM's CM16 $2C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $AD -> LM's CM16 $2D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $AE -> LM's CM16 $2E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $AF -> LM's CM16 $2F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $B0 -> LM's CM16 $30
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $B1 -> LM's CM16 $31
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $B2 -> LM's CM16 $32
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $B3 -> LM's CM16 $33
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $B4 -> LM's CM16 $34
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $B5 -> LM's CM16 $35
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $B6 -> LM's CM16 $36
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $B7 -> LM's CM16 $37
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $B8 -> LM's CM16 $38
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $B9 -> LM's CM16 $39
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $BA -> LM's CM16 $3A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $BB -> LM's CM16 $3B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $BC -> LM's CM16 $3C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $BD -> LM's CM16 $3D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $BE -> LM's CM16 $3E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $BF -> LM's CM16 $3F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $C0 -> LM's CM16 $40
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $C1 -> LM's CM16 $41
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $C2 -> LM's CM16 $42
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $C3 -> LM's CM16 $43
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $C4 -> LM's CM16 $44
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $C5 -> LM's CM16 $45
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $C6 -> LM's CM16 $46
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $C7 -> LM's CM16 $47
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $C8 -> LM's CM16 $48
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $C9 -> LM's CM16 $49
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $CA -> LM's CM16 $4A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $CB -> LM's CM16 $4B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $CC -> LM's CM16 $4C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $CD -> LM's CM16 $4D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $CE -> LM's CM16 $4E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $CF -> LM's CM16 $4F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $D0 -> LM's CM16 $50
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $D1 -> LM's CM16 $51
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $D2 -> LM's CM16 $52
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $D3 -> LM's CM16 $53
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $D4 -> LM's CM16 $54
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $D5 -> LM's CM16 $55
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $D6 -> LM's CM16 $56
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $D7 -> LM's CM16 $57
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $D8 -> LM's CM16 $58
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $D9 -> LM's CM16 $59
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $DA -> LM's CM16 $5A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $DB -> LM's CM16 $5B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $DC -> LM's CM16 $5C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $DD -> LM's CM16 $5D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $DE -> LM's CM16 $5E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $DF -> LM's CM16 $5F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $E0 -> LM's CM16 $60
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $E1 -> LM's CM16 $61
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $E2 -> LM's CM16 $62
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $E3 -> LM's CM16 $63
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $E4 -> LM's CM16 $64
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $E5 -> LM's CM16 $65
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $E6 -> LM's CM16 $66
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $E7 -> LM's CM16 $67
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $E8 -> LM's CM16 $68
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $E9 -> LM's CM16 $69
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $EA -> LM's CM16 $6A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $EB -> LM's CM16 $6B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $EC -> LM's CM16 $6C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $ED -> LM's CM16 $6D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $EE -> LM's CM16 $6E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $EF -> LM's CM16 $6F
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $F0 -> LM's CM16 $70
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $F1 -> LM's CM16 $71
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $F2 -> LM's CM16 $72
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $F3 -> LM's CM16 $73
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $F4 -> LM's CM16 $74
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $F5 -> LM's CM16 $75
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $F6 -> LM's CM16 $76
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $F7 -> LM's CM16 $77
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $F8 -> LM's CM16 $78
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $F9 -> LM's CM16 $79
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $FA -> LM's CM16 $7A
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $FB -> LM's CM16 $7B
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $FC -> LM's CM16 $7C
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $FD -> LM's CM16 $7D
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $FE -> LM's CM16 $7E
	dw GetC800IndexHorizLvl($01B0, $0000, $0000)		;>Flag $FF -> LM's CM16 $7F
?GetFlagNumberC800IndexEnd: