;Insert as [Level].

!RAMC800Bank = $7E
if !sa1 != 0
	!RAMC800Bank = $40
endif


	function GetC800IndexHorizLvl(RAM13D7, XPos, YPos) = (RAM13D7*(XPos/16))+(YPos*16)+(XPos%16)
	function GetC800IndexVertiLvl(XPos, YPos) = (512*(YPos/16))+(256*(XPos/16))+((YPos%16)*16)+(XPos%16)
load:
	.FlagMemory
	;Check flags $00-$0F
	LDX #$0F
	
	..Loop
	TXA
	PHX
	JSL BitByteTableRoutine_BitToByteIndex
	LDA !Freeram_MemoryFlag,x
	AND BitSelectTable,y			;>Clear all bits except the bit we select.
	BEQ ...BitInTableClear			;\Conditions based on bit in table set or clear.
	
	...BitInTableSet
	PLX					;>X = flag number.
	LDA C800AddrByte0,x : STA $00		;\Place $C800 addresses into RAM $00
	LDA C800AddrByte1,x : STA $01		;|
	LDA.b #!RAMC800Bank : STA $02		;/
	LDA TileLoByteWhenFlagSet,x
	STA [$00]
	INC $02					;>Go to high byte of $C800 table
	LDA TileHiByteWhenFlagSet,x
	STA [$00]
	BRA ...Next
	
	...BitInTableClear
	PLX					;>X = flag number.
	LDA C800AddrByte0,x : STA $00		;\Place $C800 addresses into RAM $00
	LDA C800AddrByte1,x : STA $01		;|
	LDA.b #!RAMC800Bank,x : STA $02		;/
	LDA TileLoByteWhenFlagClear,x
	STA [$00]
	INC $02					;>Go to high byte of $C800 table
	LDA TileHiByteWhenFlagClear,x
	STA [$00]
	
	...Next
	DEX
	BPL ..Loop
	RTL
	
	BitSelectTable:
	db %00000001 ;>Bit 0
	db %00000010 ;>Bit 1
	db %00000100 ;>Bit 2
	db %00001000 ;>Bit 3
	db %00010000 ;>Bit 4
	db %00100000 ;>Bit 5
	db %01000000 ;>Bit 6
	db %10000000 ;>Bit 7
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Tile number to write to $C800.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	TileLoByteWhenFlagClear:
	db $30 ;>Flag $00
	db $30 ;>Flag $01
	db $30 ;>Flag $02
	db $30 ;>Flag $03
	db $30 ;>Flag $04
	db $30 ;>Flag $05
	db $30 ;>Flag $06
	db $30 ;>Flag $07
	db $30 ;>Flag $08
	db $30 ;>Flag $09
	db $30 ;>Flag $0A
	db $30 ;>Flag $0B
	db $30 ;>Flag $0C
	db $30 ;>Flag $0D
	db $30 ;>Flag $0E
	db $30 ;>Flag $0F
	TileHiByteWhenFlagClear:
	db $01 ;>Flag $00
	db $01 ;>Flag $01
	db $01 ;>Flag $02
	db $01 ;>Flag $03
	db $01 ;>Flag $04
	db $01 ;>Flag $05
	db $01 ;>Flag $06
	db $01 ;>Flag $07
	db $01 ;>Flag $08
	db $01 ;>Flag $09
	db $01 ;>Flag $0A
	db $01 ;>Flag $0B
	db $01 ;>Flag $0C
	db $01 ;>Flag $0D
	db $01 ;>Flag $0E
	db $01 ;>Flag $0F
	
	TileLoByteWhenFlagSet:
	db $25 ;>Flag $00
	db $25 ;>Flag $01
	db $25 ;>Flag $02
	db $25 ;>Flag $03
	db $25 ;>Flag $04
	db $25 ;>Flag $05
	db $25 ;>Flag $06
	db $25 ;>Flag $07
	db $25 ;>Flag $08
	db $25 ;>Flag $09
	db $25 ;>Flag $0A
	db $25 ;>Flag $0B
	db $25 ;>Flag $0C
	db $25 ;>Flag $0D
	db $25 ;>Flag $0E
	db $25 ;>Flag $0F
	TileHiByteWhenFlagSet:
	db $00 ;>Flag $00
	db $00 ;>Flag $01
	db $00 ;>Flag $02
	db $00 ;>Flag $03
	db $00 ;>Flag $04
	db $00 ;>Flag $05
	db $00 ;>Flag $06
	db $00 ;>Flag $07
	db $00 ;>Flag $08
	db $00 ;>Flag $09
	db $00 ;>Flag $0A
	db $00 ;>Flag $0B
	db $00 ;>Flag $0C
	db $00 ;>Flag $0D
	db $00 ;>Flag $0E
	db $00 ;>Flag $0F
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;RAM address to write to $C800
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	C800AddrByte0:
	;This table contains the low byte of the 24-bit (3-byte) address of the map16 table.
	;($----XX)
	db $C800+GetC800IndexHorizLvl($01B0, $04, $16) ;>Flag $00
	db $C800+GetC800IndexHorizLvl($01B0, $06, $16) ;>Flag $01
	db $C800+GetC800IndexHorizLvl($01B0, $08, $16) ;>Flag $02
	db $C800+GetC800IndexHorizLvl($01B0, $0A, $16) ;>Flag $03
	db $C800+GetC800IndexHorizLvl($01B0, $0C, $16) ;>Flag $04
	db $C800+GetC800IndexHorizLvl($01B0, $0E, $16) ;>Flag $05
	db $C800+GetC800IndexHorizLvl($01B0, $10, $16) ;>Flag $06
	db $C800+GetC800IndexHorizLvl($01B0, $12, $16) ;>Flag $07
	db $C800+GetC800IndexHorizLvl($01B0, $14, $16) ;>Flag $08
	db $C800+GetC800IndexHorizLvl($01B0, $16, $16) ;>Flag $09
	db $C800+GetC800IndexHorizLvl($01B0, $18, $16) ;>Flag $0A
	db $C800+GetC800IndexHorizLvl($01B0, $1A, $16) ;>Flag $0B
	db $C800+GetC800IndexHorizLvl($01B0, $1C, $16) ;>Flag $0C
	db $C800+GetC800IndexHorizLvl($01B0, $1E, $16) ;>Flag $0D
	db $C800+GetC800IndexHorizLvl($01B0, $20, $16) ;>Flag $0E
	db $C800+GetC800IndexHorizLvl($01B0, $22, $16) ;>Flag $0F
	
	C800AddrByte1:
	;This table contains the "middle" byte of the 24-bit (3-byte) address of the map16 table.
	;($--XX--)
	db ($C800+GetC800IndexHorizLvl($01B0, $04, $16))>>8 ;>Flag $00
	db ($C800+GetC800IndexHorizLvl($01B0, $06, $16))>>8 ;>Flag $01
	db ($C800+GetC800IndexHorizLvl($01B0, $08, $16))>>8 ;>Flag $02
	db ($C800+GetC800IndexHorizLvl($01B0, $0A, $16))>>8 ;>Flag $03
	db ($C800+GetC800IndexHorizLvl($01B0, $0C, $16))>>8 ;>Flag $04
	db ($C800+GetC800IndexHorizLvl($01B0, $0E, $16))>>8 ;>Flag $05
	db ($C800+GetC800IndexHorizLvl($01B0, $10, $16))>>8 ;>Flag $06
	db ($C800+GetC800IndexHorizLvl($01B0, $12, $16))>>8 ;>Flag $07
	db ($C800+GetC800IndexHorizLvl($01B0, $14, $16))>>8 ;>Flag $08
	db ($C800+GetC800IndexHorizLvl($01B0, $16, $16))>>8 ;>Flag $09
	db ($C800+GetC800IndexHorizLvl($01B0, $18, $16))>>8 ;>Flag $0A
	db ($C800+GetC800IndexHorizLvl($01B0, $1A, $16))>>8 ;>Flag $0B
	db ($C800+GetC800IndexHorizLvl($01B0, $1C, $16))>>8 ;>Flag $0C
	db ($C800+GetC800IndexHorizLvl($01B0, $1E, $16))>>8 ;>Flag $0D
	db ($C800+GetC800IndexHorizLvl($01B0, $20, $16))>>8 ;>Flag $0E
	db ($C800+GetC800IndexHorizLvl($01B0, $22, $16))>>8 ;>Flag $0F