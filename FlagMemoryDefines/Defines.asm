;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SA-1 handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Only include this if there is no SA-1 detection, such as including this
;in a (seperate) patch.
if defined("!sa1") == 0
	!dp = $0000
	!addr = $0000
	!sa1 = 0
	!gsu = 0

	if read1($00FFD6) == $15
		sfxrom
		!dp = $6000
		!addr = !dp
		!gsu = 1
	elseif read1($00FFD5) == $23
		sa1rom
		!dp = $3000
		!addr = $6000
		!sa1 = 1
	endif
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Freeram
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 if !sa1 == 0
  !Freeram_MemoryFlag = $7FC060
 else
  !Freeram_MemoryFlag = $4001D8
 endif
 ;^[(Ceiling(NumberOfFlags/8)) bytes] a table containing an array of
 ; flags. The more flags you have in your hack, the more bytes are taken:
 ; 1-8 flags: 1 byte
 ; 9-16 flags: 2 bytes
 ; 17-24 flags: 3 bytes
 ; 25-32 flags: 4 bytes
 ; and so on.

 if !sa1 == 0
  !Scratchram_WriteArrayC800 = $7F844A
 else
  !Scratchram_WriteArrayC800 = $400198
 endif
 ;^[15 bytes] To be used in a routine [WriteBlockArrayToC800_WriteArrayC800]
 ; due to a subroutine used within a subroutine have a conflicting scratch RAM
 ; and was necessary to keep track of the positioning of the tile during a loop.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;display RAM on asar console window.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print "Low byte location:      $", hex(!Scratchram_WriteArrayC800+00), " to $", hex(!Scratchram_WriteArrayC800+02)
print "High byte location:     $", hex(!Scratchram_WriteArrayC800+03), " to $", hex(!Scratchram_WriteArrayC800+05)
print "Number of blocks:       $", hex(!Scratchram_WriteArrayC800+06)
print "Block width:            $", hex(!Scratchram_WriteArrayC800+07)
print "X Position to place:    $", hex(!Scratchram_WriteArrayC800+08), " to $", hex(!Scratchram_WriteArrayC800+09)
print "Y Position to place:    $", hex(!Scratchram_WriteArrayC800+10), " to $", hex(!Scratchram_WriteArrayC800+11)
print "Overwritten:-------------------------------------"
print "X line of blocks left:  $", hex(!Scratchram_WriteArrayC800+12)
print "X position during loop: $", hex(!Scratchram_WriteArrayC800+13), " to $", hex(!Scratchram_WriteArrayC800+14)