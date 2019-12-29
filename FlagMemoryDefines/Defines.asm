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
;Note: $ indicates hex, this include the !Defines being set to a value
;and the formula explaining how much bytes they use.
;
 if !sa1 == 0
  !Freeram_MemoryFlag = $7FAD49
 else
  !Freeram_MemoryFlag = $4001B9
 endif
 ;^[BytesUsed = NumberOfGroups*$10] a table containing an array of
 ; "global memory" flags. NumberOfGroups is how many groups of 128 flags
 ; you want in your hack, up to 16. For example:
 ;
 ; One level uses all 128 bits on !Freeram_MemoryFlag to !Freeram_MemoryFlag+$0F
 ; Another level also uses 128 bits !Freeram_MemoryFlag+$10 to !Freeram_MemoryFlag+$1F
 ;
 ; This means 2 groups of 128-bits would result the formula [32 bytes = 2 * $10].
 ; You can also make multiple levels use the same group-128 if any of the level
 ; sharing this uses less than 128 flags to save memory and not have "gaps".
 ;
 ; I would highly recommend make a note in a txt file listing the RAM flag areas
 ; so you can keep track of the flags and where they are, made-up example:
 ;
 ; !Freeram_MemoryFlag+$00 to !Freeram_MemoryFlag+$0F: used in level $105, $106 ($105: 0-63, $106: 64-127)
 ; !Freeram_MemoryFlag+$10 to !Freeram_MemoryFlag+$1F: used in level $107, $102, $103 ($107: 0-49, $102: 50-100, $103: 101-127)
 ;
 ; It would be foolish to use this ASM resource if your entire hack
 ; uses 128 or less flags since you can use $7FC060 alone. Unless you use it for
 ; creating your own special levels.

 if !sa1 == 0
  !Scratchram_WriteArrayC800 = $7F844A
 else
  !Scratchram_WriteArrayC800 = $400198
 endif
 ;^[15 bytes] To be used in a routine [WriteBlockArrayToC800_WriteArrayC800]
 ; due to a subroutine used within a subroutine have a conflicting scratch RAM
 ; and was necessary to keep track of the positioning of the tile during a loop.
 
 if !sa1 == 0
  !Scratchram_TempBlockSettings = $8A
 else
  !Scratchram_TempBlockSettings = $8A
 endif
 ;^[3 bytes] temporary storage during "WroteBlockArrayToC800"
 ; when processing a code that writes to stage.
 ; +$00 to +$01: $C800 index
 ; +$02:         #$00 if the flag table is clear and any nonzero value when set.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;display RAM on asar console window.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;print "Low byte location:      $", hex(!Scratchram_WriteArrayC800+00), " to $", hex(!Scratchram_WriteArrayC800+02)
;print "High byte location:     $", hex(!Scratchram_WriteArrayC800+03), " to $", hex(!Scratchram_WriteArrayC800+05)
;print "Number of blocks:       $", hex(!Scratchram_WriteArrayC800+06)
;print "Block width:            $", hex(!Scratchram_WriteArrayC800+07)
;print "X Position to place:    $", hex(!Scratchram_WriteArrayC800+08), " to $", hex(!Scratchram_WriteArrayC800+09)
;print "Y Position to place:    $", hex(!Scratchram_WriteArrayC800+10), " to $", hex(!Scratchram_WriteArrayC800+11)
;print "Overwritten:-------------------------------------"
;print "X line of blocks left:  $", hex(!Scratchram_WriteArrayC800+12)
;print "X position during loop: $", hex(!Scratchram_WriteArrayC800+13), " to $", hex(!Scratchram_WriteArrayC800+14)