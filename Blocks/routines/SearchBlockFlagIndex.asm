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
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Tables below. Each item in the table is each flag number.
	;Orders correspond on each table (all first items
	;are associated, second associated, and so on).
	;
	;Also make sure the list is entirely in between the starting labels
	;([?GetFlagNumberLevelIndexStart] and [?GetFlagNumberC800IndexStart]) and the
	;ending label ([?GetFlagNumberLevelIndexEnd] and [?GetFlagNumberC800IndexEnd])
	;so that all are counted properly during execution.
	;
	;I would recommend making sure the tables here are 1 item per line and using
	;Notepad++ and use [Edit -> Column editor -> Number to Insert] and:
	;Initial number: 0
	;Increase by: 1 or 2
	;Leading zeroes: checked
	;Format: Dec or hex
	;so you can instantly add a comment (see example to the right of the dw table)
	;and conveniently numbered for easy of what flag number each item in their tables
	;are associated to.
	;
	;After inserting the column, make sure you check that the index number in that
	;column at the bottom does not exceed the last flag number index in your hack
	;that you're going to use.
	;
	;
	;Example: 2 Group-128 means flag number up to 255 is valid
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;?GetFlagNumberLevelIndexStart
	;dw $0105						;>Flag 0 (X=$0000)
	;dw $0106						;>Flag 1 (X=$0002)
	;[...]
	;dw $0080						;>Flag 255 (X=$01FE)
	;dw $0081						;>Flag 256 (X=$0200) >This one is exceeding the last index.
	;?GetFlagNumberLevelIndexEnd
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Same goes with the second table:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;?GetFlagNumberC800IndexStart:
	;dw GetC800IndexHorizLvl($01B0, $0002, $0016)		;>Flag 0 (X=$0000)
	;dw GetC800IndexHorizLvl($01B0, $0002, $0016)		;>Flag 1 (X=$0002)
	;[...]
	;dw GetC800IndexHorizLvl($01B0, $003D, $0010)		;>Flag 255 (X=$01FE)
	;dw GetC800IndexHorizLvl($01B0, $00B8, $0014)		;>Flag 256 (X=$0200) >This one is exceeding the last index.
	
	
	?GetFlagNumberLevelIndexStart:
	;List of level numbers. This is essentially what level the flags are in.
	;
	;Note: you CAN have duplicate level numbers here if you have multiple flags
	;in a single level.
	dw $0105						;>Flag 0 (X=$0000)
	dw $0106						;>Flag 1 (X=$0002)
	?GetFlagNumberLevelIndexEnd:
	?GetFlagNumberLayerProcessingStart:
	;List of what layer the block is on. Put "$01" for layer 2 blocks if you
	;are using a layer 2 level and have the blocks on that layer.
	db $00							;>Flag 0
	db $00							;>Flag 1
	?GetFlagNumberLayerProcessingEnd:
	?GetFlagNumberC800IndexStart:
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
	; take the <YPos_in_hex> and add 1 AND THEN multiply by $10 (or just add a zero at the end;
	; example: ($1A + 1)*$10 = $1B0)
	;-$XXXX and $YYYY are the block coordinates, in units of 16x16 blocks (not pixels).
	dw GetC800IndexHorizLvl($01B0, $0002, $0016)		;>Flag 0 (X=$0000)
	dw GetC800IndexHorizLvl($01B0, $0002, $0016)		;>Flag 1 (X=$0002)
	?GetFlagNumberC800IndexEnd: