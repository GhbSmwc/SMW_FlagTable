	incsrc "../FlagMemoryDefines/Defines.asm"
	function GetC800IndexHorizLvl(RAM13D7, XPos, YPos) = (RAM13D7*(XPos/16))+(YPos*16)+(XPos%16)
	function GetC800IndexVertiLvl(XPos, YPos) = (512*(YPos/16))+(256*(XPos/16))+((YPos%16)*16)+(XPos%16)
;Make sure you have [math round on] to prevent unexpected rounded numbers.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Routines list:
;
;Routines specific to this ASM code:
;-WriteFlaggedBlocksC800
;
;Other routines:
;-Write2DArrayC800
;-WriteHorizLineArrayC800
;-WriteVertiLineArrayC800
;-GetLevelMap16IndexByMap16Position
;-GetMap16PositionByLevelMap16Index
;-MathMul16_16
;-MathDiv
;-BitToByteIndex
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Handle what blocks in level should spawn based on the flags stored in !Freeram_MemoryFlag.
;
;To be executed as a subroutine from level load.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WriteFlaggedBlocksC800:
	PHB						;\Switch to current bank
	PHK						;|
	PLB						;/
	REP #$30					;>16-bit AXY
	LDX.w #(.LeveListEnd-.LeveListStart)-2		;>X = Index*2
	LDY.w #((.LeveListEnd-.LeveListStart)/2)-1	;>Y = Index
	
	.Loop
	..Process
	...CheckCurrentLevelNumber
	LDA.l .LeveListStart,x			;>Level number from list
	CMP $010B|!addr				;>Compare with current level number
	BNE ..Next
	
	...GetFlag
	TYA					;>Transfer flag number to A
	PHX					;>Preserve 16-bit X
	PHY					;>Preserve 16-bit Y
	SEP #$20				;>8-bit A
	JSL BitToByteIndex			;>Get byte address location and what bit.
	LDA !Freeram_MemoryFlag,x
	AND BitSelectTable,y			;>Clear all bits except the bit we select.
	STA !Scratchram_TempBlockSettings+02	;>Store desired bit into scratch RAM
	REP #$20				;>16-bit A
	PLY					;>Restore 16-bit Y
	PLX					;>Restore 16-bit X
	
	...GetBlockLocation
	LDA.l .BlockIndexListStart,x		;\Insert the index number for the routine
	STA $00					;/
	STA !Scratchram_TempBlockSettings	;>In the event you need to write just one block, use this as index.
	PHX					;>Preserve 16-bit X
	PHY					;>Preserve 16-bit Y
	SEP #$30				;>8-bit AXY
	JSL GetMap16PositionByLevelMap16Index	;>Convert index to a total-of-4-bytes coordinates. Output: (RAM_00, RAM_02)
	REP #$10				;>16-bit XY
	PLY					;>Restore 16-bit Y
	PLX					;>Restore 16-bit X
	
	....HandleBlockArray
	PHX					;>Preserve 16-bit X
	PHY					;>Preserve 16-bit Y
	TYX					;>Had use X as a Index and not Index*2 due to LDA $xxxxxx,y doesn't exist (and so is LDX $xxxxxx,x).
	LDA #$00				;\Clear A's high byte
	XBA					;/
	LDA.l .BlockArrayTypeIDList,x		;>A = ArrayID ($00XX)
	REP #$20
	ASL					;\Get ArrayID*2 for X
	TAX					;/
	SEP #$20
	JSR (.BlockArrayRoutineTable,x)
	REP #$30
	PLY					;>Restore Y
	PLX					;>Restore X
	
	..Next
	DEY
	DEX #2					;>DEX comes after DEY to allow flags beyond $7F.
	BPL .Loop				;>Check if 16-bit X = $FFFE, then break loop.
	
	.Done
	SEP #$30
	PLB					;>Restore bank.
	RTL
	
	.LeveListStart
	dw $0105						;>Flag 0 (X=$0000)
	dw $0105						;>Flag 1 (X=$0002)
	.LeveListEnd
	
	.BlockIndexListStart
	dw GetC800IndexHorizLvl($01B0, $000F, $0014)		;>Flag 0 (X=$0000)
	dw GetC800IndexHorizLvl($01B0, $001F, $0014)		;>Flag 1 (X=$0002)
	
	.BlockArrayTypeIDList
	;This table contains what array ID of blocks to write into the level.
	;Default what each of these IDs do:
	;$00 = 1x1 block that is a cement block when the flag is 0 and coin when 1.
	;$01
	db $00							;>Flag 0 (Y=$0000)
	db $00							;>Flag 1 (Y=$0001)
	
	.BlockArrayRoutineTable
	dw Dimension1x1Block0130x002B				;>Flag 0 (X=$0002)
	
	;Don't touch this.
	BitSelectTable:	;Applies to all example codes presented here.
	db %00000001 ;>Bit 0
	db %00000010 ;>Bit 1
	db %00000100 ;>Bit 2
	db %00001000 ;>Bit 3
	db %00010000 ;>Bit 4
	db %00100000 ;>Bit 5
	db %01000000 ;>Bit 6
	db %10000000 ;>Bit 7
	
	;Here are the routines, Y = the flag index. X is safe to use.
	;Some RAM to use:
	;-$00-$01 contains the block X position
	;-$02-$03 contains the block Y position
	; ^Those positions to be used with block-array writer routines
	;  (Write2DArrayC800, WriteHorizLineArrayC800, and WriteVertiLineArrayC800)
	;-!Scratchram_TempBlockSettings+$00 to +$01 contains the $C800 index
	;-!Scratchram_TempBlockSettings+$02 contains $00 if flag clear and nonzero when set.
	;Make sure the routines here end with an RTS and not RTL due to
	;JSL ($xxxxxx,x) do not exist.
	Dimension1x1Block0130x002B:
	REP #$30				;>16-bit AXY
	LDA !Scratchram_TempBlockSettings
	TAX
	SEP #$20				;>8-bit A
	LDA !Scratchram_TempBlockSettings+$02	;\Clear or set?
	BEQ .Clear				;/
	
	.Set
	LDA.b #$0130
	if !sa1 == 0
		STA $7EC800,x
	else
		STA $40C800,x
	endif
	LDA.b #$0130>>8
	if !sa1 == 0
		STA $7FC800,x
	else
		STA $41C800,x
	endif
	BRA .Done
	
	.Clear
	LDA.b #$0300
	if !sa1 == 0
		STA $7EC800,x
	else
		STA $40C800,x
	endif
	LDA.b #$0300>>8
	if !sa1 == 0
		STA $7FC800,x
	else
		STA $41C800,x
	endif
	.Done
	SEP #$30
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Write a 2D array of blocks into $C800 (does not work with layer 2 blocks if layer 2 level).
;
; !Scratchram_WriteArrayC800 usage range: 00 to +14 ($00 to $0E)
;
;Input:
; -!Scratchram_WriteArrayC800+00 to !Scratchram_WriteArrayC800+02: Table location containing low bytes
; -!Scratchram_WriteArrayC800+03 to !Scratchram_WriteArrayC800+05: Table location containing high bytes
; -!Scratchram_WriteArrayC800+06:                                  Number of blocks, minus 1, to transfer the 2D array table.
; -!Scratchram_WriteArrayC800+07:                                  Number of blocks wide, minus 1, to transfer the 2D array table.
; -!Scratchram_WriteArrayC800+08 to !Scratchram_WriteArrayC800+09: Block array X position to place in $C800 table.
; -!Scratchram_WriteArrayC800+10 to !Scratchram_WriteArrayC800+11: Block array Y position to place in $C800 table.
;
;Overwritten:
; -!Scratchram_WriteArrayC800+12:                                  Number of blocks left as the loop processes each line (copied from +07).
; -!Scratchram_WriteArrayC800+13 to !Scratchram_WriteArrayC800+14: X position during a loop, initially copied from (+08)
;
;Example:
; load:
;  LDA.b #Table0     : STA !Scratchram_WriteArrayC800+00	;\Table location
;  LDA.b #Table0>>8  : STA !Scratchram_WriteArrayC800+01	;|
;  LDA.b #Table0>>16 : STA !Scratchram_WriteArrayC800+02	;|
;  LDA.b #Table1     : STA !Scratchram_WriteArrayC800+03	;|
;  LDA.b #Table1>>8  : STA !Scratchram_WriteArrayC800+04	;|
;  LDA.b #Table1>>16 : STA !Scratchram_WriteArrayC800+05	;/
;  
;  LDA.b #(Table0_end-Table0)-1				;\Table size, minus 1
;  STA !Scratchram_WriteArrayC800+06			;/
;  LDA.b #(Table0_endOfRow-Table0)-1			;\How many items in each row, minus 1
;  STA !Scratchram_WriteArrayC800+07			;/
;  
;  REP #$20						;\Position
;  LDA #$001E						;|
;  STA !Scratchram_WriteArrayC800+08			;|
;  LDA #$0010						;|
;  STA !Scratchram_WriteArrayC800+10			;|
;  SEP #$20						;/
;  JSL WriteBlockArrayToC800_WriteArrayC800
;  RTL
;  Table0:
;  db $0000,$0001,$0002               ;>Top row
;  .endOfRow                          ;>This label used for find how many items each row.
;  db $0010,$0011,$0012               ;>Second row
;  db $0020,$0021,$0022               ;>Third row
;  .end
;  Table1:
;  db $0000>>8,$0000>>8,$0000>>8
;  db $0000>>8,$0000>>8,$0000>>8
;  db $0000>>8,$0000>>8,$0000>>8
;  .end
;  ;Protip on creating tables: Just focus on making 4-digit hex numbers table using "db" ($xxxx), make sure all numbers are
;  ;like that, and once you're done, create a copy of that, and add ">>8" so that it will take the upper 8 bits of the map16
;  ;numbers.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Write2DArrayC800:
	LDA !Scratchram_WriteArrayC800+7		;\Line counter backup
	STA !Scratchram_WriteArrayC800+12		;/
	REP #$20
	LDA !Scratchram_WriteArrayC800+08		;\Tracking X position
	STA !Scratchram_WriteArrayC800+13		;/
	SEP #$20
	REP #$10					;>16-bit XY (due to X needed to be 16-bit for the C800 indexing)
	LDY #$0000					;>Y = what item in table.
	
	.Loop
	LDA !Scratchram_WriteArrayC800+00 : STA $00	;\Transfer table address to $00 (low byte).
	LDA !Scratchram_WriteArrayC800+01 : STA $01	;|
	LDA !Scratchram_WriteArrayC800+02 : STA $02	;/
	LDA [$00],y					;>Load an item from 2D table
	PHY						;>Push Y, what byte was selected in table
	PHA						;>Push A, what byte value in table.
	REP #$20					;\>16-bit A
	LDA !Scratchram_WriteArrayC800+13		;|Write tile (low byte)
	STA $00						;|
	LDA !Scratchram_WriteArrayC800+10		;|
	STA $02						;|
	SEP #$30					;|>8-bit AXY
	JSL GetLevelMap16IndexByMap16Position		;|
	REP #$10					;|>16-bit XY
	LDX $00						;|>X = block index
	PLA						;|>Restore A, what byte value in table
	BCS +						;|>Failsafe (don't write blocks outside of level)
	if !sa1 == 0
		STA $7EC800,x				;|
	else
		STA $40C800,x				;/
	endif
	LDA !Scratchram_WriteArrayC800+03 : STA $00	;\Transfer table address to $00 (high byte).
	LDA !Scratchram_WriteArrayC800+04 : STA $01	;|
	LDA !Scratchram_WriteArrayC800+05 : STA $02	;/
	+
	PLY						;>Restore Y (what item in table).
	BCS ..Next					;>Failsafe (don't write blocks outside of level)
	LDA [$00],y					;\Write high byte
	if !sa1 == 0
		STA $7FC800,x				;|
	else
		STA $41C800,x				;/
	endif
	
	..Next
	INY
	LDA !Scratchram_WriteArrayC800+12		;\Decrement number of blocks in the current line to process
	SEC						;|
	SBC #$01					;|
	STA !Scratchram_WriteArrayC800+12		;/
	;BPL ...HorizontalLineIncomplete		;>Once 0 -> $FF, newline, otherwise continue on the line.
	BCS ...HorizontalLineIncomplete
	
	...HorizontalLineComplete
	;Next line, go back to the left and down a line
	LDA !Scratchram_WriteArrayC800+07		;\Reset the "line of blocks left"
	STA !Scratchram_WriteArrayC800+12		;/
	REP #$20
	LDA !Scratchram_WriteArrayC800+08		;\Reset X position
	STA !Scratchram_WriteArrayC800+13		;/
	LDA !Scratchram_WriteArrayC800+10		;\Move down a line
	INC						;|
	STA !Scratchram_WriteArrayC800+10		;/
	SEP #$20
	BRA ...NextBlockInTable
	
	...HorizontalLineIncomplete
	;Continue onwards on the line.
	REP #$20
	LDA !Scratchram_WriteArrayC800+13		;\Move over to the right
	INC						;|
	STA !Scratchram_WriteArrayC800+13		;/
	SEP #$20
	
	...NextBlockInTable
	LDA !Scratchram_WriteArrayC800+06		;\Decrease number of blocks left
	SEC						;|
	SBC #$01					;|>Used SEB : SBC instead of BPL/BMI
	STA !Scratchram_WriteArrayC800+06		;/so you can use up to 255 indexes (256-array)
	;BPL .Loop					;>Loop till all blocks in table are all copied.
	BCC +
	JMP .Loop
	+
	RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Write a horizontal line of blocks into $C800 (does not work with layer 2 blocks if layer 2 level).
;
; !Scratchram_WriteArrayC800 usage range: 00 to +10 ($00 to $0A)
;
; -!Scratchram_WriteArrayC800+00 to !Scratchram_WriteArrayC800+02: Table location containing low bytes
; -!Scratchram_WriteArrayC800+03 to !Scratchram_WriteArrayC800+05: Table location containing high bytes
; -!Scratchram_WriteArrayC800+06:                                  Number of blocks, minus 1.
; -!Scratchram_WriteArrayC800+07 to !Scratchram_WriteArrayC800+08: Block array X position to place in $C800 table.
; -!Scratchram_WriteArrayC800+09 to !Scratchram_WriteArrayC800+10: Block array Y position to place in $C800 table.
;
;Example usage:
;	load:
;	LDA.b #Table0     : STA !Scratchram_WriteArrayC800+00	;\Table location
;	LDA.b #Table0>>8  : STA !Scratchram_WriteArrayC800+01	;|
;	LDA.b #Table0>>16 : STA !Scratchram_WriteArrayC800+02	;|
;	LDA.b #Table1     : STA !Scratchram_WriteArrayC800+03	;|
;	LDA.b #Table1>>8  : STA !Scratchram_WriteArrayC800+04	;|
;	LDA.b #Table1>>16 : STA !Scratchram_WriteArrayC800+05	;/
;	
;	LDA.b #(Table0_end-Table0)-1				;\Table size, minus 1
;	STA !Scratchram_WriteArrayC800+06			;/
;	
;	REP #$20						;\Position
;	LDA #$0001						;|
;	STA !Scratchram_WriteArrayC800+07			;|
;	LDA #$0012						;|
;	STA !Scratchram_WriteArrayC800+09			;|
;	SEP #$20						;/
;	JSL WriteBlockArrayToC800_WriteHorizLineArrayC800
;	RTL
;	Table0:
;	db $12F
;	db $12F
;	db $12F
;	.end
;	Table1:
;	db $12F>>8
;	db $12F>>8
;	db $12F>>8
;	.end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WriteHorizLineArrayC800:
	REP #$10
	LDY #$0000
	
	.Loop
	LDA !Scratchram_WriteArrayC800+00 : STA $00	;\Transfer table address to $00 (low byte).
	LDA !Scratchram_WriteArrayC800+01 : STA $01	;|
	LDA !Scratchram_WriteArrayC800+02 : STA $02	;/
	LDA [$00],y					;>Load an item from 2D table
	PHY						;>Push Y, what byte was selected in table
	PHA						;>Push A, what byte value in table.
	REP #$20					;\>16-bit A
	LDA !Scratchram_WriteArrayC800+07		;|Write tile (low byte)
	STA $00						;|
	LDA !Scratchram_WriteArrayC800+09		;|
	STA $02						;|
	SEP #$30					;|>8-bit AXY
	JSL GetLevelMap16IndexByMap16Position		;|
	REP #$10					;|>16-bit XY
	LDX $00						;|>X = block index
	PLA						;|>Restore A, what byte value in table
	BCS +						;|>Failsafe (don't write blocks outside of level)
	if !sa1 == 0
		STA $7EC800,x				;|
	else
		STA $40C800,x				;/
	endif
	LDA !Scratchram_WriteArrayC800+03 : STA $00	;\Transfer table address to $00 (high byte).
	LDA !Scratchram_WriteArrayC800+04 : STA $01	;|
	LDA !Scratchram_WriteArrayC800+05 : STA $02	;/
	+
	PLY						;>Restore Y (what item in table).
	BCS ..Next					;>Failsafe (don't write blocks outside of level)
	LDA [$00],y					;\Write high byte
	if !sa1 == 0
		STA $7FC800,x				;|
	else
		STA $41C800,x				;/
	endif
	..Next
	INY
	REP #$20
	LDA !Scratchram_WriteArrayC800+07		;\Next block to the right
	INC						;|
	STA !Scratchram_WriteArrayC800+07		;/
	SEP #$20					
	LDA !Scratchram_WriteArrayC800+06		;\Subtract number of blocks
	SEC						;|
	SBC #$01					;|
	STA !Scratchram_WriteArrayC800+06		;/
	BCS .Loop					;>If unsigned underflow ($00->$FF), break loop.
	RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Write a vertical line of blocks into $C800 (does not work with layer 2 blocks if layer 2 level).
;
; !Scratchram_WriteArrayC800 usage range: 00 to +10 ($00 to $0A)
;
; -!Scratchram_WriteArrayC800+00 to !Scratchram_WriteArrayC800+02: Table location containing low bytes
; -!Scratchram_WriteArrayC800+03 to !Scratchram_WriteArrayC800+05: Table location containing high bytes
; -!Scratchram_WriteArrayC800+06:                                  Number of blocks, minus 1.
; -!Scratchram_WriteArrayC800+07 to !Scratchram_WriteArrayC800+08: Block array X position to place in $C800 table.
; -!Scratchram_WriteArrayC800+09 to !Scratchram_WriteArrayC800+10: Block array Y position to place in $C800 table.
;Same as the horizontal line of blocks.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WriteVertiLineArrayC800:
	REP #$10
	LDY #$0000
	
	.Loop
	LDA !Scratchram_WriteArrayC800+00 : STA $00	;\Transfer table address to $00 (low byte).
	LDA !Scratchram_WriteArrayC800+01 : STA $01	;|
	LDA !Scratchram_WriteArrayC800+02 : STA $02	;/
	LDA [$00],y					;>Load an item from 2D table
	PHY						;>Push Y, what byte was selected in table
	PHA						;>Push A, what byte value in table.
	REP #$20					;\>16-bit A
	LDA !Scratchram_WriteArrayC800+07		;|Write tile (low byte)
	STA $00						;|
	LDA !Scratchram_WriteArrayC800+09		;|
	STA $02						;|
	SEP #$30					;|>8-bit AXY
	JSL GetLevelMap16IndexByMap16Position		;|
	REP #$10					;|>16-bit XY
	LDX $00						;|>X = block index
	PLA						;|>Restore A, what byte value in table
	BCS +						;|>Failsafe (don't write blocks outside of level)
	if !sa1 == 0
		STA $7EC800,x				;|
	else
		STA $40C800,x				;/
	endif
	LDA !Scratchram_WriteArrayC800+03 : STA $00	;\Transfer table address to $00 (high byte).
	LDA !Scratchram_WriteArrayC800+04 : STA $01	;|
	LDA !Scratchram_WriteArrayC800+05 : STA $02	;/
	+
	PLY						;>Restore Y (what item in table).
	BCS ..Next					;>Failsafe (don't write blocks outside of level)
	LDA [$00],y					;\Write high byte
	if !sa1 == 0
		STA $7FC800,x				;|
	else
		STA $41C800,x				;/
	endif
	..Next
	INY
	REP #$20
	LDA !Scratchram_WriteArrayC800+09		;\Next block downwards
	INC						;|
	STA !Scratchram_WriteArrayC800+09		;/
	SEP #$20					
	LDA !Scratchram_WriteArrayC800+06		;\Subtract number of blocks
	SEC						;|
	SBC #$01					;|
	STA !Scratchram_WriteArrayC800+06		;/
	BCS .Loop					;>If unsigned underflow ($00->$FF), break loop.
	RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Obtain level map16 ($7EC800/$7FC800) indexing via block
;;coordinates.
;;
;;Input:
;; -$00 to $01: X position, in units of full blocks (increments by
;;  one means a full 16x16 block, unlike $9A-$9B, which are pixels).
;; -$02 to $03: Same as above but for Y position
;;Output:
;; -$00-$01: The index of the blocks.
;; -Carry: Set if coordinate points to outside of level.
;;Overwritten:
;  -If SA-1 not applied:
;; --$04 to $0B: copy of $00 due to math routines.
;; -If SA-1 applied:
;; --None overwritten
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Things to note: A level screen is ALWAYS 16 blocks wide
;(regardless of the level dimension), thus, index can be written
;as in binary as %00YYYYYYYYYYXXXX as an offset from the first
;block of every screen column. The tile data are ordered like
;this:
;1) As the index increases, it goes from left to right within
;   the row of 16 blocks (within a level screen boundary). After
;   the 16th, the next block is wrapped back to the left and on
;   the next row of blocks below. This is known as
;   "Row-Major order".
;2) Once the last block within a screen is reach (bottom right),
;   the next block would be on the screen BELOW the screen the
;   previous block is on (not the next screen), if not, then go
;   to the second column repeating the "downwards, then next column"
;   order. This order is known as "Column-Major order".
;
;Input bit info:
; $00-$01: %0000000XXXXXxxxx (%00000000000Xxxxx for vertical level)
;  Uppercase X: What screen column.
;  Lowercase x: What block within the row of 16 blocks.
; $02-$03: %000000yyyyyyyyyy (%0000000YYYYYyyyy for vertical level)
;  Lowercase y: What row of 16x16 blocks. Note currently
;  as of LM3.03, the highest value for Y (bottommost block) is
;  $037F (%0000001101111111) for horizontal levels, and $01BF
;(%0000000110111111) for vertical levels.
;
;Horizontal level:
; Formula:
;  Index = (BlocksPerScrnCol * floor(XPos/16)) + (YPos*16) + (XPos MOD 16).
;Vertical level:
; Formula:
;  Index = (512 * floor(YPos/16)) + (256 * floor(XPos/16)) + ((YPos MOD 16)*16) + (XPos MOD 16)
;
; Thankfully, each screen is a number power of 2 for the number of blocks per screen: 512 ($0200)
; (which is 2^9), and so does its width and height (2^5 = 32 and 2^4 = 16) which means screen
; unit handling is easier than horizontal levels. The bit format of the index is %YYYYYXyyyyxxxx

GetLevelMap16IndexByMap16Position:
	;Check level format
	LDA $5B
	LSR
	BCS .VerticalLevel
	
	.HorizontalLevel
	;Check if the given position is outside the level.
	REP #$20
	LDA $13D7|!addr				;\Check if Y position is past the bottom of the level.
	LSR #4					;|
	CMP $02					;|
	BEQ .Invalid				;|
	BCC .Invalid				;/
	
	LDA $00					;\Check if X position is past the last screen column of the level
	LSR #4					;|>%0000000XXXXXxxxx -> %00000000000XXXXX
	SEP #$20				;|>%000XXXXX
	CMP $5E					;|>Compare with the last screen number +1
	BCS .Invalid				;/If that or higher, mark as invalid.
	
	;Obtain number of blocks per screen column.
	;Thankfully, $13D7 is also the number of blocks per screen column, because
	;$13D7 is the level height, in unit of pixels, dividing that by 16 ($10,
	;or LSR #4) gives the units in blocks, multiply that by 16 (ASL #4) will
	;give you the number of blocks per screen column. But because you are
	;multiplying by 16 then dividing by 16, this cancel each other out.
	if !sa1 == 0
		REP #$20
		LDA $02				;\Move $02-$03 to $0A-$0B (Y pos)
		STA $0A				;/
		LDA $00				;\Move $00-$01 to $08-$09 (X pos)
		STA $08				;/
		LSR #4				;\what screen column
		STA $00				;/
		LDA $13D7|!addr			;\blocks per screen column
		STA $02				;/
		JSL MathMul16_16		;>$04-$05: Total number of blocks of all screen columns to the left of (exclude at) the coordinate point.
		REP #$20			
		LDA $0A				;\$02-$03 (now $0A-$0B if SA-1): %000000yyyyyyyyyy becomes %00yyyyyyyyyy0000
		ASL #4				;|
		STA $02				;/
		LDA $08				;\(%000000000000xxxx | %00yyyyyyyyyy0000) + (RAM_13D7 * %XXXXX)
		AND.w #%0000000000001111	;|in this order
		ORA $02				;|
		CLC				;|
		ADC $04				;/
	else
		LDA #$00			;\ Multiplication Mode.
		STA $2250			;/

		REP #$20				;
		LDA $00 			;\what screen column
		LSR #4				;|
		STA $2251			;/
		LDA $13D7|!addr			;\Blocks per screen column
		STA $2253			;/
		NOP				;\ ... Wait 5 cycles!
		BRA $00 			;/$2306-$2307: Total number of blocks of all screen columns to the left of (exclude at) the coordinate point.
		
		LDA $02				;\$02-$03: %000000yyyyyyyyyy becomes %00yyyyyyyyyy0000
		ASL #4				;|
		STA $02				;/
		
		LDA $00				;\(%000000000000xxxx | %00yyyyyyyyyy0000) + (RAM_13D7 * %XXXXX)
		AND.w #%0000000000001111	;|in this order
		ORA $02				;|
		CLC				;|
		ADC $2306			;/
	endif
	STA $00					;>Output
	SEP #$20
	CLC
	RTL
	
	.Invalid
	SEP #$21
	RTL
	
	.VerticalLevel
	;$00-$01: %00000000 000Xxxxx
	;$02-$03: %0000000Y YYYYyyyy
	;Rearrange to:
	;$00-$01: %00YYYYYX yyyyxxxx
	
	
	
	;Check if the given position is outside the level.
	REP #$20
	LDA $00					;\(1) X valid ranges from $0000 to $001F
	CMP #$0020				;|
	BCS .Invalid1				;/
	LDA $02					;\Check if Y position is past the last screen of the level
	LSR #4					;|%0000000YYYYYyyyy -> %00000000000YYYYY
	SEP #$20				;|
	CMP $5F					;|>Last screen + 1
	BCS .Invalid1				;/
	
	REP #$20
	LDA $00					;
	AND.w #%0000000000010000		;>(2) what halves of the screen
	ASL #4					;>A: %00000000 000X0000 -> %0000000X 00000000
	ORA $00					;>A: %0000000X 00000000 -> %0000000X 000-xxxx
	AND.w #%0000000100001111		;>A: %0000000X 000-xxxx -> %0000000X 0000xxxx
	STA $00					;>$00 now have all X position bits done.
	
	LDA $02					;>$02: %0000000Y YYYYyyyy
	ASL #4					;>A:   %000YYYYY yyyy0000
	SEP #$20				;>A:   %000YYYYY [yyyy0000]
	ORA $00					;>A:   %yyyy0000 || %0000xxxx -> %yyyyxxxx
	STA $00					;>$00 low bits Y position done.
	REP #$20
	LDA $02					;>$02: %0000000Y YYYYyyyy
	AND.w #%0000000111110000		;>A:   %0000000Y YYYY0000
	ASL #5					;>A:   %00YYYYY0 00000000
	ORA $00					;>A:   %00YYYYY0 00000000 || %0000000X yyyyxxxx
	STA $00					;>$00 is %00YYYYYX yyyyxxxx
	SEP #$20
	CLC
	RTL
	
	.Invalid1
	SEP #$21
	RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Obtain block coordinate from $7EC800/$7FC800 indexing.
;;
;;Input:
;; -$00 to $01: The index of $7EC800/$7FC800. Index above $37FF is
;;  invalid.
;;Output:
;; -$00 to $01: X position (in units of blocks, each increment
;;  means a full block).
;; -$02 to $03: Y position, same as above but vertical position.
;; -Carry: Set if index is invalid or would be at a location
;;  outside the level boundary.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Computation as follows:
;Horizontal level:
; XPos = (floor(BlockIndex/BlocksPerScreenCol)*16) + (Index MOD 16)
; YPos = floor((BlockIndex MOD BlocksPerScreenCol)/16)
;
; BlocksPerScreenCol is basically RAM $13D7, it not only holds the
; height of the level in pixels, it also holds the number of
; blocks per screen column.
;Vertical level:
; XPos = (floor((BlockIndex MOD 512)/256)*16) + (BlockIndex MOD 16)
; YPos = (floor(BlockIndex/512)*16) + (floor(BlockIndex/16) MOD 16)
;
; In boolean bitwise operation, you simply rearrange the group
; of bits due to the width and height as well as the number of
; blocks per screen are powers of 2.
GetMap16PositionByLevelMap16Index:
	REP #$20
	LDA $00
	CMP #$3800
	BCS .Invalid
	SEP #$20
	LDA $5B
	LSR
	REP #$20
	BCS .VerticalLevel

	.HorizontalLevel
	if !sa1 == 0
		LDA $13D7|!addr			;\Index divide by number of blocks per screen column
		STA $02				;|
		JSL MathDiv			;/Q ($00-$01) = %00000000000XXXXX, R ($02-$03) = %00yyyyyyyyyyxxxx
		REP #$20			;
		LDA $00				;\$00-$01: %00000000000XXXXX -> %0000000XXXXX0000 (part of converting to X position by convert to block units)
		ASL #4				;|
		STA $00				;/
		LDA $02				;>$02-$03: %00yyyyyyyyyyxxxx
		AND.w #%0000000000001111	;>A: %000000000000xxxx
		ORA $00				;>OR with %0000000XXXXX0000
		STA $00				;>$00-$01:%0000000XXXXXxxxx ((ScreenColumnPassed*16) + XPosWithinCol)
		LDA $02				;\$02-$03: %00yyyyyyyyyyxxxx -> %000000yyyyyyyyyy (divide Y by 16)
		LSR #4				;|
		STA $02				;/
	else
		SEP #$20
		LDA #$01			;\Divide mode
		STA $2250			;/
		REP #$20
		LDA $00				;\Index divide by number of blocks per screen column
		STA $2251			;|
		LDA $13D7|!addr			;|
		STA $2253			;/Q ($2306-$2307) = %00000000000XXXXX, R ($2308-$2309) = %00yyyyyyyyyyxxxx
		NOP				;\Wait 5 cycles.
		BRA $00				;/
		LDA $2308			;\$2308-$2309 is a portion of the screen column (%00yyyyyyyyyyxxxx)
		LSR #4				;|>Divide by 16 (%00yyyyyyyyyyxxxx -> %000000yyyyyyyyyy)
		STA $02				;/
		LDA $2308			;\%00yyyyyyyyyyxxxx -> %000000000000xxxx
		AND.w #%0000000000001111	;|
		STA $00				;/
		LDA $2306			;>$2306-$2307 (quotient) = %00000000000XXXXX
		ASL #4				;>A: %00000000000XXXXX -> %0000000XXXXX0000 ((ScreenColumnPassed*16)...)
		ORA $00				;>A: (... + BlockXPosWithinColumn)
		STA $00				;>(ScreenColumnPassed*16) + BlockXPosWithinColumn (%0000000XXXXX0000 + %00000000000XXXXX)
	endif
	LDA $00					;\Screen column the block coordinate is on
	LSR #4					;/
	SEP #$20
	CMP $5E					;>If past the last screen, mark as invalid.
	BCS .Invalid
	
	.Valid
	CLC				;>Mark that this is a valid coordinate.
	RTL
	
	.Invalid
	SEP #$21
	RTL
;Rearrange this:
; $00-$01: %00YYYYYX yyyyxxxx
;to:
; $00-$01: %00000000 000Xxxxx
; $02-$03: %0000000Y YYYYyyyy
	.VerticalLevel
	LDA $00					;>$00-$01: %00YYYYYX yyyyxxxx
	AND.w #%0000000011110000		;>A:       %00000000 yyyy0000
	LSR #4					;>A:       %00000000 0000yyyy
	STA $02					;>$02-$03: %00000000 0000yyyy
	LDA $00					;>$00-$01: %00YYYYYX yyyyxxxx
	AND.w #%0011111000000000		;>A:       %00YYYYY0 00000000
	LSR #5					;>A:       %0000000Y YYYY0000
	ORA $02					;>A:       %0000000Y YYYYyyyy
	STA $02					;>$02-$03: %0000000Y YYYYyyyy ;>Y pos done.
	LDA $00					;>$00-$01: %00YYYYYX yyyyxxxx ;\Make room to place the high bit X position
	AND.w #%0000000100001111		;>A:       %0000000X 0000xxxx ;|next to the low 4 bits of X position.
	STA $00					;>$00-$01: %0000000X 0000xxxx ;/
	AND.w #%0000000100000000		;>A:       %0000000X 00000000
	LSR #4					;>A:       %00000000 000X0000
	ORA $00					;>A:       %0000000X 000Xxxxx ;>Note the duplicated X position high bit
	AND.w #%0000000000011111		;>A:       %0000000X 000Xxxxx ;>fix the high bit problem.
	STA $00					;>$00-$01: %00000000 000Xxxxx ;>X pos done.
	
	LDA $02
	LSR #4
	SEP #$20
	CMP $5F
	BCS .Invalid
	RTL
if !sa1 == 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 16bit * 16bit unsigned Multiplication
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Argusment
; $00-$01 : Multiplicand
; $02-$03 : Multiplier
; Return values
; $04-$07 : Product
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MathMul16_16:	REP #$20
		LDY $00
		STY $4202
		LDY $02
		STY $4203
		STZ $06
		LDY $03
		LDA $4216
		STY $4203
		STA $04
		LDA $05
		REP #$11
		ADC $4216
		LDY $01
		STY $4202
		SEP #$10
		CLC
		LDY $03
		ADC $4216
		STY $4203
		STA $05
		LDA $06
		CLC
		ADC $4216
		STA $06
		SEP #$20
		RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; unsigned 16bit / 16bit Division
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Arguments
; $00-$01 : Dividend
; $02-$03 : Divisor
; Return values
; $00-$01 : Quotient
; $02-$03 : Remainder
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MathDiv:	REP #$20
		ASL $00
		LDY #$0F
		LDA.w #$0000
-		ROL A
		CMP $02
		BCC +
		SBC $02
+		ROL $00
		DEY
		BPL -
		STA $02
		SEP #$20
		RTL
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Bit search. This is basically euclidean division
;by 8 to determine what bit and byte to read and
;write. Very useful if you have a table where each
;item is 1 bit large instead of a byte.
;
;Input:
; -A (8-bit) = what bit number (a flag), 0-255 ($00-$FF)
;Output:
; -X (8-bit) = What byte in byte-array to check from.
;  Up to X=31 ($1F) due to floor(255/8).
; -Y (8-bit) = what bit number in each byte: 0-7.
;
;To set a bit:
; LDA <Bitnumber>
; JSL BitToByteIndex
; LDA BitSelectTable,y
; ORA !RAMTable,x
; STA !RAMTable,x
; [...]
; BitSelectTable:	;Applies to all example codes presented here.
;  db %00000001 ;>Bit 0
;  db %00000010 ;>Bit 1
;  db %00000100 ;>Bit 2
;  db %00001000 ;>Bit 3
;  db %00010000 ;>Bit 4
;  db %00100000 ;>Bit 5
;  db %01000000 ;>Bit 6
;  db %10000000 ;>Bit 7
;
;To clear a bit:
; LDA <Bitnumber>
; JSL BitToByteIndex
; LDA BitSelectTable,y
; EOR.b #%11111111
; AND !RAMTable,x
; STA !RAMTable,x
;
;To read/check a bit:
; LDA <Bitnumber>
; JSL BitToByteIndex
; LDA !RAMTable,x
; AND BitSelectTable,y			;>Clear all bits except the bit we select.
; BEQ BitInTableClear			;\Conditions based on bit in table set or clear.
; BNE BitInTableSet			;/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BitToByteIndex:
	PHA			;>A as input preserved.
	AND.b #%00000111	;>WhatBit = Bitnumber MOD 8
	TAY			;>Place in Y.
	PLA			;>Restore what was originally in the input.
	LSR #3			;>ByteNumber = floor(Bitnumber/8)
	TAX			;>Place in X.
	RTL