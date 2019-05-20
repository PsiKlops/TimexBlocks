;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name :   tetInit.asm
; Purpose   :   Tetris Wrist App Common Utility Routines
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;INCLUDED IN STATES THAT NEED THE INITIALISATION FUNCTION ;;;;;;;;;;;;;;;

tetInitialise:
				;clear block parse states
                ld      A, #0
                ld      [TETDisplayStatus], A
                ld      [TET_Flags], A
                ld      [TET_Score1], A
                ld      [TET_Score2], A
 
 				;;		Start the game - block falling at initial speed
                ld      A, #TET_GAME_STATUS_START_FLAGS
                ld      [TET_GameStatus], A

                ;ld      A, #TET_FALL_SPEED_1    ;;Setting this here in init will cause game to freeze on second run (after blocks fill screen)??? Although we get a 16 bit time out otherwise and it freezes eventually
                ;ld      [TET_FallUpdateCnt], A
                           

                ;;Set 'Left L' as next shape to draw - DONT NEED TO COPY BLOCKS JUST DO THIS I THINK ?
                ld      A, #TET_SHAPE_LEFT_L_TYPE
                ld      [TET_NextShapeNum], A
 			  
 				;;Has our noddy timeout happened?
				ld      HL,#TET_GameUpdateCnt                         
				ld      [HL], #TET_UPDATE_COUNT   ;;Reset TET_GameUpdate counter
                
                car tetInitBlkAndNextSwitch  ;; make sure 'next' and 'this' block are both random 
                car tetInitBlkAndNextSwitch  ;;- so do it twice to shuffle them thru the queue
                
                ;;Initialise the block pos variables to the Init Block position
                ld		HL,#TET_BlockPosX
				ld		[HL],#TET_INITIAL_BLOCK_START_X				
				ld		HL,#TET_BlockPosY
				ld		[HL],#TET_INITIAL_BLOCK_START_Y
				
				car		tetGetCurrentBlockPosIntoParserPos

                ; start our stopwatch resource
                ld      HL, [CORECurrentASDAddress]
                ld      A, [HL]
                KSTP_START_RESOURCE
               
                ;;//;;//;;//;;//;;// DATABASE ACCESS ;;//;;//;;//;;//;;//;;//
                ;;//;;//;;//;;//;;// DATABASE ACCESS ;;//;;//;;//;;//;;//;;//
                ;;//;;//;;//;;//;;// DATABASE ACCESS ;;//;;//;;//;;//;;//;;//
                
                ; Read currently viewed record from the EEPROM
                ld      HL, [CORECurrentADDAddress]
                ld      [DBExternalMemoryAddress], HL
                DB_OPEN_FILE
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				; read in data from eeprom to internal memory
				; this example is accessing a sequential type structure
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				; specify the base offset of a record in the database
				; always 0 for sequential access memory
				ld HL, #0000H
				ld [DBExternalMemoryAddress], HL
				; specify the memory buffer to store the data read from eeprom
				ld HL, #TET_HiScore1
				ld [DBInternalMemoryAddress], HL
				; specify the number of bytes to transfer
				ld A, #2
				ld [DBLengthLo], A
				; read the data array from eeprom database

				DB_READ_RECORD
				DB_CLOSE_FILE


                ret
                
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;       This func is a copy of whats in BlkSw                                                             ;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  tetUtilGetRandomBlockNum:

				ld	B,#0
				;CORE_SET_RANDOM_SEED
				CORE_GENERATE_RANDOM_NUMBER
				
				ld	HL,BA
				
				ld  A,#(TET_BLOCK_NUM_MAX +1)
				
				div
				
				dec	A	; we get remainder in range 1 to 7 so decrement so it becomes 0 to 6
				
				ld A,H  ;; remainder will be our random result

				ret		
				
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;       This is very similar to whats in BlkSw as well                                                             ;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copy next block data to current and then Get random 'next' block count and set the 'Next' block data to appropriate bit map   
tetInitBlkAndNextSwitch:

				
                ;;CLEAR THE NEXT BLOCK -> not here! just do it in blkswtch version 
                ;ld      HL, #TET_GameStatus
                ;or     [HL], #bTET_GS_DrawAtNextPos
				;ld		IY,#TET_NextShape_7_0
                ;car		tetClearBlock   ;; Clear the Next block  off screen                
                ;ld      HL, #TET_GameStatus
                ;and     [HL], #@LOW(~bTET_GS_DrawAtNextPos)


			    ;Copy 'Next' block bit map to 'Current'
                ld      IY, #TET_NextShape_7_0          
 				ld      IX, #TET_Current_Shape_7_0
				car		tetCopyBlockFromIYToBlockAtIXAndPointIYAtIX  ;;now copy the block from temp

                
	            ;Both 'Line' and 'Square' are 4 x 4 rotation type, so clear the flag in preparation for test
                ld		HL,#TETDisplayStatus                
                and		[HL],#(~bTET_3_x_3_Rotate)    ; set the block rotation style to be 4 x 4

                car		tetUtilGetRandomBlockNum   ;;into A
				ld      HL, #TET_NextShapeNum
				cp		[HL],#TET_SHAPE_SQUARE_TYPE	
				jr		GE, TET_DontSet3x3Rotate			
                ld		HL,#TETDisplayStatus                
                or		[HL],#bTET_3_x_3_Rotate    ; set the block rotation style to be 3 x 3 by default
