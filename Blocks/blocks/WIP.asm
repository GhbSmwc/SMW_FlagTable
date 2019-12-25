db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:

;WallFeet:	; when using db $37
;WallBody:
	PHY
	%BlkCoords2C800Index()
	%SearchFlagIndex()
	PLY
	REP #$20
	CMP #$FFFE
	SEP #$20
	BEQ SpriteV
	LDA #$80
	STA $7D
SpriteV:
SpriteH:

MarioCape:
MarioFireball:
RTL

print "<description>"