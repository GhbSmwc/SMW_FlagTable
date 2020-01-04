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
;
;Note: [Must be saved] indicates that you must have these RAM not to
;be reset during level transitions, they must retain their values.
;
;You should also be very careful to prevent things that would get the
;player permanently stuck. Example is that locked doors/gate respawning
;while the keys don't, rendering it possible to run out of keys while
;progressing the stages.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Note: $ indicates hex, this include the !Defines being set to a value
;and the formula explaining how much bytes they use.
;
 if !sa1 == 0
  !Freeram_MemoryFlag = $7FAD49
 else
  !Freeram_MemoryFlag = $4001B9
 endif
 ;^[BytesUsed = NumberOfGroups*$10] [Must be saved] a table containing an array of
 ; "global memory" flags. NumberOfGroups is how many groups of 128 bit flags
 ; you want in your hack, up to 16. For example:
 ;
 ; One level uses all 128 bits on !Freeram_MemoryFlag to !Freeram_MemoryFlag+$0F
 ; Another level also uses 128 bits !Freeram_MemoryFlag+$10 to !Freeram_MemoryFlag+$1F
 ;
 ; This means 2 groups of 128-bits would result the formula [32 = 2 * $10] (32 bytes),
 ; Therefore the range of !Freeram_MemoryFlag is !Freeram_MemoryFlag+$0 to
 ; !Freeram_MemoryFlag+$1F (default example: $7FAD49 to $7FAD68)
 ;
 ; You can also make multiple levels use the same group-128 if any of the level
 ; sharing this uses less than 128 flags to save memory and not have "gaps".
 ;
 ; I would highly recommend make a note in a txt file listing the RAM flag areas
 ; so you can keep track of the flags and where they are, made-up example:
 ;
 ; !Freeram_MemoryFlag+$00 to !Freeram_MemoryFlag+$0F: used in level $105, $106 ($105: 0-63, $106: 64-127)
 ; !Freeram_MemoryFlag+$10 to !Freeram_MemoryFlag+$1F: used in level $107, $102, $103 ($107: 0-49, $102: 50-100, $103: 101-127)
 if !sa1 == 0
  !Freeram_KeyCounter = $7FAD79
 else
  !Freeram_KeyCounter = $4001E9
 endif
 ;^[BytesUsed = How_Many_local_key_counter_you_want] [Must be saved] How many keys the player have. Note that this is stored as a table
 ; with each byte being their own separate key counter local to the level(s) they are associated with. This is to prevent
 ; the player from taking the key they got from one area, exit to the map, go to another "main" level and use that key
 ; on the completely different level. This is similar to how modern Legend of Zelda's dungeon keys to only be useable
 ; in the dungeon you found them.
 ;
 ; Here is how the memory works (example):
 ; !Freeram_KeyCounter+$00: $0105, $01CB
 ; !Freeram_KeyCounter+$01: $0106, $01CA
 ; !Freeram_KeyCounter+$02: $0103, $01FD
 ; [...]
 ;
 ; So levels are given what key counter they should use, if you don't have keys matching to the locked doors, it won't open.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Collectible key:
 !Settings_MBCM16_KeyHitboxSize = 1
 ;^hitbox size:
 ; 0 = Full 16x16 block
 ; 1 = 16x16 Sprite-styled hitbox (actually its hitbox is 12x10, used by
 ;     most powerup sprites).
 
 !Settings_MBCM16_SoundRAM = $1DFC|!addr
 !Settings_MBCM16_SoundNum = $15
 ;^What sound to play with picking up the key.