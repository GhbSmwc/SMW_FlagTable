	incsrc "../FlagMemoryDefines/Defines.asm"
	
;Execute like this:
;in level:
;	load:
;	JSL MBM16WriteTo7FC060_LoadFlagTableToCM16
;	;[...]
;	RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Load flag table into conditional map16 flags (CM16: $7FC060)
;
;Because the CM16 is 16 bytes large ($7FC060-$7FC06F; total of
;128 bits numbered from $00-$7F), !Freeram_MemoryFlag will have
;to be divided into groups of 16 bytes:
;
;Group 0: !Freeram_MemoryFlag+$00 to !Freeram_MemoryFlag+$0F
;Group 1: !Freeram_MemoryFlag+$10 to !Freeram_MemoryFlag+$1F
;Group 2: !Freeram_MemoryFlag+$20 to !Freeram_MemoryFlag+$0F
;[...]
;
;This code handles it like this (in this order):
;1) Find what index number of the current level being loaded
;2) Use that index number to find what group the level is
;   associated with.
;3) Take the now-known group in !Freeram_MemoryFlag and transfer
;   the data into $7FC060-$7FC06F.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LoadFlagTableToCM16:
	PHB				;\update bank
	PHK				;|
	PLB				;/
	REP #$30			;>16-bit AXY
	
	LDX.w #(.LevelList_End-.LevelList)-2
	LDY.w #((.LevelList_End-.LevelList)/2)-1
	
	.Loop
	LDA $010B|!addr			;\Search what index the current level is on.
	CMP .LevelList,x		;|
	BEQ .Found			;|
	
	..Next
	DEY				;|
	DEX #2				;|
	BPL .Loop			;/
	
	.NotFound
	;X=$FFFE			;\If in a level not listed, don't do anything
	;Y=$FFFF			;|
	BRA .Done			;/
	
	.Found
	;X = (levelIndex*2)
	;Y = LevelIndex
	SEP #$20					;
	LDA.b #!Freeram_MemoryFlag     : STA $00	;\Find what level listed is associated to what 128-group.
	LDA.b #!Freeram_MemoryFlag>>8  : STA $01	;|
	LDA.b #!Freeram_MemoryFlag>>16 : STA $02	;|
	
	LDA $00						;|
	CLC						;|
	ADC .OneHundredTwentyEightFlagGroupList,y	;|
	STA $00						;|
	LDA $01						;|
	ADC #$00					;|
	STA $01						;|
	;LDA $02					;|
	;ADC #$00					;|
	;STA $02					;/$00-$02 = !Freeram_MemoryFlag+(GroupNumber*$10)
	
	.TransferTo7FC060
	SEP #$30
	LDY #$0F					;\Transfer.
	LDX #$0F					;|>Because STA $xxxxxx,y does not exist.
	..Loop
	LDA [$00],y					;|
	STA $7FC060,x					;|
	DEY						;|
	DEX						;|
	BPL ..Loop					;/
	
	.Done
	SEP #$30
	PLB				;>Restore bank
	RTL
	
	.LevelList
	;Avoid having duplicate level numbers here, thus all level numbers
	;must be unique.
	dw $0105		;>Item 0 (X = $0000, Y = $0000)
	dw $0106		;>Item 1 (X = $0002, Y = $0001)
	..End
	
	.OneHundredTwentyEightFlagGroupList
	;^Labels cannot start with numbers on the string.
	; Only put numbers that are multiples of 16 ($10):
	; Group 0: $00
	; Group 1: $10
	; Group 2: $20
	;
	; [ValueInTable = GroupNumber*$10], or simply $<groupNumb>0.
	;
	; Although I could simply not use a table and assume what item
	; in the level list is [TableGroup = LevelIndex*$10], that would
	; make it impossible if you want to conserve RAM by having multiple
	; levels using the same group number (when one level uses less than
	; 128 bits).
	db $00
	..end