;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Bit search. This is basically euclidean division
;by 8 to determine what bit and byte to read and
;write. Very useful if you have a table where each
;item is 1 bit large instead of a byte.
;
;Input:
; A (8-bit) = what bit number (a flag).
;Output:
; X (8-bit) = What byte in byte-array to check from.
; Y (8-bit) = what bit number in each byte: 0-7.
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