TET_DontSet3x3Rotate:
			
				
				ld      HL, #TET_NextShapeNum ;;really needs optimising all this reloading regs, if i can be assed
				ld      IY, #TET_CurrentBlockType
                ld      [IY],[HL]   ; copy next to current num/type
                
                ld		[HL],A  ;;Override 'Next' with our random A
                				
;;Was going to have a look up in data memory but decided to just use a space wasting switch case type affair 
;;instead since we have extra states to play in
				cp		[HL],#TET_SHAPE_RIGHT_SNAKE_TYPE				
				jr		NZ, tetSkipRightSnake							
                ld      A, #@LOW(TET_SHAPE_RIGHT_SNAKE)
                ld      [TET_NextShape_7_0], A
                ld      A, #@HIGH(TET_SHAPE_RIGHT_SNAKE)         
                jr		tetSwitchBlockEnd               

tetSkipRightSnake:                			
				cp		[HL],#TET_SHAPE_LEFT_SNAKE_TYPE				
				jr		NZ, tetSkipLeftL
                ld      A, #@LOW(TET_SHAPE_LEFT_SNAKE)
                ld      [TET_NextShape_7_0], A
                ld      A, #@HIGH(TET_SHAPE_LEFT_SNAKE)         
                jr		tetSwitchBlockEnd
tetSkipLeftL:
				cp		[HL],#TET_SHAPE_LEFT_L_TYPE				
				jr		NZ, tetSkipRightL
                ld      A, #@LOW(TET_SHAPE_LEFT_L)
                ld      [TET_NextShape_7_0], A
                ld      A, #@HIGH(TET_SHAPE_LEFT_L)         
                jr		tetSwitchBlockEnd
tetSkipRightL:
				cp		[HL],#TET_SHAPE_RIGHT_L_TYPE				
				jr		NZ, tetSkipT
                ld      A, #@LOW(TET_SHAPE_RIGHT_L)
                ld      [TET_NextShape_7_0], A
                ld      A, #@HIGH(TET_SHAPE_RIGHT_L)         
                jr		tetSwitchBlockEnd
tetSkipT:
				cp		[HL],#TET_SHAPE_T_TYPE				
				jr		NZ, tetSkipSquare
                ld      A, #@LOW(TET_SHAPE_T)
                ld      [TET_NextShape_7_0], A
                ld      A, #@HIGH(TET_SHAPE_T)         
                jr		tetSwitchBlockEnd
tetSkipSquare:

				cp		[HL],#TET_SHAPE_SQUARE_TYPE				
				jr		NZ, tetSkipLine
                ld      A, #@LOW(TET_SHAPE_SQUARE)
                ld      [TET_NextShape_7_0], A
                ld      A, #@HIGH(TET_SHAPE_SQUARE)         
                jr		tetSwitchBlockEnd
tetSkipLine:
				;Has to be a line if we get here
                ld      A, #@LOW(TET_SHAPE_LINE)
                ld      [TET_NextShape_7_0], A
                ld      A, #@HIGH(TET_SHAPE_LINE)         

tetSwitchBlockEnd:
                ld      [TET_NextShape_15_8], A   ;common code: copy last part of bit map 
 
 
                ret
