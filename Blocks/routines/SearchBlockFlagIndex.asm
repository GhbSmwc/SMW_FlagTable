;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Functions to make it easy to to list the coordinates into $C800 index.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function GetC800IndexHorizLvl(RAM13D7, XPos, YPos) = (RAM13D7*(XPos/16))+(YPos*16)+(XPos%16)
function GetC800IndexVertiLvl(XPos, YPos) = (512*(YPos/16))+(256*(XPos/16))+((YPos%16)*16)+(XPos%16)
;Make sure you have [math round on] to prevent unexpected rounded numbers.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This routine takes the current block $C800 index (first convert its XY coordinate into $C800 index)
;compares it to a list of $C800 indexes determine what flag the block is assigned to.
;
;The reason of having a list of indexes instead of XY coordinates is because each XY coordinate takes up a total of 4
;bytes (2 bytes for each axis, X and Y) per flag, while $C800_index takes only 2 bytes per flag.
;
;Input:
;-$00-$01: The $C800 index (Execute [BlkCoords2C800Index.asm] subroutine first)
;-[$010B|!addr] to [$010C|!addr]: Current level number. No need to write on this since it is pre-written.
;
;Output:
;-A (16-bit): the flag number, times 2 (so if it is flag 3, then A = $0006). Ranges from 0-510 ($0000-$01FE), (unless you
; added more than 256 items in the table which you shouldn't since flag numbering is designed to have up to 256 entries).
; Simply use LSR to convert to flag number. If a block wasn't assigned to any $C800_index listed here, then X=$FFFE.
; Recommended to add a check X=$FFFE as a failsafe in case of a bug could happen or if you accidentally placed a block
; at a location that isn't assigned.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	PHX		;>This is needed if you are going to have sprites interacting with this block.
	REP #$30
	LDX.w #(?GetFlagNumberC800IndexEnd-?GetFlagNumberC800IndexStart)-2 ;>Obtain the last index.
	-
	LDA $010B|!addr
	CMP.l ?GetFlagNumberLevelIndexStart,x			;\If level number not match, next
	BNE ++							;/
	LDA $00							;\If C800 index number not match, next
	CMP.l ?GetFlagNumberC800IndexStart,x			;/
	BNE ++
	BRA +							;>Match found.
	++
	DEX #2							;>Next item.
	BPL -							;>Loop till X=$FFFE (no match found), thankfully, 255*2 = 510 ($01FE) is less than 32768 ($8000).
	+
	TXA							;>Transfer indexCount*2 to A
	SEP #$30
	PLX							;>Restore potential sprite index.
	RTL
	;Note: The order in these tables relates to the flag numbering, as you
	;go down the list, the flag number increases (starting from 0). Make sure
	;that all entries are in between "Start" and "End" so that the routine
	;above catches all the items in the list and not miss them.
	
	;I would recommend using Notepad++ and use [Edit -> Column editor -> Number to Insert]
	;and:
	;Initial number: 0
	;Increase by: 1 or 2
	;Leading zeroes: checked
	;Format: Dec or hex
	;so you can instantly add a comment (see example to the right of the dw table)
	;and conveniently numbered for easy of what flag number each item in their tables
	;are associated to.
	
	
	?GetFlagNumberLevelIndexStart:
	;List of level numbers. This is essentially what level the flags are in.
	dw $0105						;>Flag 0 (X=$0000)
	dw $0105						;>Flag 1 (X=$0002)
	?GetFlagNumberLevelIndexEnd:
	?GetFlagNumberC800IndexStart:
	;List of positions.
	;With the help of asar's function (not sure if Xkas first made this or not),
	;adding a location to the table is very easy. Format:
	;
	;dw GetC800IndexHorizLvl($HHHH, $XXXX, $YYYY)
	;dw GetC800IndexVertiLvl($XXXX, $YYYY)
	;
	;-$HHHH is the level height (in pixels), basically RAM address $13D7. Fast way to
	; know what value is this in a level is in lunar magic,
	; "Change Properties in header" (Mario head), and on "Horizontal Level Mode",
	; you'll see [Level Height=<HHH> tiles, Max H-Screens=<WW>]
	; Take the value in <HHH>, add a zero at the end (example: $01B -> $01B0) and
	; that will be your $HHHH value.
	;-$XXXX and $YYYY are the block coordinates, in units of 16x16 blocks (not pixels).
	dw GetC800IndexHorizLvl($01B0, $000F, $0014)		;>Flag 0 (X=$0000)
	dw GetC800IndexHorizLvl($01B0, $001F, $0014)		;>Flag 1 (X=$0002)
	?GetFlagNumberC800IndexEnd: