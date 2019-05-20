;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; File Name    : tetblkSw.asm
; Purpose      : Tetris Application Default State Manager
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;DO NOT MODIFY THE FOLLOWING SUBROUTINE DEFINITION;;;;;;;;;;;;;;;;;

                IF @DEF('SUBROUTINE')
                    UNDEF SUBROUTINE
                ENDIF
                DEFINE  SUBROUTINE      "'tetblksw'"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Module Name : tetDefaultStateManager
; Description : Tetris Application Default State Manager.
; Assumptions : Display is cleared on first time entry into the state.
; Input(s)    : CORECurrentEvent  - system event to be processed
;               COREEventArgument - event extra information
; Output(s)   : None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                GLOBAL  tetBlockSwitchStateManager

tetBlockSwitchStateManager:
                ld      A, [CORECurrentEvent]

                ; Check if state entry event.
                cp      A, #TET_STATEENTRY
                jr      Z, tetDefaultStateStateEntryEvent

                ; Check if mode depress event.
                ;cp      A, #TET_MODEDEPRESS
                ;jr      Z, tetDefaultStateModeDepressEvent

                ; Check if crown set event.
                ;cp      A, #TET_CROWNSET
                ;jr      Z, tetDefaultPulledCrownEvent

                ;cp      A, #COREEVENT_CW_EDGE_TRAILING
                ;jr      Z, tetMoveBlockRight

                ;cp      A, #COREEVENT_CCW_EDGE_TRAILING
                ;jr      Z, tetMoveBlockLeft
                
                ;cp      A, #COREEVENT_STARTSPLITDEPRESS
                ;jr      Z, tetRotateBlock

                ;cp      A, #COREEVENT_STOPRESETDEPRESS
                ;jr      Z, tetDrawBlock - set IY

                ;TODO: Add more events detection here
                ;There are more events, add your own as needed

                ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EVENT HANDLERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tetDefaultPulledCrownEvent:
                ;**************************************************************
                ;
                ;                       CROWN SET
                ;
                ;**************************************************************

                ld      B, #TETYOUROCKSETSTATE
                CORE_REQ_STATE_CHANGE

                ret

tetDefaultStateStateEntryEvent:
                ;**************************************************************
                ;
                ;                       STATE ENTRY
                ;
                ;**************************************************************

				car tetBlkSwitch

                ; start our background timing generator
                ld      HL, [CORECurrentASDAddress]
                ld      A, [HL]
                KSTP_ENABLE_DISP_UPD_EVENT
                ret

tetDefaultStateModeDepressEvent:
                ;**************************************************************
                ;
                ;                       MODE DEPRESS
                ;
                ;**************************************************************

                ;This is default to go to the next mode

                CORE_REQ_MODE_CHANGE_NEXT

                ret
                
             ;Copy next block data to current and then Get random 'next' block count and set the 'Next' block data to appropriate bit map   
tetBlkSwitch:
				;;Has our noddy timeout happened?
				ld      HL,#TET_GameUpdateCnt         
				cp		[HL],#0
				jr		Z, tetBlkSwContinue
				
				dec		[HL]      ;   	pretty wasteful this			    
				cp		[HL],#0
				jr		NZ, tetBlkSwContinue

                ld      HL, #TET_GameStatus
				or     [HL], #@LOW(~bTET_GS_FallSpeed_1)  ;;Clear slow updating flag and therefore start the fast update
              
tetBlkSwContinue:


				;; Reset the 'hurry-up' flag
                ld      HL,#TET_GameStatus         
				and      [HL], #@LOW(~bTET_GS_FallSpeedQuick)   ;;If user wanted to hurry it up, cancel it now for new block

				car		tetSetBlockFallRate
				
                ;;CLEAR THE NEXT BLOCK
                ld      HL, #TET_GameStatus
                or     [HL], #bTET_GS_DrawAtNextPos
				ld		IY,#TET_NextShape_7_0
                car		tetClearBlock   ;; Clear the Next block  off screen                
                ld      HL, #TET_GameStatus
                and     [HL], #@LOW(~bTET_GS_DrawAtNextPos)


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
 
 
				car		tetIfNewBlockIsAlreadyCollidingThenEndGame	;;;Sets the end game flag if needs be
				
				              
				;Now we have set the block, Go back to main default state
                ld      B, #TETDEFAULTSTATE
                CORE_REQ_STATE_CHANGE_NO_CLEAR_DISPLAY
                ret
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	
;;   Pretty much what the function name says ;)		
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

tetIfNewBlockIsAlreadyCollidingThenEndGame:
   				;;;;ld HL,#DEBUG_BREAKPOINT_VALUE   ;;TEMP TEST!!!!!!!!!!!!!!!!!!!
                ld		HL,#TET_Flags                
                and		[HL],#TET_CLEAR_HIT_FLAGS
	            
	            ld		HL,#TETDisplayStatus                
                and		[HL],#TET_CLEAR_PARSER_STATUS
                or		[HL],#bTET_TestPixel		;Just test pixels - the new block at top of screen wont be colliding with walls
                               
                car		tetGetCurrentBlockPosIntoParserPos  ;;Since this destroys IX put it here!              
                ld      IY, #TET_Current_Shape_7_0
                ld      IX, #TET_Temp_Shape_7_0
                ;;;;
				;;now do the check	
                car	tetUtilBPB
				;;And see if we hit another block
                ld		HL, #TET_Flags
                bit		[HL],#TET_HIT_PIXEL_OR_WALL
                Jr		Z,tetNoNewBlockCollide
                
                ld      HL, #TET_GameStatus 
                and		[HL],#@LOW(~bTET_GS_Running)	;; Stop the game!
              
tetNoNewBlockCollide:
                ret
   
   
;;Start the fall rate counter at its full value             
tetSetBlockFallRate:
                ld      HL, #TET_GameStatus
				bit     [HL], #bTET_GS_FallSpeed_1
                jr      Z, tetBSWFallResetRate2
                
				ld      HL,#TET_FallUpdateCnt         
				ld      [HL], #TET_FALL_SPEED_1   ;;Reset TET_FallUpdateCnt counter
				jr		tetBSWResRateEnd ;;done it so leave - optimise

tetBSWFallResetRate2:
				ld      HL,#TET_FallUpdateCnt         ;;TODO -- MAKE THIS MORE EFFICIENT!!!
				ld      [HL], #TET_FALL_SPEED_2   ;;Reset TET_FallUpdateCnt counter

tetBSWResRateEnd:
				ret

	 ;INCLUDE 'C:\M851\App\Tetris\src\tetCom.asm'
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;			Get a random number into A within a hardcoded preset range -> TET_BLOCK_NUM_MAX
;;;
;;;			detroys HL,B
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		        ;;Moved from util - GLOBAL  tetUtilGetRandomBlockNum
		
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
